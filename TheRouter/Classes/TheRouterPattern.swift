//
//  TheRouterPattern.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

public class TheRouterPattern: TheRouterParser {
    
    public static let PatternPlaceHolder = "~LA~"
    
    public var patternString: String
    public var sheme: String
    public var patternPaths: [String]
    public var priority: uint
    public var matchString: String
    public var classString: String
    public var paramsMatchDict: [String: Int]
    
    public init(_ string: String,
                _ classString: String,
                priority: uint = 0) {
        
        self.patternString = string
        self.priority = priority
        self.sheme = TheRouterPattern.parserSheme(string)
        self.patternPaths = TheRouterPattern.parserPaths(string)
        self.paramsMatchDict = [String: Int]()
        self.classString = classString
        var matchPaths = [String]()
        for i in 0..<patternPaths.count {
            var pathComponent = self.patternPaths[i]
            if pathComponent.hasPrefix(":") {
                let name = pathComponent.la_dropFirst(1)
                self.paramsMatchDict[name] = i
                pathComponent = TheRouterPattern.PatternPlaceHolder
            }
            matchPaths.append(pathComponent)
        }
        self.matchString = matchPaths.joined(separator: "/")
    }
    
}
