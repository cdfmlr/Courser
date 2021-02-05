//
//  QzClient.swift
//  Courser
//
//  Created by c on 2021/2/3.
//

import Combine
import Foundation

/// 强智教务系统客户端
///
/// 封装 QzAPI，透明处理登陆 token，并维护本地缓存。
class QzClient: Codable, JwClient {
    /// 学生
    let student: Student

    // MARK: - Caches

    /// 已登陆的用户（学生）信息
    var loggedIn: Auth?

    /// 教务系统获取的当前时间缓存
    var currentTime: CurrentTime

    /// 课表缓存: `["\(xnxqh)-\(zc)": [Course]]`
    ///
    /// 不要直接用这个属性，用 getCoursesCache 和 setCoursesCache 方法。
    var coursesCache: [String: [Course]]

    // MARK: - Mutex Locks

    private var loggedInMutex: NSLock = .init()
    private var currentTimeMutex: NSLock = .init()
    private var coursesCacheMutex: NSLock = .init()

    // MARK: - Custom Codable

    enum CodingKeys: String, CodingKey {
        case student, loggedIn, currentTime, coursesCache
    }

    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)

        student = try values.decode(Student.self, forKey: .student)
        loggedIn = try values.decode(Optional<Auth>.self, forKey: .loggedIn)
        currentTime = try values.decode(CurrentTime.self, forKey: .currentTime)
        coursesCache = try values.decode([String: [Course]].self, forKey: .coursesCache)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)

        try container.encode(student, forKey: .student)
        try container.encode(loggedIn, forKey: .loggedIn)
        try container.encode(currentTime, forKey: .currentTime)
        try container.encode(coursesCache, forKey: .coursesCache)
    }

    // MARK: - init

    /// 初始化客户端
    /// - Parameter student: 学生实例
    init(student: Student) {
        self.student = student

        loggedIn = nil

        currentTime = .init(from: nil)
        currentTime.outOfDate()

        coursesCache = [:]
    }

    // MARK: - Auth Publisher

    /// 从本地缓存（`self.loggedIn`）发布 Auth
    ///
    /// - Attention: 在使用前保证 `self.loggedIn != nil`
    private func authPublisherFromCache() -> AnyPublisher<Auth, AppError> {
        return Just(loggedIn ?? .init(userrealname: nil, token: "sdfsdf", userdwmc: nil))
            .print("[authPublisher.cache]")
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    /// 从 QzAPI 请求获取 Auth，成功时刷新本地缓存（`self.loggedIn`）
    private func authPublisherFromQzAPI() -> AnyPublisher<Auth, AppError> {
        return QzAPI.AuthUser(
            school: student.school,
            xh: student.sid,
            pwd: student.password
        ).publisher
            .print("[authPublisher.QzAPI]")
            .mapError { _ in AppError.networkError }
            .map { auth in // 缓存 auth
                self.loggedIn = auth
                return auth
            }
            .eraseToAnyPublisher()
    }

    /// A Publisher to get Auth from local cache (`self.loggedIn`) or requesting QzAPI
    var authPublisher: AnyPublisher<Auth, AppError> {
        print("authPublisher")
        loggedInMutex.lock()
        defer {
            self.loggedInMutex.unlock()
        }

        return Just(loggedIn)
            .setFailureType(to: AppError.self)
            .flatMap { logged -> AnyPublisher<Auth, AppError> in
                if logged != nil {
                    return self.authPublisherFromCache()
                }
                // else: not yet logged in
                return self.authPublisherFromQzAPI()
            }
            .tryMap { auth -> Auth in
                if auth.token == "-1" { // token == "-1" 是教务系统响应的账户错误
                    throw AppError.userAuthFailed
                }
                return auth
            }.mapError { err -> AppError in // 错误了，清除缓存
                self.loggedInMutex.lock()
                defer {
                    self.loggedInMutex.unlock()
                }
                self.loggedIn = nil

                return err as! AppError
            }
            .eraseToAnyPublisher()
    }

    // MARK: - CurrentTime Publisher

    /// 从给定的 auth (获取 token 以) 请求 QzAPI.GetCurrentTime
    private func currentPublisherWith(auth: Auth) -> AnyPublisher<CurrentTime.CurrentTimeEntry, Error> {
        currentTimeMutex.lock()
        defer {
            self.currentTimeMutex.unlock()
        }
        guard let current = currentTime.getWithCheck() else {
            // 缓存不可用
            let dateFormatter = DateFormatter()
            dateFormatter.dateFormat = "YYYY-MM-DD"

            // 现在的时间日期
            #if DEBUG
                // sometime in a school term: 2020年11月10日 星期二 17时20分00秒 CST
                let now: Date = Date(timeIntervalSince1970: 1605000000)
            #else
                let now: Date = Date() // real NOW
            #endif

            return QzAPI.GetCurrentTime(school: student.school,
                                        token: auth.token,
                                        currDate: dateFormatter.string(from: now)
            ).publisher
                .map { resp in
                    self.currentTime = .init(from: resp) // 写缓存
                    return resp
                }
                .print("[currentTime.QzAPI]")
                .eraseToAnyPublisher()
        }
        // 直接用缓存
        return Just(current)
            .setFailureType(to: Error.self)
            .print("[currentTime.cahce]")
            .eraseToAnyPublisher()
    }

    /// A publisher for getting CurrentTime (学年学期、周次) from QZ JWXT.
    var currentPublisher: AnyPublisher<CurrentTime.CurrentTimeEntry, AppError> {
        print("currentPublisher")
        return authPublisher
            .flatMap { auth in
                self.currentPublisherWith(auth: auth)
                    .mapError { _ in AppError.unexpectedError }
            }
//            .mapError { err -> AppError in
//                if err.se is AppError {
//                    return err
//                }
//                return AppError.networkError
//            }
            .tryMap { current in
                if current.zc == nil {
                    self.currentTimeMutex.lock()
                    defer {
                        self.currentTimeMutex.unlock()
                    }
                    self.currentTime.outOfDate()
                    throw AppError.notInSchoolTerm
                }
                return current
            }
            // 可能是 token 过期，重试登陆，再试一次
            .mapError { err in
                self.loggedInMutex.lock()
                defer {
                    self.loggedInMutex.unlock()
                }
                self.loggedIn = nil

                return err as! AppError
            }
            .retry(1)
            .eraseToAnyPublisher()
    }

    // MARK: - Courses Publisher

    /// 给定周次的课表查询，从本地缓存获取
    ///
    /// - Parameter week: 周次。调用前必须保证 week in self.coursesCache
    private func coursesFromCacheAt(week: Int?, schoolTerm: String?) -> AnyPublisher<[Course], AppError> {
        return Just(getCoursesCache(schoolTerm: schoolTerm, week: week) ?? [])
            .setFailureType(to: AppError.self)
            .eraseToAnyPublisher()
    }

    /// 给定周次的课表查询，从网络请求，并写入缓存
    /// - Parameter week: 周次
    private func coursesFromQzAt(week: Int?, schoolTerm: String?, with auth: Auth) -> AnyPublisher<[Course], AppError> {
        return QzAPI.GetKbcxAzc(school: student.school,
                                token: auth.token,
                                xh: student.sid,
                                xnxqid: schoolTerm ?? "",
                                zc: week?.description ?? ""
        ).publisher
            .map { respItems in
                let courses = respItems.map { Course(from: $0) }

                self.setCoursesCache( // 写缓存
                    schoolTerm: schoolTerm,
                    week: week,
                    courses: courses
                )

                return courses
            }
            .mapError { _ -> AppError in AppError.networkError }
            .eraseToAnyPublisher()
    }

    /// 获取某学期、某周次的课程
    /// - Parameter week: 要查询的周次
    /// - Parameter schoolTerm: 学年学期号。e.g. "2020-2021-1"
    func coursesAt(week: Int?, schoolTerm: String?) -> AnyPublisher<[Course], AppError> {
        print("courseAt")

        if getCoursesCache(schoolTerm: schoolTerm, week: week) != nil {
            return coursesFromCacheAt(week: week, schoolTerm: schoolTerm)
        }
        // 缓存未命中
        return authPublisher
            .flatMap { auth -> AnyPublisher<[Course], AppError> in
                self.coursesFromQzAt(week: week, schoolTerm: schoolTerm, with: auth)
            }
            .eraseToAnyPublisher()
    }

    // MARK: - 🚮 Discarded

    // TODO: Remove those discarded stuff

    /// 客户端错误
    ///
    /// 客户端出错：网络/账户错误，导致无法维护 token。
    /// - Attention:  🚮 弃用：
    /// 不再需要 error：基于 Combine，QzClient 被设计为完全（异步）响应式的，错误直接由 Publisher 发布 Failure。
    var error: AppError?

    /// QzClient 可能处于的几种状态
    ///
    /// 只有在 logined 才可以做其他操作
    /// - Attention: 🚮 弃用：用 token: String? 即可判断状态
    enum Status {
        case notLogin, logining, logined
    }
}

