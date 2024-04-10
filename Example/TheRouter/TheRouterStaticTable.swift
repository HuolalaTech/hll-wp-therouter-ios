//
//  TheRouterStaticTable.swift
//  TheRouter_Example
//
//  Created by season on 2024/4/10.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation

import TheRouter

/// App的静态路由表
enum AppStaticRouteTable {
    
    static let all = [
        StaticRouterInfo(patternString: "scheme://router/demo", routerClass: "TheRouter_Example.TheRouterController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo1", routerClass: "TheRouter_Example.TheRouterControllerA", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo2", routerClass: "TheRouterBController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/baseA", routerClass: "TheRouterBaseAViewController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/baseB", routerClass: "TheRouterBaseBViewController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo33", routerClass: "TheRouter_Example.TheRouterControllerC", params: ["desc":"如果直接调用TheRouterCApi进行路由跳转，此时路由地址demo33是错误的，无法进行跳转，触发断言，仅当动态下发修复之后才能跳转，测试可以注释TheRouterManager.addRelocationHandle这行代码"], jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo3", routerClass: "TheRouter_Example.TheRouterControllerC", params: ["desc":"如果直接调用TheRouterCApi进行路由跳转，此时路由地址demo33是错误的，无法进行跳转，触发断言，仅当动态下发修复之后才能跳转，测试可以注释TheRouterManager.addRelocationHandle这行代码"], jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo4", routerClass: "TheRouter_Example.TheRouterControllerD", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://webview/home", routerClass: "TheRouter_Example.TheRouterWebController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/demo9", routerClass: "TheRouter_Example.TheRouterControllerE", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/class_prex_test", routerClass: "TheRouter_Example.LARouterController", params: .empty, jumpType: .push),
        
        StaticRouterInfo(patternString: "scheme://router/anyClass_prex_test", routerClass: "TheRouter_Example.AnyPrifxClassTestController", params: .empty, jumpType: .push),
    ]
}

/// TheRouterTestModule模块的静态路由表
/// 如果有多个模块的静态路由表,那么每个模块自己维护一个静态路由表,并暴露出来即可,其实不管是维护路由表还是TheRouterApi,都可能会出现冲突问题
enum TestModuleRouteTable {
    static var all: [StaticRouterInfo] {
        return (2...34).map { index in
            let patternString = "scheme://router/demoE\(index)"
            let routerClass = "TheRouterTestModule.TheRouterControllerE\(index)"
            
            return StaticRouterInfo(patternString: patternString, routerClass: routerClass, params: .empty, jumpType: .push)
        }
    }
}

extension Dictionary where Key == String, Value == Any {
    static let empty: [String: Any] = [:]
}
