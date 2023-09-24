//
//  TheRouterServiceManager.swift
//
//  Created by mars.yao on 2021/9/1.
//

import Foundation

public typealias LAServiceCreator = () -> Any

public final class TheRouterServiceManager {
    
    public static let `default` = TheRouterServiceManager()
    
    public init() {}
    
    /// Service 同步
    private let serviceQueue = DispatchQueue(label: "scheme.TheRouterServiceManager.queue")
    /// Service构建者
    public var creatorsMap: [String: LAServiceCreator] = [:]
    /// service缓存
    public var servicesCache: [String: Any] = [:]
}


// MARK: - Service Register & Unregister
public extension TheRouterServiceManager {
    class func serviceName<T>(of value: T) -> String {
        return String(describing: value)
    }
    
    // MARK: - Register With Service Name
    /// 通过服务名称(named)注册LAServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - creator: 服务构造者
    func registerService(named: String, creator: @escaping LAServiceCreator) {
        serviceQueue.async {
            self.creatorsMap[named] = creator
        }
    }
    
    /// 通过服务名称(named)注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - named: 服务名称
    ///   - instance: 服务实例
    func registerService(named: String, instance: Any) {
        serviceQueue.async {
            self.servicesCache[named] = instance
        }
    }
    
    /// 通过服务名称(named)注册LAServiceCreator
    /// - Parameters:
    ///   - named: 服务名称
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    func registerService(named: String, lazyCreator: @escaping @autoclosure LAServiceCreator) {
        registerService(named: named, creator: lazyCreator)
    }
    
    // MARK: - Register With Service Type
    /// 通过服务接口注册LAServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - creator: 服务构造者
    func registerService<Service>(_ service: Service.Type, creator: @escaping () -> Service) {
        registerService(named: TheRouterServiceManager.serviceName(of: service), creator: creator)
    }
    
    /// 通过服务接口注册LAServiceCreator
    /// - Parameters:
    ///   - service: 服务接口
    ///   - lazyCreator: 延迟实例化构造者 (如：```registerService(named: "A", lazyCreator: A())```)
    func registerService<Service>(_ service: Service.Type, lazyCreator: @escaping @autoclosure () -> Service) {
        registerService(named: TheRouterServiceManager.serviceName(of: service), creator: lazyCreator)
    }
    
    /// 通过服务接口注册一个服务实例 (存在缓存中)
    /// - Parameters:
    ///   - service: 服务接口
    ///   - instance: 服务实例
    func registerService<Service>(_ service: Service.Type, instance: Service) {
        registerService(named: TheRouterServiceManager.serviceName(of: service), instance: instance)
    }
    
    // MARK: - Unregister Service
    
    /// 通过服务名称取消注册服务
    /// - Parameter named: 服务名称
    @discardableResult
    func unregisterService(named: String) -> Any? {
        return serviceQueue.sync {
            self.creatorsMap.removeValue(forKey: named)
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    /// 通过服务接口取消注册服务
    /// - Parameter service: 服务接口
    @discardableResult
    func unregisterService<Service>(_ service: Service) -> Service? {
        return unregisterService(named: TheRouterServiceManager.serviceName(of: service)) as? Service
    }
}

// MARK: - Register Batch Services
public extension TheRouterServiceManager {
    typealias BatchServiceMap = [String: LAServiceCreator]
    typealias ServiceEntry = BatchServiceMap.Element
    func registerService(_ services: BatchServiceMap) {
        serviceQueue.async {
            self.creatorsMap.merge(services, uniquingKeysWith: { _, v2 in v2 })
        }
    }
    
    func registerService(entryLiteral entries: ServiceEntry ...) {
        return registerService(BatchServiceMap(entries, uniquingKeysWith: {_, v2 in v2}))
    }
}

// MARK: - Service Create
public extension TheRouterServiceManager {
    /// 根据服务名称创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - named: 服务名称
    ///   - shouldCache: 是否需要缓存
    func createService(named: String, shouldCache: Bool = true) -> Any? {
        // 检查是否有缓存
        if let service = serviceQueue.sync(execute: { servicesCache[named] }) {
            return service
        }
        // 检查是否有构造者
        guard let creator = serviceQueue.sync(execute: { creatorsMap[named] }) else {
            return nil
        }
        
        let service = creator()
        if shouldCache {
            self.serviceQueue.async {
                self.servicesCache[named] = service
            }
        }
        return service
    }
    
    /// 根据服务接口创建服务（如果缓存中已有服务实例，则不需要创建）
    /// - Parameters:
    ///   - service: 服务接口
    ///   - shouldCache: 是否需要缓存
    func createService<Service>(_ service: Service.Type, shouldCache: Bool = true) -> Service? {
        return createService(named: TheRouterServiceManager.serviceName(of: service), shouldCache: shouldCache) as? Service
    }
}

// MARK: - Service Fetch
public extension TheRouterServiceManager {
    /// 通过服务名称获取服务
    /// - Parameter named: 服务名称
    func getService(named: String) -> Any? {
        return self.createService(named: named)
    }
    
    /// 通过服务接口获取服务
    /// - Parameter service: 服务接口
    func getService<Service>(_ service: Service.Type) -> Service? {
        return getService(named: TheRouterServiceManager.serviceName(of: service)) as? Service
    }
}


// MARK: - Service Clean Cache
public extension TheRouterServiceManager {
    func cleanAllServiceCache() {
        serviceQueue.async {
            self.servicesCache.removeAll()
        }
    }
    
    @discardableResult
    func cleanServiceCache(named: String) -> Any? {
        return serviceQueue.sync {
            return self.servicesCache.removeValue(forKey: named)
        }
    }
    
    @discardableResult
    func cleanServiceCache<Service>(by service: Service.Type) -> Service? {
        return cleanServiceCache(named: TheRouterServiceManager.serviceName(of: service)) as? Service
    }
}
