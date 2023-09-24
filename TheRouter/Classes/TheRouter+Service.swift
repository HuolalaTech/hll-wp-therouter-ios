//
//  TheRouter+Service.swift
//  TheRouter
//
//  Created by mars.yao on 2023/7/27.
//

import Foundation

public extension TheRouter {
    // MARK: - Register With Service Name
    /// 通过服务名称(named)注册LAServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - creator: 服务构造者
    class func registerService(named: String, creator: @escaping LAServiceCreator) {
        TheRouterServiceManager.default.registerService(named: named, creator: creator)
    }
    
    /// 通过服务名称(named)注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - named: 服务名称
    ///   - instance: 服务实例
    class func registerService(named: String, instance: Any) {
        TheRouterServiceManager.default.registerService(named: named, instance: instance)
    }
    
    /// 通过服务名称(named)注册LAServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    class func registerService(named: String, lazyCreator: @escaping @autoclosure LAServiceCreator) {
        TheRouterServiceManager.default.registerService(named: named, lazyCreator: lazyCreator)
    }
    
    // MARK: - Register With Service Type
    /// 通过服务接口注册LAServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - creator: 服务构造者
    class func registerService<Service>(_ service: Service.Type, creator: @escaping () -> Service) {
        TheRouterServiceManager.default.registerService(service, creator: creator)
    }
    
    /// 通过服务接口注册LAServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    class func registerService<Service>(_ service: Service.Type, lazyCreator: @escaping @autoclosure () -> Service) {
        TheRouterServiceManager.default.registerService(service, lazyCreator: lazyCreator())
    }
    
    /// 通过服务接口注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - service: 服务接口
    ///   - instance: 服务实例
    class func registerService<Service>(_ service: Service.Type, instance: Service) {
        TheRouterServiceManager.default.registerService(service, instance: instance)
    }
}

public extension TheRouter {
    
    /// 根据服务名称创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - named: 服务名称
    ///   - shouldCache: 是否需要缓存
    @discardableResult
    class func createService(named: String, shouldCache: Bool = true) -> Any? {
        return TheRouterServiceManager.default.createService(named: named)
    }
    
    /// 根据服务接口创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - service: 服务接口
    ///   - shouldCache: 是否需要缓存
    @discardableResult
    class func createService<Service>(_ service: Service.Type, shouldCache: Bool = true) -> Service? {
        return TheRouterServiceManager.default.createService(service)
    }
    
    /// 通过服务名称获取服务
    /// - Parameter named: 服务名称
    @discardableResult
    class func getService(named: String) -> Any? {
        return TheRouterServiceManager.default.getService(named: named)
    }
    
    /// 通过服务接口获取服务
    /// - Parameter service: 服务接口
    @discardableResult
    class func getService<Service>(_ service: Service.Type) -> Service? {
        return TheRouterServiceManager.default.getService(named: TheRouterServiceManager.serviceName(of: service)) as? Service
    }
}
