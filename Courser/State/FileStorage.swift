//
//  FileStorage.swift
//  Courser
//
//  Created by c on 2021/2/28.
//

import Foundation

/// 维护变量持久化到文件（用 JSON 编解码）
///
/// E.g. 自动维护登陆用户持久化储存：
///
/// ```
/// @FileStorage(directory: .documentDirectory, fileName: "user.json")
/// var loginUser: User?
/// ```
///
/// - 注：关于 `@propertyWrapper` 的理解：
/// 每个 @propertyWrapper 都必须实现一个 wrappedValue 属性,
/// 实现 wrappedValue 的 set get 就相当于替换掉原属性的 set get。
@propertyWrapper struct FileStorage<T: Codable> {
    var value: T?

    let directory: FileManager.SearchPathDirectory
    let fileName: String

    init(directory: FileManager.SearchPathDirectory, fileName: String) {
        self.directory = directory
        self.fileName = fileName

        value = try? FileHelper.loadJSON(
            from: directory,
            fileName: fileName
        )
    }

    var wrappedValue: T? {
        set {
            value = newValue
            if let value = newValue {
                try? FileHelper.writeJSON(value,
                                          to: directory,
                                          fileName: fileName)
            } else {
                try? FileHelper.delete(from: directory, fileName: fileName)
            }
        }
        
        get {
            value
        }
    }
}
