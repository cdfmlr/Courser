//
//  Regex.swift
//  Courser
//
//  Created by c on 2021/2/7.
//

import Foundation

/** 基于NSRegularExpression api 的正则处理工具类

 From: https://www.hangge.com/blog/cache/detail_2170.html

 # Usage

 - 验证字符串格式
 
 ```
 //初始化正则工具类
 let pattern = "^([a-z0-9_\\.-]+)@([\\da-z\\.-]+)\\.([a-z\\.]{2,6})$"
 let regex = try! Regex(pattern)
  
 //验证邮箱地址
 let mailAddress = "admin@hangge.com"
 if regex.matches(mailAddress) {
     print("邮箱地址格式正确")
 }else{
     print("邮箱地址格式有误")
 }
 ```
 
 - 提取字符串
 
 ```
 //初始化正则工具类
 let pattern = "([\\u4e00-\\u9fa5]+):([\\d]+)"
 let regex = try! Regex(pattern)
  
 //原始字符串
 let str = "王大锤:123456,李子明:23457,李洛克:110"
  
 // 获取所有的匹配结果
 for match in regex.matches(in: str) {
     print("\n--- 匹配结果  ---")
     print(match)
     print("匹配字符串：", match.string)
     print("捕获组：", match.captures[0]!, match.captures[1]!)
     print("匹配范围：", match.range)
 }
 
 // 获取第一个匹配对象
 let first = regex.firstMatch(in: str)
 ```
 
 - 字符串替换
 
 1) 简单的替换
 
 ```
 //初始化正则工具类
 let pattern = "([\\u4e00-\\u9fa5]+):([\\d]+)"
 let regex = try! Regex(pattern)
  
 //原始字符串
 let str = "王大锤:123456,李子明:23457,李洛克:110"
  
 //只替换第1个匹配项
 let out1 = regex.replacingMatches(in: str, with: "***", count: 1)
 //替换所有匹配项
 let out2 = regex.replacingMatches(in: str, with: "***")
    
 //输出结果
 print("原始的字符串：", str)
 print("替换第1个匹配项：", out1)
 print("替换所有匹配项：", out2)
 ```

 2) 捕获组替换
 
 ```
 //初始化正则工具类
 let pattern = "([\\u4e00-\\u9fa5]+):([\\d]+)"
 let regex = try! Regex(pattern)
  
 //原始字符串
 let str = "王大锤:123456,李子明:23457,李洛克:110"
  
 //只替换第1个匹配项
 let out1 = regex.replacingMatches(in: str, with: "$1的电话是$2", count: 1)
 //替换所有匹配项
 let out2 = regex.replacingMatches(in: str, with: "$1的电话是$2")
    
 //输出结果
 print("原始的字符串：", str)
 print("替换第1个匹配项：", out1)
 print("替换所有匹配项：", out2)
 ```
 */
public struct Regex {
    private let regularExpression: NSRegularExpression

    /// 使用正则表达式进行初始化
    public init(_ pattern: String, options: Options = []) throws {
        regularExpression = try NSRegularExpression(
            pattern: pattern,
            options: options.toNSRegularExpressionOptions
        )
    }

    /// 正则匹配验证（true表示匹配成功）
    public func matches(_ string: String) -> Bool {
        return firstMatch(in: string) != nil
    }

    /// 获取第一个匹配结果
    public func firstMatch(in string: String) -> Match? {
        let firstMatch = regularExpression
            .firstMatch(in: string, options: [],
                        range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return firstMatch
    }

    /// 获取所有的匹配结果
    public func matches(in string: String) -> [Match] {
        let matches = regularExpression
            .matches(in: string, options: [],
                     range: NSRange(location: 0, length: string.utf16.count))
            .map { Match(result: $0, in: string) }
        return matches
    }

    /// 正则替换
    public func replacingMatches(in input: String, with template: String,
                                 count: Int? = nil) -> String {
        var output = input
        let matches = self.matches(in: input)
        let rangedMatches = Array(matches[0 ..< min(matches.count, count ?? .max)])
        for match in rangedMatches.reversed() {
            let replacement = match.string(applyingTemplate: template)
            output.replaceSubrange(match.range, with: replacement)
        }

        return output
    }
}

// 正则匹配可选项
extension Regex {
    /// Options 定义了正则表达式匹配时的行为
    public struct Options: OptionSet {
        /// 忽略字母
        public static let ignoreCase = Options(rawValue: 1)

        /// 忽略元字符
        public static let ignoreMetacharacters = Options(rawValue: 1 << 1)

        /// 默认情况下,“^”匹配字符串的开始和结束的“$”匹配字符串,无视任何换行。
        /// 使用这个配置，“^”将匹配的每一行的开始,和“$”将匹配的每一行的结束。
        public static let anchorsMatchLines = Options(rawValue: 1 << 2)

        /// 默认情况下,"."匹配除换行符(\n)之外的所有字符。使用这个配置，选项将允许“.”匹配换行符
        public static let dotMatchesLineSeparators = Options(rawValue: 1 << 3)

        /// OptionSet的 raw value
        public let rawValue: Int

        /// 将Regex.Options 转换成对应的 NSRegularExpression.Options
        var toNSRegularExpressionOptions: NSRegularExpression.Options {
            var options = NSRegularExpression.Options()
            if contains(.ignoreCase) { options.insert(.caseInsensitive) }
            if contains(.ignoreMetacharacters) {
                options.insert(.ignoreMetacharacters)
            }
            if contains(.anchorsMatchLines) { options.insert(.anchorsMatchLines) }
            if contains(.dotMatchesLineSeparators) {
                options.insert(.dotMatchesLineSeparators)
            }
            return options
        }

        /// OptionSet 初始化
        public init(rawValue: Int) {
            self.rawValue = rawValue
        }
    }
}

// 正则匹配结果
extension Regex {
    /// Match 封装有单个匹配结果
    public class Match: CustomStringConvertible {
        /// 匹配的字符串
        public lazy var string: String = {
            String(describing: self.baseString[self.range])
        }()

        /// 匹配的字符范围
        public lazy var range: Range<String.Index> = {
            Range(self.result.range, in: self.baseString)!
        }()

        /// 正则表达式中每个捕获组匹配的字符串
        public lazy var captures: [String?] = {
            let captureRanges = stride(from: 0, to: result.numberOfRanges, by: 1)
                .map(result.range)
                .dropFirst()
                .map { [unowned self] in
                    Range($0, in: self.baseString)
                }

            return captureRanges.map { [unowned self] captureRange in
                if let captureRange = captureRange {
                    return String(describing: self.baseString[captureRange])
                }

                return nil
            }
        }()

        private let result: NSTextCheckingResult

        private let baseString: String

        /// 初始化
        internal init(result: NSTextCheckingResult, in string: String) {
            precondition(
                result.regularExpression != nil,
                "NSTextCheckingResult必需使用正则表达式"
            )

            self.result = result
            baseString = string
        }

        /// 返回一个新字符串，根据“模板”替换匹配的字符串。
        public func string(applyingTemplate template: String) -> String {
            let replacement = result.regularExpression!.replacementString(
                for: result,
                in: baseString,
                offset: 0,
                template: template
            )

            return replacement
        }

        /// 藐视信息
        public var description: String {
            return "Match<\"\(string)\">"
        }
    }
}
