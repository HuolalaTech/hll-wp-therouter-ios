//
//  TheRouter.swift
//  TheRouter
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

// 定义一个封装类来存储和执行接受参数的闭包
public class TheRouerParamsClosureWrapper: NSObject {
    public var closure: ((Any) -> Void)?

    public init(closure: @escaping (Any) -> Void) {
        self.closure = closure
    }

    public func executeClosure(params: Any) {
        closure?(params)
    }
}

public class TheRouter: TheRouterParser {
    
    // MARK: - Constants
    public typealias FailedHandleBlock = ([String: Any]) -> Void
    public typealias RouteResponse = (pattern: TheRouterPattern?, queries: [String: Any])
    public typealias MatchResult = (matched: Bool, queries: [String: Any])
    public typealias LazyRegisterHandleBlock = (_ url: String, _ userInfo: [String: Any]) -> Any?
    public typealias RouterLogHandleBlock = (_ url: String, _ logType: TheRouterLogType, _ errorMsg: String) -> Void
    
    // MARK: - 自定义跳转
    public typealias CustomJumpActionClouse = (LAJumpType, UIViewController) -> Void
    
    // MARK: - Private property
    private var interceptors = [TheRouterInterceptor]()
    
    private var globalOpenFailedHandler: FailedHandleBlock?
    
    // MARK: - Public  property
    public static let shareInstance = TheRouter()
    
    // 映射要替换的路由信息
    public var reloadRouterMap: [TheRouterInfo] = []
    
    /// 懒加载注册
    public var lazyRegisterHandleBlock: LazyRegisterHandleBlock?
    
    // 路由是否加载完毕
    public var routerLoaded: Bool = false
    
    public var patterns = [TheRouterPattern]()
    
    public var webPath: String?
    
    public var serviceHost: String = "scheme://services?"
    
    public var logcat: RouterLogHandleBlock?
    
    public var customJumpAction: CustomJumpActionClouse?
    
    // MARK: - Public method
    func addRouterItem(_ patternString: String,
                       classString: String,
                       priority: uint = 0) {
        
        let pattern = TheRouterPattern.init(patternString.trimmingCharacters(in: CharacterSet.whitespaces), classString, priority: priority)
        patterns.append(pattern)
        patterns.sort { $0.priority > $1.priority }
    }
    
    func addRouterInterceptor(_ whiteList: [String] = [String](),
                              priority: uint = 0,
                              handle: @escaping TheRouterInterceptor.InterceptorHandleBlock) {
        let interceptor = TheRouterInterceptor.init(whiteList, priority: priority, handle: handle)
        interceptors.append(interceptor)
        interceptors.sort { $0.priority > $1.priority }
    }
    
    func globalOpenFailedHandler(_ handle: @escaping FailedHandleBlock) {
        globalOpenFailedHandler = handle
    }
    
    func lazyRegisterRouterHandle(_ handle: @escaping LazyRegisterHandleBlock) {
        lazyRegisterHandleBlock = handle
    }
    
    func logcat(_ handle: @escaping RouterLogHandleBlock) {
        logcat = handle
    }
    
    func customJumpAction(_ handle: @escaping CustomJumpActionClouse) {
        customJumpAction = handle
    }
    
    func removeRouter(_ patternString: String) {
        patterns = patterns.filter { $0.patternString != patternString }
    }
    
    func canOpenURL(_ urlString: String) -> Bool {
        if urlString.isEmpty {
            return false
        }
        return matchURL(urlString.trimmingCharacters(in: CharacterSet.whitespaces)).pattern != nil
    }
    
    func requestURL(_ urlString: String, userInfo: [String: Any] = [String: Any]()) -> RouteResponse {
        return matchURL(urlString.trimmingCharacters(in: CharacterSet.whitespaces), userInfo: userInfo)
    }
    
