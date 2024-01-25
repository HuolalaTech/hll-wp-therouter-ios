//
//  TheRouterApi.swift
//  TheRouter-ObjectiveCDemo
//
//  Created by mars.yao on 2024/1/25.
//

import Foundation
import TheRouter

/**
 TheRouterApi 主要作用是做模块间解耦合，多个模块相互调用，抽出统一的Api，进行跨模块调用,为了保证线上稳定性，建议开启强制检查，会自动检测是否写错或者漏写，触发断言
 */

@objc public class TheRouterApi: NSObject, CustomRouterInfo {
    
    @objc public static var patternString = "scheme://router/objcDemo"
    public static var routerClass = "TheRouter_ObjectiveCDemo.TheRouterControllerSwift"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    // 这里没办法，OC不支持元组，只能拆开
    @objc public func generateParams() -> [String: Any] {
        return TheRouter.generate(Self.patternString, params: self.params, jumpType: self.jumpType).1
    }
    public override init() {}
}

public class TheRouterWebApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://webview/home"
    public static var routerClass = "TheRouter_ObjectiveCDemo.TheRouterWebController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}
