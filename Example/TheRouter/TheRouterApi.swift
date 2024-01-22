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

public class TheRouterAApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo1"
    public static var routerClass = "TheRouter_Example.TheRouterControllerA"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterBApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo2"
    public static var routerClass = "TheRouter_Example.TheRouterControllerB"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterBAndroidApi: NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demo2-Android"
    public static var routerClass = "TheRouter_Example.TheRouterControllerB"
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


public class TheRouterE2Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE2"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE2"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE3Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE3"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE3"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE4Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE4"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE4"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE5Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE5"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE5"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE6Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE6"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE6"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE7Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE7"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE7"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE8Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE8"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE8"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE9Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE9"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE9"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE10Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE10"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE10"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE11Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE11"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE11"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE12Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE12"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE12"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE13Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE13"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE13"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE14Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE14"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE14"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE15Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE15"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE15"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE16Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE16"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE16"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE17Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE17"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE17"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE18Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE18"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE18"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE19Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE19"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE19"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE20Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE20"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE20"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE21Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE21"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE21"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE22Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE22"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE22"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE23Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE23"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE23"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE24Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE24"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE24"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE25Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE25"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE25"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE26Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE26"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE26"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE27Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE27"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE27"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE28Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE28"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE28"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE29Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE29"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE29"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE30Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE30"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE30"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE31Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE31"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE31"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE32Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE32"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE32"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE33Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE33"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE33"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterE34Api:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/demoE34"
    public static var routerClass = "TheRouterTestModule.TheRouterControllerE34"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterLAApi:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/class_prex_test"
    public static var routerClass = "TheRouter_Example.LARouterController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}

public class TheRouterAnyPrifxApi:NSObject, CustomRouterInfo {
    
    public static var patternString = "scheme://router/anyClass_prex_test"
    public static var routerClass = "TheRouter_Example.AnyPrifxClassTestController"
    public var params: [String: Any] { return [:] }
    public var jumpType: LAJumpType = .push
    
    public override init() {}
}
