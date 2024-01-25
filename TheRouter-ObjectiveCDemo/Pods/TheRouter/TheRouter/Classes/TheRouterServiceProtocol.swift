//
//  TheRouterServiceProtocol.swift
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

@objc
public protocol TheRouterServiceProtocol: NSObjectProtocol {
    init()
    
    static var seriverName: String { get }
}
