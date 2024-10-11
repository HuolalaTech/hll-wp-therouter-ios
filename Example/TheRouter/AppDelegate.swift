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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil) -> Bool {
        
        // 日志回调，可以监控线上路由运行情况
        TheRouter.logcat { url, logType, errorMsg in
            NSLog("TheRouter: logMsg- \(url) \(logType.rawValue) \(errorMsg)")
        }
        
        // 类似RDVTabBarControlle也没有继承UITabbarController，导航栈也不同，那么就需要自己实现各种跳转逻辑
//        TheRouter.customJumpAction { jumpType, instance in
//          
//        }
        
        var config = TheRouterConfiguration()
        config.excludeCocoapods = false
        config.forceCheckEnable = false
        config.useCache = true
        config.webPath = webRouterUrl
        config.serviceHost = serivceHost
        TheRouterManager.shareInstance.setConfiguration(config)

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