// MARK: - define Auth

extension QzClient {
    /// 登陆信息，其中包括 token
    typealias Auth = QzAPI.AuthUser.Response
}

// MARK: - define CurrentTime

extension QzClient {
    /// 教务系统获取的当前时间缓存
    struct CurrentTime: Codable {
        /** 教务系统 GetCurrentTime 的结果

            {
                "zc":20, //当前周次
                "e_time":"2019-01-20", //本周结束时间
                "s_time":"2019-01-14", //本周开始时间
                "xnxqh":"2018-2019-1" //学年学期名称
            }
         */
        typealias CurrentTimeEntry = QzAPI.GetCurrentTime.Response

        private var currentTime: CurrentTimeEntry?
        private var update: Date?

        /// Get CurrentTimeEntry with checking whether it's out of date
        ///
        /// If currentTime is NOT updated, returns nil
        mutating func getWithCheck() -> CurrentTimeEntry? {
            guard let update = self.update else {
                return nil
            }
            if update.isSameWeek(date: .init()) { // 和现在在同一周
                return currentTime
            }
            currentTime = nil
            return nil
        }

        /// - Parameter currentTime: a `CurrentTimeEntry` (aka `QzAPI.GetCurrentTime.Response`) from jwxt.
        init(from currentTime: CurrentTimeEntry?) {
            self.currentTime = currentTime
            update = Date()
        }

