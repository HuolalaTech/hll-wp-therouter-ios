//
//  AppConfigServices.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/7/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter
import Toast

@objc
public protocol AppConfigServiceProtocol: TheRouterServiceProtocol {
    // 打开小程序
    func openMiniProgram(info: [String: Any])
}

final class ConfigModuleService: NSObject, AppConfigServiceProtocol {
    
    static var seriverName: String {
        String(describing: AppConfigServiceProtocol.self)
    }
    
    func openMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol AppRouterProtocol: TheRouterServiceProtocol {
    // 打开路由
    func openRouter(info: [String: Any])
}

final class AppRouterModuleService: NSObject, AppRouterProtocol {
    
    static var seriverName: String {
        String(describing: AppRouterProtocol.self)
    }
    
    func openRouter(info: [String : Any]) {
       debugPrint("打开路由了")
    }
}
