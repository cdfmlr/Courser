//
//  FileHelper.swift
//  Courser
//
//  Created by c on 2021/2/5.
//

import Foundation

/// 提供一系列读写 JSON 的方法
enum FileHelper {

    /// 读资源文件（Bundle）
    static func loadBundledJSON<T: Decodable>(file: String) -> T {
        guard let url = Bundle.main.url(forResource: file, withExtension: "json") else {
            fatalError("Resource not found: \(file)")
        }
        return try! loadJSON(from: url)
    }

    static func loadJSON<T: Decodable>(from url: URL) throws -> T {
        let data = try Data(contentsOf: url)
        return try appDecoder.decode(T.self, from: data)
    }

    static func loadJSON<T: Decodable>(
        from directory: FileManager.SearchPathDirectory,
        fileName: String
    ) throws -> T
    {
        let url = FileManager.default.urls(for: directory, in: .userDomainMask).first!
        return try loadJSON(from: url.appendingPathComponent(fileName))
    }

    static func writeJSON<T: Encodable>(_ value: T, to url: URL) throws {
        let data = try appEncoder.encode(value)
        try data.write(to: url)
    }

    static func writeJSON<T: Encodable>(
        _ value: T,
        to directory: FileManager.SearchPathDirectory,
        fileName: String
    ) throws
    {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        try writeJSON(value, to: url.appendingPathComponent(fileName))
    }

    static func delete(
        from directory: FileManager.SearchPathDirectory,
        fileName: String) throws
    {
        guard let url = FileManager.default.urls(for: directory, in: .userDomainMask).first else {
            return
        }
        try FileManager.default.removeItem(at: url.appendingPathComponent(fileName))
    }
}
