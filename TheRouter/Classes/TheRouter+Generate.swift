//
//  TheRouter+Generate.swift
//  TheRouter
//
//  Created by mars.yao on 2021/11/29.
//

import Foundation
import UIKit

// MARK: - Constants
// 跳转类型Key
public let LAJumpTypeKey = "jumpType"
// 第一个参数Key
public let TheRouterIvar1Key = "ivar1"
// 第二个参数Key
public let TheRouterIvar2Key = "ivar2"
// 返回值类型Key
public let TheRouterFunctionResultKey = "resultType"
// 路由Path常量Key
public let TheRouterPath = "path"
// 路由class常量Key
public let TheRouterClassName = "class"
//路由priority常量Key
public let TheRouterPriority = "priority"
// tabBar选中参数 tabBarSelecIndex
public let TheRouterTabBarSelecIndex = "tabBarSelecIndex"


//路由优先级默认值
public let TheRouterDefaultPriority: UInt = 1000

public typealias ComplateHandler = (([String: Any]?, Any?) -> Void)?

// constants
public extension TheRouter {
    static let patternKey = "patternKey"
    static let requestURLKey = "requestURLKey"
    static let matchFailedKey = "matchFailedKey"
    static let urlKey = "url"
    static let userInfoKey = "userInfo"
}

// 跳转方式
@objc public enum LAJumpType: Int {
    case modal
    case push
    case popToTaget
    case windowNavRoot
    case modalDismissBeforePush
    case showTab
}

public struct RouteItem {
    
    public var path: String = ""
    public var className: String = ""
    public var action: String = ""
    public var descriptions: String = ""
    public var params: [String: Any] = [:]
    
    public init(path: String, className: String, action: String = "", descriptions: String = "", params: [String: Any] = [:]) {
        self.path = path
        self.className = className
        self.action = action
        self.descriptions = descriptions
        self.params = params
    }
}

// 动态路由调用方法返回类型
@objc public enum TheRouterFunctionResultType: Int {
    case voidType   // 无返回值类型
    case valueType  // 值类型
    case referenceType // 引用类型
}

/// 远端下发路由数据
@objc public enum TheRouterReloadMapEnum: Int {
    case none
    case replace
    case add
    case delete
    case reset
}

// 日志类型
@objc public enum TheRouterLogType: Int {
    case logNormal
    case logError
}

public extension URL {
    var urlParameters: [String: String]? {
        guard let components = URLComponents(url: self, resolvingAgainstBaseURL: true),
              let queryItems = components.queryItems else { return nil }
        return queryItems.reduce(into: [String: String]()) { (result, item) in
            result[item.name] = item.value
        }
    }
}

extension TheRouter {
    
    // MARK: - Convenience method
    public class func generate(_ patternString: String, params: [String: Any] = [String: Any](), jumpType: LAJumpType) -> (String, [String: Any]) {
        
        if let url = URL(string: patternString) {
            let orginParams = url.urlParameters ?? [String: Any]()
            var queries = params
            queries[LAJumpTypeKey] = "\(jumpType.rawValue)"
            
            for (key, value) in orginParams.reversed() {
                queries[key] = value
            }
            return (patternString, queries)
        }
        
        return ("", [String: Any]())
    }
    
}

public protocol CustomRouterInfo {
    static var patternString: String { get }
    static var routerClass: String { get }
    var params: [String: Any] { get }
    var jumpType: LAJumpType { get }
}

extension CustomRouterInfo {
    public var requiredURL: (String, [String: Any]) {
        return TheRouter.generate(Self.patternString, params: self.params, jumpType: self.jumpType)
    }
}

public struct TheRouterInfo: Decodable {
    public init() {}
    
    public var targetPath: String?
    public var orginPath: String?
    public var routerType: Int = 0 // 1: 表示替换或者修复客户端代码path错误 2: 新增路由path 3:删除路由 4: 重置路由
    public var path: String? // 新的路由地址
    public var className: String? // 路由地址对应的界面
    public var params: [String: Any]?
    
    enum CodingKeys: String, CodingKey {
        case targetPath
        case orginPath
        case path
        case className
        case routerType
        case params
    }
    
    public init(from decoder: Decoder) throws {
        
        let container = try decoder.container(keyedBy: CodingKeys.self)
        targetPath = try container.decodeIfPresent(String.self, forKey: CodingKeys.targetPath)
        orginPath = try container.decodeIfPresent(String.self, forKey: CodingKeys.orginPath)
        routerType = try container.decode(Int.self, forKey: CodingKeys.routerType)
        path = try container.decodeIfPresent(String.self, forKey: CodingKeys.path)
        className = try container.decodeIfPresent(String.self, forKey: CodingKeys.className)
        params = try container.decodeIfPresent(Dictionary<String, Any>.self, forKey: CodingKeys.params)
    }
}
