//
//  TheRouter+Jump.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation
import UIKit

// extension of viewcontroller jump for TheRouter
extension TheRouter {
    
    @discardableResult
    public class func openURL(_ urlString: String, userInfo: [String: Any] = [String: Any](), complateHandler: ComplateHandler = nil) -> Any? {
        if urlString.isEmpty {
            return nil
        }
        if !shareInstance.routerLoaded {
            return shareInstance.lazyRegisterHandleBlock?(urlString, userInfo)
        } else {
            return openCacheRouter((urlString, userInfo), complateHandler: complateHandler)
        }
    }
    
    @discardableResult
    public class func openURL(_ uriTuple: (String, [String: Any]), complateHandler: ComplateHandler = nil) -> Any? {
        if !shareInstance.routerLoaded {
            return shareInstance.lazyRegisterHandleBlock?(uriTuple.0, uriTuple.1)
        } else {
            return openCacheRouter(uriTuple, complateHandler: complateHandler)
        }
    }
    
    @discardableResult
    public class func openWebURL(_ uriTuple: (String, [String: Any])) -> Any? {
        return TheRouter.openURL(uriTuple)
    }
    
    @discardableResult
    public class func openWebURL(_ urlString: String,
                                 userInfo: [String: Any] = [String: Any]()) -> Any? {
        return TheRouter.openURL((urlString, userInfo))
    }
    
    
    public class func openCacheRouter(_ uriTuple: (String, [String: Any]), complateHandler: ComplateHandler = nil) -> Any? {
        
        if uriTuple.0.isEmpty {
            return nil
        }
        
        if uriTuple.0.contains(shareInstance.serviceHost) {
            return routerService(uriTuple)
        } else {
            return routerJump(uriTuple, complateHandler: complateHandler)
        }
    }
    
    // 路由跳转
    public class func routerJump(_ uriTuple: (String, [String: Any]), complateHandler: ComplateHandler = nil) -> Any? {
        
        let response = TheRouter.requestURL(uriTuple.0, userInfo: uriTuple.1)
        let queries = response.queries
        var resultJumpType: LAJumpType = .push
        
        if let typeString = queries[LAJumpTypeKey] as? String,
           let jumpType = LAJumpType.init(rawValue: Int(typeString) ?? 1) {
            resultJumpType = jumpType
        } else {
            resultJumpType = .push
        }
        
        let instanceVC = TheRouterDynamicParamsMapping.router().routerGetInstance(withClassName: response.pattern?.classString) as? NSObject
        
        instanceVC?.setPropertyParameter(queries)
        
        
        var resultVC: UIViewController?
        
        if let vc = instanceVC as? UIViewController {
            resultVC = vc
        }
        
        
        if let jumpVC = resultVC {
            jump(jumpType: resultJumpType, vc: jumpVC, queries: queries)
            let className = NSStringFromClass(type(of: jumpVC))
            shareInstance.logcat?(uriTuple.0, .logNormal, "resultVC: \(className)")
        } else {
            shareInstance.logcat?(uriTuple.0 , .logError, "resultVC: nil")
        }
        
        complateHandler?(queries, resultVC)
        
        return resultVC
    }
    
    public class func jump(jumpType: LAJumpType, vc: UIViewController, queries: [String: Any]) {
        DispatchQueue.main.async {
            if let action = shareInstance.customJumpAction {
                action(jumpType, vc)
            } else {
                switch jumpType {
                case .modal:
                    modal(vc)
                case .push:
                    push(vc)
                case .popToTaget:
                    popToTargetVC(vcClass: type(of: vc))
                case .windowNavRoot:
                    pusbWindowNavRoot(vc)
                case .modalDismissBeforePush:
                    modalDismissBeforePush(vc)
                case .showTab:
                    showTabBar(queries: queries)
                }
            }
        }
    }
    
