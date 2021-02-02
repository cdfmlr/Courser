//
//  CodableHelper.swift
//  Courser
//
//  Created by c on 2021/2/2.
//

import Foundation

/// 该 App 通用的解码器
let appDecoder: JSONDecoder = {
    let decoder = JSONDecoder()
    decoder.keyDecodingStrategy = .convertFromSnakeCase
    return decoder
}()

/// 该 App 通用的编码器
let appEncoder: JSONEncoder = {
    let encoder = JSONEncoder()
    encoder.keyEncodingStrategy = .convertToSnakeCase
    return encoder
}()