        /// 标记当前值过期了
        mutating func outOfDate() {
            currentTime = nil
            update = nil
        }
    }
}

// MARK: - CoursesCache getter and setter

extension QzClient {
    /// 从 coursesCache 读取指定学期、周次的课表缓存
    ///
    /// 内部有处理锁🔒，外部调用时不要上 coursesCacheMutex！！！
    /// - Parameters:
    ///   - schoolTerm: 学年学期号
    ///   - week: 周次
    /// - Returns: 课程列表
    private func getCoursesCache(schoolTerm: String?, week: Int?) -> [Course]? {
        coursesCacheMutex.lock()
        defer {
            self.coursesCacheMutex.unlock()
        }
        return coursesCache["\(schoolTerm ?? "nil")-\(week ?? .min)"]
    }

    /// 将指定学期、周次的课表缓存写入 coursesCache
    ///
    /// 内部有处理锁🔒，外部调用时不要上 coursesCacheMutex！！！
    /// - Parameters:
    ///   - schoolTerm: 学年学期号
    ///   - week: 周次
    ///   - courses: 课程列表
    private func setCoursesCache(schoolTerm: String?, week: Int?, courses: [Course]) {
        coursesCacheMutex.lock()
        defer {
            self.coursesCacheMutex.unlock()
        }
        coursesCache["\(schoolTerm ?? "nil")-\(week ?? .min)"] = courses
    }
}
