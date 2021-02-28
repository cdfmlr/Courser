//
//  Store.swift
//  Courser
//
//  Created by c on 2021/2/25.
//

import Combine
import Foundation

class Store: ObservableObject {
    @Published var appState = AppState()

    /// 用来保持 AnyCancellable 的数组
    var disposeBag = [AnyCancellable]()

    init() {
        autoLogin()
        updateCurrent()

        setupObservers()
    }

    private func autoLogin() {
        guard let client = appState.client else {
            return
        }
        client.authPublisher
            .receive(on: DispatchQueue.main)
            .sink(receiveCompletion: { _ in }, receiveValue: { auth in
                self.appState.settings.model.account = .init(
                    from: client.student
                )
                self.appState.settings.loginUser = auth
            }).store(in: &disposeBag)
    }

    /// Update current time, courseTab, and courseDaily
    private func updateCurrent() {
        guard let client = appState.client else {
            return
        }
        client.currentPublisher
            .receive(on: DispatchQueue.main)
            .sink(
                receiveCompletion: { _ in },
                receiveValue: { current in
                    print(current)
                    self.appState.current = current
                    client.coursesAt(
                        week: current.zc,
                        schoolTerm: current.xnxqh
                    )
                    .map { courses in
                        courses.map { CourseViewModel(course: $0) }
                    }
                    .sink(
                        receiveCompletion: { _ in },
                        receiveValue: { models in
                            let weekday = Date().weekday

                            self.appState.courseTable.model = .init(
                                week: current.zc ?? 0,
                                today: weekday,
                                from: models
                            )

                            self.appState.courseDaily.model = .init(
                                week: current.zc ?? 0,
                                weekday: weekday,
                                from: models
                            )
                        }
                    ).store(in: &self.disposeBag)
                }
            ).store(in: &disposeBag)
    }

    func setupObservers() {
        // TODO:
    }

    static func reduce(state: AppState, action: AppAction) -> (state: AppState, command: AppCommand?) {
        var appState = state
        var appCommand: AppCommand?

        switch action {
        case let .login(student: student):
            guard !appState.settings.logining else {
                break
            }
            appState.settings.logining = true

            appCommand = LoginAppCommand(student: student)
        case let .loginDone(result: result):
            appState.settings.logining = false
            switch result {
            case let .success(client):
                appState.client = client
                appState.settings.loginUser = client.loggedIn
            case let .failure(error):
                print("error: \(error)")
                appState.settings.loginError = error
            }
        }
        return (appState, appCommand)
    }

    /// 给 View 调用的用于表示发送了某个 Action 的方法:
    /// 将当前 AppState 和收到的 Action 交给 reduce，然后把返回的 state 设置为新的状态。
    func dispatch(_ action: AppAction) {
        #if DEBUG
            print("[dispatch] action: \(action)")
        #endif

        let result = Store.reduce(state: appState, action: action)

        appState = result.state

        if let command = result.command {
            #if DEBUG
                print("[dispatch] command: \(command)")
            #endif

            command.execute(in: self)
        }
    }
}
