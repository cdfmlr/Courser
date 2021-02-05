//
//  QzAPI.swift
//  Courser
//
//  Created by c on 2021/2/2.
//

import Combine
import Foundation

/// 强智教务系统 API
enum QzAPI {
    /**
     登录帐号

     ## 请求
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=authUser&xh={$学号}&pwd={$密码}
     ```

     ## 参数
     ```json
     {
         "method":'authUser',  //必填
         "xh":'登陆教务系统使用的学号',  //必填
         "pwd":'登陆教务系统需要的密码'  //必填
     }
     ```

     ## 返回
     ``` json
     {
         "flag":"1", //是否成功 #成功1 失败0
         "userrealname":"张三", //用户真实姓名 #失败 null
         "token":"", //令牌 #失败 -1
         "userdwmc":"XXXX学院", //用户所在学院名称 #失败 null
         "usertype":"2", //用户类别 #已知学生身份为2 失败 null
         "msg":"登录成功" //返回消息
     }
     ```

     ## 例程
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=authUser&xh=17111111&pwd=1234578

     ```
     */
    struct AuthUser {
        /// 学校: xxxx.edu.cn 的 xxxx
        let school: String
        /// 登陆教务系统使用的学号
        let xh: String
        /// 登陆教务系统需要的密码
        let pwd: String

        /**
         ``` json
         {
             "flag":"1", //是否成功 #成功1 失败0
             "userrealname":"张三", //用户真实姓名 #失败 null
             "token":"", //令牌 #失败 -1
             "userdwmc":"XXXX学院", //用户所在学院名称 #失败 null
             "usertype":"2", //用户类别 #已知学生身份为2 失败 null
             "msg":"登录成功" //返回消息
         }
         ```
         */
        struct Response: Codable {
            /// 是否成功 #成功"1", 失败"0"
//            var flag: String?

            /// 用户真实姓名 #失败 null
            var userrealname: String?
            /// 令牌 #失败 -1
            var token: String
            /// 用户所在学院名称 #失败 null
            var userdwmc: String?

            /// 用户类别 #已知学生身份为"2" 失败 null
//            var usertype: String?

            /// 返回消息: "登录成功"
//            var msg: String?
        }

        var request: URL {
            URL(string:
                "http://jwxt.\(school).edu.cn/app.do?method=authUser&xh=\(xh)&pwd=\(pwd)")!
        }

        var publisher: AnyPublisher<Response, Error> {
            URLSession.shared.dataTaskPublisher(
                for: request
            )
            .map { $0.data }
            .decode(type: Response.self, decoder: appDecoder)
            .eraseToAnyPublisher()
        }
    }

    /**
     时间信息

     获取所提交的日期的时间、周次、学年等信息

     ## 请求
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=getCurrentTime&currDate={$查询日期}
     ```

     ## 参数
     ```js
     request.header{token:'运行身份验证authUser时获取到的token，有过期机制'},
     request.data{
         'method':'getCurrentTime',  //必填
         'currDate':  //格式为"YYYY-MM-DD"，必填，留空调用成功，但返回值均为null
     }
     ```

     ## 返回
     ```json
     {
         "zc":20, //当前周次
         "e_time":"2019-01-20", //本周结束时间
         "s_time":"2019-01-14", //本周开始时间
         "xnxqh":"2018-2019-1" //学年学期名称
     }
     ```

     ## 例程
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=getCurrentTime&currDate=2019-01-14
     ```
     */
    struct GetCurrentTime {
        /// 学校: xxxx.edu.cn 的 xxxx
        let school: String
        /// 运行身份验证authUser时获取到的token，有过期机制
        let token: String
        /// 查询日期: 格式为"YYYY-MM-DD"，必填。留空调用成功，但返回值均为null
        let currDate: String

        var request: URLRequest {
            let url = URL(string:
                "http://jwxt.\(school).edu.cn/app.do?method=getCurrentTime&currDate=\(currDate)")!
            var req = URLRequest(url: url)
            req.addValue(token, forHTTPHeaderField: "token")
            return req
        }

        /**
         ```json
         {
             "zc":20, //当前周次
             "e_time":"2019-01-20", //本周结束时间
             "s_time":"2019-01-14", //本周开始时间
             "xnxqh":"2018-2019-1" //学年学期名称
         }
         ```
         */
        struct Response: Codable {
            /// 当前周次: 13, nil 可能是假期，不在学期内
            let zc: Int?
            /// 本周开始时间: "2019-01-14"
            let sTime: String?
            /// 本周结束时间: "2019-01-20"
            let eTime: String?
            /// 学年学期名称: "2018-2019-1", nil 可能是假期，不在学期内
            let xnxqh: String?

            // decoder.keyDecodingStrategy = .convertFromSnakeCase
//            enum CodingKeys: String, CodingKey {
//                case zc
//                case sTime = "s_time"
//                case eTime = "e_time"
//                case xnxqh
//            }
        }

        var publisher: AnyPublisher<Response, Error> {
            URLSession.shared.dataTaskPublisher(
                for: request
            )
            .map { $0.data }
            .decode(type: Response.self, decoder: appDecoder)
            .eraseToAnyPublisher()
        }
    }

