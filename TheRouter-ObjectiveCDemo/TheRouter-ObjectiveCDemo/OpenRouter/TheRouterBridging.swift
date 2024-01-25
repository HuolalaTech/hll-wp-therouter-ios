//
//  TheRouterBridging.swift
//  TheRouter-ObjectiveCDemo
//
//  Created by mars.yao on 2024/1/25.
//

import Foundation
import TheRouter

/// 服务路由
public let serivceHost = "scheme://services?"

/// web跳转路由
public let webRouterUrl = "scheme://webview/home"

@objc public class TheRouterService: NSObject {
    
    public typealias TheRouterComplateHandler = ((NSDictionary?, NSObject?) -> Void)?

    @objc public static func initTheRouter() {
        // 日志回调，可以监控线上路由运行情况
        TheRouter.logcat { url, logType, errorMsg in
            NSLog("TheRouter: logMsg- \(url) \(logType.rawValue) \(errorMsg)")
        }
        
        // 路由懒加载注册,
        // - excludeCocoapods: 是否对Cocoapods生成的组件进行动态注册
        // - excludeCocoapods = true 不对Cocoapods生成的组件进行动态注册， false 对Cocoapods生成的组件也进行遍历动态注册
        // - useCache: 是否开启本地缓存功能
        TheRouterManager.loadRouterClass(excludeCocoapods: true, useCache: true)
        
        TheRouter.lazyRegisterRouterHandle { url, userInfo in
            TheRouterManager.injectRouterServiceConfig(webRouterUrl, serivceHost)
            /// - Parameters:
            ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
            ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
            ///   - urlPath: 将要打开的路由path
            ///   - userInfo: 路由传递的参数
            ///   - forceCheckEnable: 是否支持强制校验，强制校验要求Api声明与对应的类必须实现TheRouterAble协议
            ///   - forceCheckEnable 强制打开TheRouterApi定义的便捷类与实现TheRouterAble协议类是否相同，打开的话，debug环境会自动检测，避免线上出问题，建议打开
            return TheRouterManager.addGloableRouter(true, url, userInfo, forceCheckEnable: true)
        }
            
        // 动态注册服务
        TheRouterManager.registerServices(excludeCocoapods: true)
    }
    
    @discardableResult
    @objc public static func openURL(_ urlString: String,
                                     _ userInfo: [String: Any] = [String: Any](),
                                     _ complateHandler: TheRouterComplateHandler = nil) -> Any? {
        TheRouter.openURL(urlString, userInfo: userInfo, complateHandler: { (dict, obj) in
            // 将结果转换为Objective-C兼容的类型
            complateHandler?(dict as NSDictionary?, obj as? NSObject)
        })
    }
    
    @discardableResult
    @objc public static func openWebURL(_ urlString: String,
                                        _ userInfo: [String: Any] = [String: Any]()) -> Any? {
        return TheRouter.openURL((urlString, userInfo))
    }
    
}

// 假设需要跳转的类是TheRouterController， 那么在此处实现
public class TheRouterControllerSwift: TheRouterController, TheRouterable {
    
    public static var patternString: [String] {
        ["scheme://router/objcDemo"]
    }
    
    public static func registerAction(info: [String : Any]) -> Any {
        let vc =  TheRouterController()
        // 参数记得自己赋值
        return vc
    }
    
    public static var priority: UInt {
        TheRouterDefaultPriority
    }
}

