//
//  TheRouterRequest.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

class TheRouterRequest: TheRouterParser {
    
    var urlString: String
    var sheme: String
    var paths: [String]
    var queries: [String: Any]
    
    init(_ urlString: String) {
        self.urlString = urlString
        self.sheme = TheRouterRequest.parserSheme(urlString)
        
        let result = TheRouterRequest.parser(urlString)
        self.paths = result.paths
        self.queries = result.queries
    }
    
}
