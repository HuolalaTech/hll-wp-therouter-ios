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


@objc
public protocol TestServiceProtocol: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService: NSObject, TestServiceProtocol {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol1: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService1: NSObject, TestServiceProtocol1 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol1.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}


@objc
public protocol TestServiceProtocol2: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService2: NSObject, TestServiceProtocol2 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol2.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}


@objc
public protocol TestServiceProtocol3: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService3: NSObject, TestServiceProtocol3 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol3.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol4: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService4: NSObject, TestServiceProtocol4 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol4.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}


@objc
public protocol TestServiceProtocol5: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService5: NSObject, TestServiceProtocol5 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol5.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol6: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService6: NSObject, TestServiceProtocol6 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol6.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol7: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService7: NSObject, TestServiceProtocol7 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol7.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol8: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService8: NSObject, TestServiceProtocol8 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol8.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol9: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService9: NSObject, TestServiceProtocol9 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol9.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol10: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService10: NSObject, TestServiceProtocol10 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol10.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}

@objc
public protocol TestServiceProtocol11: TheRouterServiceProtocol {
    // 打开小程序
    func testOpenMiniProgram(info: [String: Any])
}

final class TestModuleService11: NSObject, TestServiceProtocol11 {
    
    static var seriverName: String {
        String(describing: TestServiceProtocol11.self)
    }
    
    func testOpenMiniProgram(info: [String : Any]) {
        if let window = UIApplication.shared.delegate?.window {
            window?.makeToast("打开微信小程序", duration: 1, position: window?.center)
        }
    }
}
