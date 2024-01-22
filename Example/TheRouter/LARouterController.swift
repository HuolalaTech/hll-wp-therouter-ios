//
//  LARouterController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 11/10/2021.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter

class LARouterController: UIViewController, TheRouterable {
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
    }

    public static var patternString: [String] {
        ["scheme://router/class_prex_test"]
    }
    
    public static func registerAction(info: [String : Any]) -> Any {
        let vc =  LARouterController()
        return vc
    }
    
    public static var priority: UInt {
        TheRouterDefaultPriority
    }
}
