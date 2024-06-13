//
//  TheRouterApi.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/7/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter

/**
 TheRouterApi 主要作用是做模块间解耦合，多个模块相互调用，抽出统一的Api，进行跨模块调用
 */

public class TheRouterApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo"
    public static var routerClass = "TheRouter_Example.TheRouterController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterTabApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/tabbar"
    public static var routerClass = "TheRouterTabBarController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .showTab
    
    public override init() {}
}


public class TheRouterAApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo1"
    public static var routerClass = "TheRouter_Example.TheRouterControllerA"
    public var params: [String: Any] { return ["dynamic": "value is dynamic"] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterBApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo2"
    public static var routerClass = "TheRouterBController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterBaseAApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/baseA"
    public static var routerClass = "TheRouterBaseAViewController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterBaseBApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/baseB"
    public static var routerClass = "TheRouterBaseBViewController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}


public class TheRouterCApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo33"
    public static var routerClass = "TheRouter_Example.TheRouterControllerC"
    public var params: [String: Any] { return ["desc":"如果直接调用TheRouterCApi进行路由跳转，此时路由地址demo33是错误的，无法进行跳转，触发断言，仅当动态下发修复之后才能跳转，测试可以注释TheRouterManager.addRelocationHandle这行代码"] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterC3Api: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo3"
    public static var routerClass = "TheRouter_Example.TheRouterControllerC"
    public var params: [String: Any] { return ["desc":"如果直接调用TheRouterCApi进行路由跳转，此时路由地址demo33是错误的，无法进行跳转，触发断言，仅当动态下发修复之后才能跳转，测试可以注释TheRouterManager.addRelocationHandle这行代码"] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterDApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo4"
    public static var routerClass = "TheRouter_Example.TheRouterControllerD"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterWebApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://webview/home"
    public static var routerClass = "TheRouter_Example.TheRouterWebController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterEApi:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo9"
    public static var routerClass = "TheRouter_Example.TheRouterControllerE"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterLAApi:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/class_prex_test"
    public static var routerClass = "TheRouter_Example.LARouterPresentController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .modal
    
    public override init() {}
}

public class TheRouterAnyPrifxApi:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/anyClass_prex_test"
    public static var routerClass = "TheRouter_Example.AnyPrifxClassTestController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}
