//
//  AppCommand.swift
//  Courser
//
//  Created by c on 2021/2/28.
//

import Combine
import Foundation

protocol AppCommand {
    /// 执行副作用的入口
    /// - Parameter store: 提供一个执行后续操作的上下文，
    /// 在副作用执行完毕时，发送新的 Action 来更改 app 状态。
    func execute(in store: Store)
}

/// 用来保持 AnyCancellable 的数组
var disposeBag = [AnyCancellable]()

struct LoginAppCommand: AppCommand {
    let student: Student

    func execute(in store: Store) {
        let client = QzClient(student: student)

        client.authPublisher
            .receive(on: DispatchQueue.main) 
            .sink(receiveCompletion: { complete in
                if case let .failure(error) = complete {
                    store.dispatch(
                        .loginDone(result: .failure(error))
                    )
                }
            }, receiveValue: { _ in
                store.dispatch(
                    .loginDone(result: .success(client))
                )
            })
            .store(in: &disposeBag)
        
    }
}