    // MARK: - Private method
    private func matchURL(_ urlString: String, userInfo: [String: Any] = [String: Any]()) -> RouteResponse {
        
        let request = TheRouterRequest.init(urlString)
        var queries = request.queries
        var matched: TheRouterPattern?
        var matchUserInfo: [String: Any] = userInfo
        let relocationMap = reloadRouterMap(TheRouter.shareInstance.reloadRouterMap, url: urlString)
        if let relocationMap = relocationMap,
           let url = relocationMap[TheRouter.urlKey] as? String,
           let firstMatched = patterns.filter({ $0.patternString == url }).first {
            //relocation
            matched = firstMatched
            if let relocationUserInfo =  relocationMap[TheRouter.userInfoKey] as? [String: Any] {
                matchUserInfo = relocationUserInfo
            }
        } else {
            var matchedPatterns = [TheRouterPattern]()
            
            if la_webUrlCheck(urlString) {
                matchedPatterns = patterns.filter{ ($0.patternString == TheRouter.shareInstance.webPath)}
                assert(TheRouter.shareInstance.webPath != nil, "h5 jump path cannot be empty")
            } else {
                //filter the scheme and the count of paths not matched
                matchedPatterns = patterns.filter{ $0.sheme == request.sheme && $0.patternPaths.count == request.paths.count }
            }
            
            for pattern in matchedPatterns {
                let result = matchPattern(request, pattern: pattern)
                if result.matched || la_webUrlCheck(urlString) {
                    matched = pattern
                    queries.la_combine(result.queries)
                    break
                }
            }
        }
        
        guard let currentPattern = matched else {
            //not matched
            var info = [TheRouter.matchFailedKey  : urlString as Any]
            info.la_combine(matchUserInfo)
            globalOpenFailedHandler?(info)
            logcat?(urlString, .logError, "not matched, please check the router register is all readly")
            assert(matched != nil, "not matched, please check the router register is all readly")
            return (nil, [String: Any]())
        }
        
        guard la_intercept(currentPattern.patternString, queries: queries) else {
            return (nil, [String: Any]())
        }
        
        if la_webUrlCheck(urlString) {
            queries.la_combine(["url" : urlString as Any])
            queries.la_combine([LAJumpTypeKey: "\(LAJumpType.push.rawValue)" as Any])
            queries.la_combine(matchUserInfo)
        } else {
            queries.la_combine([TheRouter.requestURLKey  : currentPattern.matchString as Any])
            queries.la_combine(matchUserInfo)
        }
        
        return (currentPattern, queries)
    }
    
    
    private func matchPattern(_ request: TheRouterRequest, pattern: TheRouterPattern) -> MatchResult {
        
        var requestPaths = request.paths
        var pathQuery = [String: Any]()
        // replace params
        pattern.paramsMatchDict.forEach({ (name, index) in
            let requestPathQueryValue = requestPaths[index] as Any
            pathQuery[name] = requestPathQueryValue
            requestPaths[index] = TheRouterPattern.PatternPlaceHolder
        })
        
        let matchString = requestPaths.joined(separator: "/")
        if matchString == pattern.matchString {
            return (true, pathQuery)
        } else {
            return (false, [String: Any]())
        }
        
    }
    
    func la_webUrlCheck(_ urlString: String) -> Bool {
        if let url = TheRouter.canOpenURLString(urlString) {
            if url.scheme == "https" || url.scheme == "http" {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    // Intercep the request and return whether should continue
    private func la_intercept(_ matchedPatternString: String, queries: [String: Any]) -> Bool {
        
        for interceptor in self.interceptors where !interceptor.whiteList.contains(matchedPatternString) {
            if !interceptor.handle(queries) {
                // interceptor handle return true will continue interceptor
                return false
            }
        }
        
        return true
    }
    
    func routerLoadStatus(_ loadStatus: Bool) {
        routerLoaded = loadStatus
    }
    
    func injectRouterServiceConfig(_ webPath: String?, _ serviceHost: String) {
        self.webPath = webPath
        self.serviceHost = serviceHost
    }
    
    func reloadRouterMap(_ reloadRouterMap: [TheRouterInfo], url: String) -> [String: Any]?  {
        if reloadRouterMap.count > 0 {
            
            var orignRouterUrl = ""
            var replacedRouterUrl = ""
            var replaceParam: [String: Any] = [:]
            
            for rouerInfo in reloadRouterMap {
                
                if (rouerInfo.routerType == TheRouterReloadMapEnum.replace.rawValue) {
                    if (patterns.first(where: { $0.patternString == rouerInfo.orginPath }) != nil) {
                        orignRouterUrl = rouerInfo.orginPath ?? ""
                        replacedRouterUrl = rouerInfo.targetPath ?? ""
                        replaceParam = rouerInfo.params ?? [:]
                    }
                }
            }
            
            if url.hasPrefix(orignRouterUrl) {
                let dict = replaceParam as [String: AnyObject]
                return [TheRouter.urlKey: replacedRouterUrl, TheRouter.userInfoKey: dict] as [String: Any]
            } else {
                return nil
            }
        } else {
            return nil
        }
    }
}
