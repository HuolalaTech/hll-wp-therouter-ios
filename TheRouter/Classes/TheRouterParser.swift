//
//  TheRouterParser.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

protocol TheRouterParser {
    
    typealias ParserResult = (paths: [String], queries: [String: Any])
    // 不做百分号转义
    static func parser(_ url: URL) -> ParserResult
    static func parserSheme(_ url: URL) -> String
    static func parserPaths(_ url: URL) -> [String]
    static func parserQuerys(_ url: URL) -> [String: Any]
    // 做百分号转义
    static func parser(_ urlString: String) -> ParserResult
    static func parserSheme(_ urlString: String) -> String
    static func parserPaths(_ urlString: String) -> [String]
    static func parserQuerys(_ urlString: String) -> [String: Any]
}

extension TheRouterParser {
    
    static func parser(_ url: URL) -> ParserResult {
        let paths = parserPaths(url)
        let query = parserQuerys(url)
        return (paths, query)
    }
    
    static func parserSheme(_ url: URL) -> String {
        return url.scheme ?? ""
    }
    
    static func parserPaths(_ url: URL) -> [String] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return [String]()
        }
        let paths = la_parserPath(components)
        return paths
    }
    
    static func parserQuerys(_ url: URL) -> [String: Any] {
        guard let components = URLComponents(url: url, resolvingAgainstBaseURL: true) else {
            return [String: Any]()
        }
        let query = la_parserQuery(components)
        return (query as [String: Any])
    }
    
    static func parser(_ urlString: String) -> ParserResult {
        let paths = parserPaths(urlString)
        let queries = parserQuerys(urlString)
        return (paths, queries)
    }
    
    static func parserSheme(_ urlString: String) -> String {
        if let url = canOpenURLString(urlString) {
            return url.scheme ?? ""
        }
        return ""
    }
    
    static func parserPaths(_ urlString: String) -> [String] {
        var paths = [String]()
        
        urlString.components(separatedBy: "#").forEach { componentString in
            if let url = canOpenURLString(componentString) {
                let result = parserPaths(url)
                paths += result
            }
        }
        return paths
    }
    
    static func parserQuerys(_ urlString: String) -> [String: Any] {
        var queries = [String: Any]()
        
        urlString.components(separatedBy: "#").forEach { componentString in
            if let url = canOpenURLString(componentString) {
                let result = parserQuerys(url)
                queries.la_combine(result)
            }
        }
        return queries
    }
    
    /// 解析Path (paths include the host)
    private static func la_parserPath(_ components: URLComponents) -> [String] {
        
        var paths = [String]()
        
        // check host
        if let host = components.host, host.count > 0 {
            paths.append(host)
        }
        
        // check path
        let path = components.path
        if path.count > 0 {
            let pathComponents = path.components(separatedBy: "/").filter { $0.count > 0}
            paths += pathComponents
        }
        
        return paths
    }
    
    /// 解析Query
    private static func la_parserQuery(_ components: URLComponents) -> [String: Any] {
        
        guard let items = components.queryItems,
              items.count > 0 else {
            return [:]
        }
        
        var queries = [String: Any]()
        items.forEach { (item) in
            if let value = item.value {
                queries[item.name] = value
            } else {
            }
        }
        
        return queries
    }
    
    /// 检查URL
    public static func canOpenURLString(_ urlString: String) -> URL? {
        
        let urlString = urlString.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        guard let encodeString = urlString, encodeString.count > 0 else {
            return nil
        }
        
        guard let url = URL.init(string: encodeString) else {
            return nil
        }
        
        return url
    }
}