    private class func showTabBar(queries: [String: Any]) {
        let selectIndex: Int = processParameter(queries[TheRouterTabBarSelecIndex] ?? 0) ?? 0
        let tabVC = UIApplication.shared.delegate?.window??.rootViewController
        if let tabVC = tabVC as? UITabBarController {
            let navVC: UINavigationController? = la_getTopViewController(nil)?.navigationController
            if let navigationController = navVC {
                navigationController.popToRootViewController(animated: false)
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
                    tabVC.selectedIndex = selectIndex
                    if let topViewController = la_getTopViewController(nil), let navController = topViewController.navigationController {
                        navController.popToRootViewController(animated: false)
                    }
                }
            }
        }
        
    }
    // 服务调用
    public class func routerService(_ uriTuple: (String, [String: Any])) -> Any? {
        let request = TheRouterRequest.init(uriTuple.0)
        let queries = request.queries
        guard let protocols = queries["protocol"] as? String,
              let methods = queries["method"] as? String else {
            assert(queries["protocol"] != nil, "The protocol name is empty")
            assert(queries["method"] != nil, "The method name is empty")
            shareInstance.logcat?(uriTuple.0, .logError, "protocol or method is empty，Unable to initiate service")
            return nil
        }
        // 为了使用方便，针对1个参数或2个参数，依旧可以按照ivar1，ivar2进行传递，自动匹配。对于没有ivar1参数的,但是方法中必须有参数的，将queries赋值作为ivar1。
        shareInstance.logcat?(uriTuple.0, .logNormal, "")
        
        if let functionResultType = uriTuple.1[TheRouterFunctionResultKey] as? Int {
            if functionResultType == TheRouterFunctionResultType.voidType.rawValue {
                self.performTargetVoidType(protocolName: protocols,
                                           actionName: methods,
                                           param: uriTuple.1[TheRouterIvar1Key],
                                           otherParam: uriTuple.1[TheRouterIvar2Key])
                return nil
            } else if functionResultType == TheRouterFunctionResultType.valueType.rawValue {
                let exectueResult = self.performTarget(protocolName: protocols,
                                                       actionName: methods,
                                                       param: uriTuple.1[TheRouterIvar1Key],
                                                       otherParam: uriTuple.1[TheRouterIvar2Key])
                return exectueResult?.takeUnretainedValue()
            } else if functionResultType == TheRouterFunctionResultType.referenceType.rawValue {
                let exectueResult = self.performTarget(protocolName: protocols,
                                                       actionName: methods,
                                                       param: uriTuple.1[TheRouterIvar1Key],
                                                       otherParam: uriTuple.1[TheRouterIvar2Key])
                return exectueResult?.takeRetainedValue()
            }
        }
        return nil
    }
    
    //实现路由转发协议-值类型与引用类型
    public class func performTarget(protocolName: String,
                                    actionName: String,
                                    param: Any? = nil,
                                    otherParam: Any? = nil,
                                    classMethod: Bool = false) -> Unmanaged<AnyObject>? {
        if classMethod {
            let serviceClass = TheRouterServiceManager.default.servicesCache[protocolName] as? AnyObject ?? NSObject()
            assert(TheRouterServiceManager.default.servicesCache[protocolName] != nil, "No corresponding service found")
            let selector  = NSSelectorFromString(actionName)
            guard let _ = class_getClassMethod(serviceClass as? AnyClass, selector) else {
                assert(class_getClassMethod(serviceClass as? AnyClass, selector) != nil, "No corresponding class method found")
                shareInstance.logcat?("\(protocolName)->\(actionName)", .logError, "No corresponding class method found")
                return nil
            }
            return serviceClass.perform(selector, with: param, with: otherParam)
        } else {
            let serviceClass = TheRouterServiceManager.default.servicesCache[protocolName] as? AnyObject ?? NSObject()
            let selector = NSSelectorFromString(actionName)
            guard let _ = class_getInstanceMethod(type(of: serviceClass), selector) else {
                assert(class_getInstanceMethod(serviceClass as? AnyClass, selector) != nil, "No corresponding instance method found")
                shareInstance.logcat?("\(protocolName)->\(actionName)", .logError, "No corresponding instance method found")
                return nil
            }
            return serviceClass.perform(selector, with: param, with: otherParam)
        }
    }
    
    //实现路由转发协议-无返回值类型
    public class func performTargetVoidType(protocolName: String,
                                            actionName: String,
                                            param: Any? = nil,
                                            otherParam: Any? = nil,
                                            classMethod: Bool = false) {
        if classMethod {
            let serviceClass = TheRouterServiceManager.default.servicesCache[protocolName] as? AnyObject ?? NSObject()
            assert(TheRouterServiceManager.default.servicesCache[protocolName] != nil, "No corresponding service found")
            let selector  = NSSelectorFromString(actionName)
            guard let _ = class_getClassMethod(serviceClass as? AnyClass, selector) else {
                assert(class_getClassMethod(serviceClass as? AnyClass, selector) != nil, "No corresponding class method found")
                shareInstance.logcat?("\(protocolName)->\(actionName)", .logError, "No corresponding class method found")
                return
            }
            _ = serviceClass.perform(selector, with: param, with: otherParam)
        } else {
            let serviceClass = TheRouterServiceManager.default.servicesCache[protocolName] as? AnyObject ?? NSObject()
            let selector = NSSelectorFromString(actionName)
            guard let _ = class_getInstanceMethod(type(of: serviceClass), selector) else {
                assert(class_getInstanceMethod(serviceClass as? AnyClass, selector) != nil, "No corresponding instance method found")
                shareInstance.logcat?("\(protocolName)->\(actionName)", .logError, "No corresponding instance method found")
                return
            }
            _ = serviceClass.perform(selector, with: param, with: otherParam)
        }
    }
    
    public class func push(_ vc: UIViewController) {
        
        guard let currentVC = getActivityViewController() else {
            return
        }
        if currentVC is UITabBarController {
            vc.hidesBottomBarWhenPushed = true
            la_getTopViewController(nil)?.navigationController?.pushViewController(vc, animated: true)
        } else {
            DispatchQueue.main.async {
                var navVC: UINavigationController?
                if  currentVC.isKind(of: UINavigationController.self) == true {
                    navVC = currentVC as? UINavigationController
                } else {
                    navVC = getFirstNavigationControllerContainer(responder: currentVC) as? UINavigationController
                }
                vc.hidesBottomBarWhenPushed = true
                navVC?.pushViewController(vc, animated: true)
            }
        }
    }
    
    public class func modal(_ vc: UIViewController) {
        
        guard let currentVC = getActivityViewController() else {
            return
        }
        DispatchQueue.main.async {
            
            vc.modalTransitionStyle = UIModalTransitionStyle.coverVertical
            vc.modalPresentationStyle = .fullScreen
            // 防止单例的视图控制器
            guard vc.presentedViewController == nil else {return}
            guard vc.isBeingPresented == false else {return}
            
            // 不同视图控制器，先隐藏旧的，再展示新的
            if (currentVC.presentationController) != nil {
                currentVC.presentedViewController?.dismiss(animated: false, completion: nil)
            }
            
            currentVC.present(vc, animated: true, completion: nil)
        }
    }
    
    public class func popToTargetVC(vcClass: UIViewController.Type) {
        
        let navVC: UINavigationController? = la_getTopViewController(nil)?.navigationController
        
        guard let targetVC = navVC?.viewControllers.filter({ $0.isKind(of: vcClass) }).last else {
            navVC?.popViewController(animated: true)
            return
        }
        
        DispatchQueue.main.async {
            navVC?.popToViewController(targetVC, animated: true)
        }
    }
    
    // MARK: - 跳转到首页
    public class func popToRootVC() {
        la_getTopViewController(nil)?.navigationController?.popToRootViewController(animated: true)
    }
    
    // MARK: - 需要注册的时候传入一个导航包含的控制器
    public class func windowRoot(nav: UIViewController) {
        if  nav.isKind(of: UINavigationController.self) == true {
            getKeyWindow().rootViewController = nav
        } else {
#if DEBUG
            assertionFailure("传入对象必须是导航控制器")
#endif
        }
    }
    
    public class func modalDismissBeforePush(_ vc: UIViewController) {
        if let visiableVC = TheRouter.la_getTopViewController(nil), visiableVC.presentingViewController != nil {
            visiableVC.dismiss(animated: false) {
                push(vc)
            }
        } else {
            push(vc)
        }
    }
    
    public class func pusbWindowNavRoot(_ vc: UIViewController) {
        if let app = UIApplication.shared.delegate, let window = app.window {
            if let rootVC = window?.rootViewController {
                if let nav: UINavigationController = rootVC as? UINavigationController {
                    nav.pushViewController(vc, animated: true)
                } else {
                    la_getTopViewController(nil)?.navigationController?.pushViewController(vc, animated: true)
                }
            }
        }
    }
    
    // MARK: - 判断某视图是否已经在window 上
    public class func ifAddToWindow(view: AnyClass) -> Bool {
        let res = getKeyWindow().subviews.filter { (subView: UIView) -> Bool in
            return subView.isKind(of: view.self)
        }
        return res.count > 0
    }
    
    // MARK: - 获取活跃VC
    public class func getActivityViewController() -> UIViewController? {
        
        var viewController: UIViewController?
        let windows: [UIWindow] = UIApplication.shared.windows
        var activeWindow: UIWindow?
        
        for window in windows {
            if window.windowLevel == UIWindow.Level.normal {
                activeWindow = window
                break
            }
        }
        
        if activeWindow != nil && activeWindow!.subviews.count > 0 {
            let frontView: UIView = activeWindow!.subviews.last!
            var nextResponder: UIResponder? = frontView.next
            
            while nextResponder!.isKind(of: UIWindow.self) == false {
                if nextResponder!.isKind(of: UIViewController.self) {
                    viewController = nextResponder as! UIViewController?
                    break
                } else {
                    nextResponder = nextResponder!.next
                }
            }
            
            if nextResponder!.isKind(of: UIViewController.self) {
                viewController = nextResponder as! UIViewController?
            } else {
                viewController = activeWindow!.rootViewController
            }
            
            while  viewController!.presentedViewController != nil {
                viewController =  viewController!.presentedViewController
            }
        }
        
        return viewController
    }
    
    /// 获取当前正在显示的UIViewController，而不是NavigationController
    public class func visibleVC() -> UIViewController? {
        let viewController = getActivityViewController()
        if viewController?.isKind(of: UINavigationController.self) == true {
            let nav: UINavigationController = viewController as! UINavigationController
            return nav.visibleViewController
        }
        return viewController
    }
    
    // MARK: 获取根控制器
    public class func getRootViewController() -> UIViewController? {
        
        var vc: UIViewController?
        
        let windows: [UIWindow] = UIApplication.shared.windows
        var activeWindow: UIWindow?
        
        for window in windows {
            if window.windowLevel == UIWindow.Level.normal {
                activeWindow = window
                break
            }
        }
        
        if activeWindow?.rootViewController != nil {
            vc = activeWindow!.rootViewController
        }
        return vc
    }
    
    // MARK: 获取导航栏
    private class func getFirstNavigationControllerContainer(responder: UIResponder?) -> UIViewController? {
        var returnResponder: UIResponder? = responder
        while returnResponder != nil {
            if returnResponder!.isKind(of: UIViewController.self) {
                
                if (returnResponder! as? UIViewController)!.navigationController != nil {
                    return returnResponder! as? UIViewController
                }
            }
            returnResponder = returnResponder!.next
        }
        
        return nil
    }
    
    // 获取window
    public class func getKeyWindow() -> UIWindow {
        let app = UIApplication.shared
        if app.delegate?.window != nil {
            return ((app.delegate?.window)!)!
        } else {
            return app.keyWindow!
        }
    }
    public class func la_getTopViewController(_ currentVC: UIViewController?) -> UIViewController? {
        
        guard let rootVC = getKeyWindow().rootViewController else {
            return nil
        }
        let topVC = currentVC ?? rootVC
        
        switch topVC {
        case is UITabBarController:
            if let top = (topVC as! UITabBarController).selectedViewController {
                return la_getTopViewController(top)
            } else {
                return nil
            }
            
        case is UINavigationController:
            if let top = (topVC as! UINavigationController).topViewController {
                return la_getTopViewController(top)
            } else {
                var navVC: UINavigationController?
                navVC = getFirstNavigationControllerContainer(responder: currentVC) as? UINavigationController
                return navVC
            }
            
        default:
            return topVC.presentedViewController ?? topVC
        }
    }
    
    class func processParameter(_ parameter: Any) -> Int? {
        if let intValue = parameter as? Int {
            return intValue
        } else if let stringValue = parameter as? String, let intValue = Int(stringValue) {
            return intValue
        } else {
            return 0
        }
    }
    
}
