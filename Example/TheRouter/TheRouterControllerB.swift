//
//  TheRouterControllerB.swift
//  TheRouter_Example
//
//  Created by mars.yao on 2023/7/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter

public class TheRouterControllerB: TheRouterBController, TheRouterable {
    
    public static var patternString: [String] {
        ["scheme://router/demo2",
         "scheme://router/demo2-Android"]
    }
    
    public static func registerAction(info: [String : Any]) -> Any {
        let vc =  TheRouterBController()
        vc.desLabel.text = info.description
        return vc
    }
    
    public static var priority: UInt {
        TheRouterDefaultPriority
    }
}
