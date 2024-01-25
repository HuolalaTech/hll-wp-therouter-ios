//
//  TheRouterBuilder.swift
//  TheRouter
//
//  Created by mars.yao on 2023/3/9.
//

import Foundation

public class TheRouterBuilder {
    
    public var buildResult: (String, [String: Any]) = ("", [:])
    
    public init () {}
}

extension TheRouterBuilder {
    
    @discardableResult
    public class func build(_ path: String) -> TheRouterBuilder {
        let builder = TheRouterBuilder.init()
        builder.buildPaths(path: path)
        return builder
    }
    
    @discardableResult
    public func withInt(key: String, value: Int) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    @discardableResult
    public func withString(key: String, value: String) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    @discardableResult
    public func withBool(key: String, value: Bool) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    @discardableResult
    public func withDouble(key: String, value: Double) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    @discardableResult
    public func withFloat(key: String, value: Float) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    @discardableResult
    public func withAny(key: String, value: Any) -> Self {
        buildResult.1[key] = value
        return self
    }
    
    func buildPaths(path: String) {
        buildResult.0 = path
    }
    
    @discardableResult
    public func buildService<TheRouterServiceProtocol>(_ protocolInstance: TheRouterServiceProtocol.Type, methodName: String) -> Self {
        let protocolName = String(describing: protocolInstance)
        buildResult.0 = "\(TheRouter.shareInstance.serviceHost)protocol=\(protocolName)&method=\(methodName)"
        return self
    }
    
    @discardableResult
    public func buildServicePath<TheRouterServiceProtocol>(_ protocolInstance: TheRouterServiceProtocol.Type, methodName: String) -> String {
        let protocolName = String(describing: protocolInstance)
        return "\(TheRouter.shareInstance.serviceHost)protocol=\(protocolName)&method=\(methodName)"
    }
    
    @discardableResult
    func buildService(path: String) -> Self  {
        buildResult.0 = path
        return self
    }
    
    @discardableResult
    public func buildDictionary(param: [String: Any]) -> Self {
        buildResult.1.merge(dic: param)
        return self
    }
    
    @discardableResult
    public func fetchService() -> Any? {
        let result = TheRouter.generate(buildResult.0, params: buildResult.1, jumpType: .push)
        TheRouter.shareInstance.logcat?(buildResult.0, .logNormal, "")
        return TheRouter.openURL(result)
    }
    
    public func navigation(_ handler: ComplateHandler = nil) {
        TheRouter.openURL(buildResult, complateHandler: handler)
    }
}
