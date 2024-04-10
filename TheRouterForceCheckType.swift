//
//  TheRouterForceCheckType.swift
//  TheRouter
//
//  Created by season on 2024/4/10.
//

import Foundation

/// 这里其实需要考虑如何将CustomRouterInfo与StaticRouterInfoConvertible合成一个协议
public protocol StaticRouterInfoConvertible {
    var patternString: String { get }
    var routerClass: String { get }
    var params: [String: Any] { get }
    var jumpType: LAJumpType { get }
}

extension StaticRouterInfoConvertible {
    public var requiredURL: (String, [String: Any]) {
        return TheRouter.generate(patternString, params: params, jumpType: jumpType)
    }
}

/// 这里是一个具体遵守StaticRouterInfoConvertible协议的结构体
public struct StaticRouterInfo: StaticRouterInfoConvertible {
    public let patternString: String
    public let routerClass: String
    public let params: [String: Any]
    public let jumpType: LAJumpType
    
    public init(patternString: String, routerClass: String, params: [String : Any], jumpType: LAJumpType) {
        self.patternString = patternString
        self.routerClass = routerClass
        self.params = params
        self.jumpType = jumpType
    }
}

public enum TheRouterForceCheckType {
    /// 通过运行时进行检查
    case runtime
    
    /// 通过路由表进行静态检查
    case staticWithRoutingList([StaticRouterInfoConvertible])
}
