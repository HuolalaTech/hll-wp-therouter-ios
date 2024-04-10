//
//  AppDelegate.swift
//  TheRouter
//
//  Created by mars.yao on 11/10/2021.
//  Copyright (c) 2021 CocoaPods. All rights reserved.
//

import UIKit
import TheRouter
/// 服务路由
public let serivceHost = "scheme://services?"

/// web跳转路由
public let webRouterUrl = "scheme://webview/home"

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        
        // 日志回调，可以监控线上路由运行情况
        TheRouter.logcat { url, logType, errorMsg in
            NSLog("TheRouter: logMsg- \(url) \(logType.rawValue) \(errorMsg)")
        }
        
        // 路由懒加载注册,
        // - excludeCocoapods: 是否对Cocoapods生成的组件进行动态注册
        // - excludeCocoapods = true 不对Cocoapods生成的组件进行动态注册， false 对Cocoapods生成的组件也进行遍历动态注册
        // - useCache: 是否开启本地缓存功能
        TheRouterManager.loadRouterClass(excludeCocoapods: true, useCache: false)
        
        TheRouter.lazyRegisterRouterHandle { url, userInfo in
            TheRouterManager.injectRouterServiceConfig(webRouterUrl, serivceHost)
            /// - Parameters:
            ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
            ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
            ///   - urlPath: 将要打开的路由path
            ///   - userInfo: 路由传递的参数
            ///   - forceCheckType: 强制校验类型
            ///   注意: 传入nil或者不传不进行校验，
            ///   传入.runtime类型强制校验要求Api声明与对应的类必须实现TheRouterAble协议,
            ///   传入.staticWithRoutingList类型强制校验要求要求传入的路由表数字的元素遵守StaticRouterInfoConvertible协议
            ///   打开的话，debug环境会自动检测，避免线上出问题，建议打开
            
            /// runtime校验
            //return TheRouterManager.addGloableRouter(true, url, userInfo, forceCheckType: .runtime)
            
            /// 静态路由表校验
            let routingList = AppStaticRouteTable.all + TestModuleRouteTable.all
            return TheRouterManager.addGloableRouter(true, url, userInfo, forceCheckType: .staticWithRoutingList(routingList))
        }
            
        // 动态注册服务
        TheRouterManager.registerServices(excludeCocoapods: true)

        return true
    }
    
    func applicationWillResignActive(_ application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
    }

    func applicationDidEnterBackground(_ application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
    }

    func applicationWillEnterForeground(_ application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    }

    func applicationWillTerminate(_ application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    }


}

