//
//  TheRouter+Convenience.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import UIKit

public extension TheRouter {
    
    /// addRouterItem with parasing the dictionary, the class which match the className need inherit the protocol of TheRouterable
    ///
    class func addRouterItem(_ routerItem: RouteItem) {
        addRouterItem(routerItem.path, classString: routerItem.className)
    }
    
    /// addRouterItem with parasing the dictionary, the class which match the className need inherit the protocol of TheRouterable
    ///
    /// - Parameter dictionary: [patternString: className]
    class func addRouterItem(_ dictionary: [String: String]) {
        dictionary.forEach { (key: String, value: String) in
            addRouterItem(key, classString: value)
        }
    }
    
    /// convienience addRouterItem with className
    ///
    /// - Parameters:
    ///   - patternString: register urlstring
    ///   - classString: the class which match the className need inherit the protocol of TheRouterable
    class func addRouterItem(patternString: String, priority: uint = 0, classString: String) {
       
        let clz: AnyClass? = classString.trimmingCharacters(in: CharacterSet.whitespaces).la_matchClass()
        if let _ = clz as? TheRouterable.Type {
            self.addRouterItem(patternString.trimmingCharacters(in: CharacterSet.whitespaces), classString: classString, priority: priority)
        } else {
            if let currentCls = clz, currentCls.self.conforms(to: TheRouterableProxy.self) {
                self.addRouterItem(patternString.trimmingCharacters(in: CharacterSet.whitespaces), classString: classString, priority: priority)
            } else {
                shareInstance.logcat?(patternString, .logError, "\(classString) register router error， please implementation the TheRouterable Protocol")
                assert(clz as? TheRouterable.Type != nil, "register router error， please implementation the TheRouterable Protocol")
            }
        }
    }
    
    /// addRouterItem
    ///
    /// - Parameters:
    ///   - patternString: register urlstring
    ///   - priority: match priority, sort by inverse order
    ///   - handle: block of refister URL
    class func addRouterItem(_ patternString: String, classString: String, priority: uint = 0) {
        shareInstance.addRouterItem(patternString.trimmingCharacters(in: CharacterSet.whitespaces), classString: classString, priority: priority)
    }
    
    /// addRouterItem
    ///
    /// - Parameters:
    ///   - whiteList: whiteList for intercept
    ///   - priority: match priority, sort by inverse order
    ///   - handle: block of interception
    class func addRouterInterceptor(_ whiteList: [String] = [String](), priority: uint = 0, handle: @escaping TheRouterInterceptor.InterceptorHandleBlock) {
        shareInstance.addRouterInterceptor(whiteList, priority: priority, handle: handle)
    }
    
    /// addFailedHandel
    class func globalOpenFailedHandler(_ handel: @escaping FailedHandleBlock) {
        shareInstance.globalOpenFailedHandler(handel)
    }
    
    /// LazyRegister
    class func lazyRegisterRouterHandle(_ handel: @escaping LazyRegisterHandleBlock) {
        shareInstance.lazyRegisterRouterHandle(handel)
    }
    
    /// addRouterItemLogHandle
    class func logcat(_ handle: @escaping RouterLogHandleBlock) {
        shareInstance.logcat(handle)
    }
    
    /// addRouterItemLogHandle
    class func customJumpAction(_ handle: @escaping CustomJumpActionClouse) {
        shareInstance.customJumpAction(handle)
    }
    
    /// removeRouter by register urlstring
    ///
    /// - Parameter patternString: register urlstring
    class func removeRouter(_ patternString: String) {
        shareInstance.removeRouter(patternString.trimmingCharacters(in: CharacterSet.whitespaces))
    }
    
    /// Check whether register for url
    ///
    /// - Parameter urlString: real request urlstring
    /// - Returns: whether register
    class func canOpenURL(_ urlString: String) -> Bool {
        return shareInstance.canOpenURL(urlString.trimmingCharacters(in: CharacterSet.whitespaces))
    }
    
    /// request for url
    ///
    /// - Parameters:
    ///   - urlString: real request urlstring
    ///   - userInfo: custom userInfo, could contain Object
    /// - Returns: response for request, contain pattern and queries
    class func requestURL(_ urlString: String, userInfo: [String: Any] = [String: Any]()) -> RouteResponse {
        return shareInstance.requestURL(urlString.trimmingCharacters(in: CharacterSet.whitespaces), userInfo: userInfo)
    }
    
    // injectRouterServiceConfig
    class func injectRouterServiceConfig(_ webPath: String?, _ serviceHost: String) {
        return shareInstance.injectRouterServiceConfig(webPath, serviceHost)
    }
    
    /// Is the route loaded
    /// - Parameter loadStatus:  router paths loadStatus
    class func routerLoadStatus(_ loadStatus: Bool) {
        return shareInstance.routerLoadStatus(loadStatus)
    }
}
