//
//  TheRouterable.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//


public protocol TheRouterable {
    
    static var patternString: [String] { get }
    
    static var priority: UInt { get }
}

extension TheRouterable {
    public static var priority: UInt {
        1000
    }
}
