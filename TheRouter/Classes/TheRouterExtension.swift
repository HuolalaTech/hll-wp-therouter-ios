//
//  LACommonExtension.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

public extension String {
    
    func containsSubString(substring: String) -> Bool {
        return range(of: substring) != nil
    }
    
    func la_dropFirst(_ count: Int) -> String {
        let start = self.index(startIndex, offsetBy: 0)
        let end = self.index(start, offsetBy: count)
        let results = self[start...end]
        return String(results)
    }
    
    func la_dropLast(_ count: Int) -> String {
        let start = self.index(endIndex, offsetBy: 0)
        let end = self.index(endIndex, offsetBy: -count)
        let results = self[start...end]
        return String(results)
    }
    
    func la_matchClass() -> AnyClass? {
        
        if let cls: AnyClass  = NSClassFromString(self) {
            return cls
        }
        return nil
    }
}

// MARK:- 一、基本的扩展
public extension Dictionary  {
    
    // MARK: 1.1、检查字典里面是否有某个 key
    /// 检查字典里面是否有某个 key
    func has(_ key: Key) -> Bool {
        return index(forKey: key) != nil
    }
    
    // MARK: 1.2、字典的key或者value组成的数组
    /// 字典的key或者value组成的数组
    /// - Parameter map: map
    /// - Returns: 数组
    func toArray<V>(_ map: (Key, Value) -> V) -> [V] {
        return self.map(map)
    }
    
    // MARK: 1.3、JSON字符串 -> 字典
    /// JsonString转为字典
    /// - Parameter json: JSON字符串
    /// - Returns: 字典
    static func jsonToDictionary(json: String) -> Dictionary<String, Any>? {
        if let data = (try? JSONSerialization.jsonObject(
            with: json.data(using: String.Encoding.utf8,
                            allowLossyConversion: true)!,
            options: JSONSerialization.ReadingOptions.mutableContainers)) as? Dictionary<String, Any> {
            return data
        } else {
            return nil
        }
    }
    
    // MARK: 1.4、字典 -> JSON字符串
    /// 字典转换为JSONString
    func toJSON() -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: self, options: JSONSerialization.WritingOptions()) {
            let jsonStr = String(data: jsonData, encoding: String.Encoding(rawValue: String.Encoding.utf8.rawValue))
            return String(jsonStr ?? "")
        }
        return nil
    }
    
    // MARK: 1.5、字典里面所有的 key
    /// 字典里面所有的key
    /// - Returns: key 数组
    func allKeys() -> [Key] {
        /*
         shuffled：不会改变原数组，返回一个新的随机化的数组。  可以用于let 数组
         */
        return self.keys.shuffled()
    }
    
    // MARK: 1.6、字典里面所有的 value
    /// 字典里面所有的value
    /// - Returns: value 数组
    func allValues() -> [Value] {
        return self.values.shuffled()
    }
    
    ///  MARK: 1.7、用于字典的合并
    mutating func merge(dic:Dictionary) {
        self.merge(dic) { (parama1, parama2) -> Value in
            return parama1
        }
    }
    
    mutating func la_combine(_ dict: Dictionary) {
        var tem = self
        dict.forEach({ (key, value) in
            if let existValue = tem[key] {
                // combine same name query
                if let arrValue = existValue as? [Value] {
                    tem[key] = (arrValue + [value]) as? Value
                } else {
                    tem[key] = ([existValue, value]) as? Value
                }
            } else {
                tem[key] = value
            }
        })
        self = tem
    }
}

