//
//  AnyPrifxClassTestController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 11/10/2021.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter

class AnyPrifxClassTestController: UIViewController, TheRouterable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
    }

    public static var patternString: [String] {
        ["scheme://router/anyClass_prex_test"]
    }
    
    public static func registerAction(info: [String : Any]) -> Any {
        let vc =  AnyPrifxClassTestController()
        return vc
    }
    
    public static var priority: UInt {
        TheRouterDefaultPriority
    }
}