    /**
     课程信息

     获取一周的课程信息

     ## 请求
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=getKbcxAzc&xh={$学号}&xnxqid={$学年学期ID}&zc={$周次}
     ```

     ## 参数
     ```js
     request.header{token:'运行身份验证authUser时获取到的token，有过期机制'},
     request.data{
         'method':'getKbcxAzc',  //必填
         'xh':'2017168xxxxx',  //必填，使用与获取token时不同的学号，则可以获取到新输入的学号的课表
         'xnxqid':'2018-2019-1',  //格式为"YYYY-YYYY-X"，非必填，不包含时返回当前日期所在学期课表
         'zc':'1'  //必填
     }
     ```

     ## 返回
     ``` json
     [
         {
             "jsxm":"张三", //教师姓名
             "jsmc":"教学楼101", //教室名称
             "jssj":"10:00", //结束时间
             "kssj":"08:00", //开始时间
             "kkzc":"1", //开课周次，有三种已知格式1)a-b、2)a,b,c、3)a-b,c-d
             "kcsj":"10506", //课程时间，格式x0a0b，意为星期x的第a,b节上课
             "kcmc":"大学英语", //课程名称
             "sjbz":"0" //具体意义未知，据观察值为1时本课单周上，2时双周上
         },{
             "jsxm":"李四",
             "jsmc":"教学楼101",
             "jssj":"12:00",
             "kssj":"10:00",
             "kkzc":"1",
             "kcsj":"1000000",
             "kcmc":"微积分",
             "sjbz":"0"
         }
     ]
     ```

     ## 例程
     ``` url
     GET http://jwxt.xxxx.edu.cn/app.do?method=getKbcxAzc&xh=101010000&xnxqid=2018-2019-1&zc=5
     ```
     */
    struct GetKbcxAzc {
        /// 学校: xxxx.edu.cn 的 xxxx
        let school: String
        /// 运行身份验证authUser时获取到的token，有过期机制
        let token: String
        /// 学号
        let xh: String
        /// 学年学期名称: "2018-2019-1"
        let xnxqid: String
        /// 周次
        let zc: String

        var request: URLRequest {
            let url = URL(string:
                "http://jwxt.\(school).edu.cn/app.do?method=getKbcxAzc&xh=\(xh)&xnxqid=\(xnxqid)&zc=\(zc)")!
            var req = URLRequest(url: url)
            req.addValue(token, forHTTPHeaderField: "token")
            return req
        }

        struct ResponseItem: Codable {
            /// 教师姓名
            ///
            /// e.g.
            ///   "张三"
            let jsxm: String
            /// 教室名称
            ///
            /// e.g.
            ///   "教学楼101"
            let jsmc: String
            /// 结束时间
            ///
            /// e.g.
            ///   "10:00"
            let jssj: String
            /// 开始时间
            ///
            /// e.g.
            ///   "08:00"
            let kssj: String
            /// 开课周次，有三种已知格式1)a-b、2)a,b,c、3)a-b,c-d
            ///
            /// e.g.
            ///   "1"
            let kkzc: String
            /// 课程时间，格式x0a0b，意为星期x的第a,b节上课
            ///
            /// e.g.
            ///   "10506"
            let kcsj: String
            /// 课程名称
            /// e.g.
            ///   "大学英语"
            let kcmc: String
            /// 具体意义未知，据观察值为1时本课单周上，2时双周上
            ///
            /// e.g.
            ///   "0"
            let sjbz: String?
        }

        var publisher: AnyPublisher<[ResponseItem], Error> {
            URLSession.shared.dataTaskPublisher(
                for: request
            )
            .map { $0.data }
            .decode(type: [ResponseItem].self, decoder: appDecoder)
            .eraseToAnyPublisher()
        }
    }
}

/**** DEBUG **/

// let resp = QzAPI.GetCurrentTime.Response(zc: 12, sTime: "2020-11-30", eTime: "2020-12-06", xnxqh: "2020-2021-1")
//
// let data = try! appEncoder.encode(resp)
// let encodedString = String(data: data, encoding: .utf8)!
//
////let data = """
////{"zc":14,"e_time":"2020-12-06","s_time":"2020-11-30","xnxqh":"2020-2021-1"}
////""".data(using: .utf8)!
//
// let decoded = try? appDecoder.decode(QzAPI.GetCurrentTime.Response.self, from: data)

/**** TEST **/

// QzAPI.AuthUser(school: "ncepu", xh: "201810000507", pwd: "hd160016")
//    .publisher
//    .print()
//    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

// QzAPI.GetCurrentTime(school: "ncepu",
//                     token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTI0MTk0MDIsImF1ZCI6IjIwMTgxMDAwMDUwNyJ9.ZAsqIjAeHb_Vb8NEwB9IIuw5F7BmZde8WrWe3lTF76g",
//                     currDate: "2020-12-03")
//    .publisher
//    .print()
//    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

// QzAPI.GetKbcxAzc(school: "ncepu",
//                 token: "eyJ0eXAiOiJKV1QiLCJhbGciOiJIUzI1NiJ9.eyJleHAiOjE2MTI0MTk0MDIsImF1ZCI6IjIwMTgxMDAwMDUwNyJ9.ZAsqIjAeHb_Vb8NEwB9IIuw5F7BmZde8WrWe3lTF76g",
//                 xh: "201810000502", xnxqid: "2020-2021-1", zc: "12")
//    .publisher
//    .print()
//    .sink(receiveCompletion: { _ in }, receiveValue: { _ in })

// sleep(30)
