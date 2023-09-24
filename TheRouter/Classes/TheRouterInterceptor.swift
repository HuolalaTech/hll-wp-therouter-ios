//
//  TheRouterInterceptor.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import UIKit

public class TheRouterInterceptor: NSObject {
    
    public typealias InterceptorHandleBlock = ([String: Any]) -> Bool
    
    var priority: uint
    var whiteList: [String]
    var handle: InterceptorHandleBlock
    
    init(_ whiteList: [String],
         priority: uint,
         handle: @escaping InterceptorHandleBlock) {
        
        self.whiteList = whiteList
        self.priority = priority
        self.handle = handle
    }
    
}
