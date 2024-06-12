//
//  AnyPrifxClassTestController.swift
//  TheRouter_Example
//
//  Created by mars.yao on 11/10/2021.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

import Foundation
import TheRouter

class AnyPrifxClassTestController: TheRouterBaseControllerSwift, TheRouterable {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.backgroundColor = .cyan
    }

    public static var patternString: [String] {
        ["scheme://router/anyClass_prex_test"]
    }
}
