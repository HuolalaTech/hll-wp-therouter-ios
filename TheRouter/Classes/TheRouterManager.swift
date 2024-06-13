//
//  TheRouterManager.swift
//  TheRouter
//
//  Created by mars.yao on 2023/7/27.
//

import Foundation
import UIKit

/// 对于KVO监听，动态创建子类，需要特殊处理
public let NSKVONotifyingPrefix = "KVONotifying_"

/// 神策动态类
public let kSADelegateClassSensorsSuffix = "_CN.SENSORSDATA"

/// 排除苹果系统类
public let kSAppleSuffix = "com.apple"

/// 排除cocoaPods相关库
public let kSCocoaPodsSuffix = "org.cocoapods"

public class TheRouterManager: NSObject {
    
    static public let shareInstance = TheRouterManager()
    
    // 是否使用缓存
    public var useCache: Bool = false
    
    // MARK: - 注册路由
    /// - Parameters:
    ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
    ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    ///   - urlPath: 将要打开的路由path
    ///   - userInfo: 路由传递的参数
    ///   - forceCheckEnable: 是否支持强制校验，强制校验要求Api声明与对应的类必须实现TheRouterAble协议
    public static func addGloableRouter(_ excludeCocoapods: Bool = false,
                                        _ urlPath: String,
                                        _ userInfo: [String: Any],
                                        forceCheckEnable: Bool = false) -> Any? {
        
        TheRouter.globalOpenFailedHandler { (info) in
            guard let matchFailedKey = info[TheRouter.matchFailedKey] as? String else { return }
            debugPrint(matchFailedKey)
            TheRouter.shareInstance.logcat?("TheRouter: globalOpenFailedHandler", .logError, "\(matchFailedKey)")
        }
        
        return TheRouterManager.registerRouterMap(excludeCocoapods, urlPath, userInfo, forceCheckEnable: forceCheckEnable)
    }
    
    // MARK: -注册web与服务调用
    public static func injectRouterServiceConfig(_ webPath: String?, _ serviceHost: String) {
        TheRouter.injectRouterServiceConfig(webPath, serviceHost)
    }
}

extension TheRouterManager {
    
    /// 类名和枚举值的映射表
    static var apiArray = [String]()
    static var classMapArray = [String]()
    static var registerRouterList: Array = [[String: String]]()
    
    // MARK: - 自动注册路由
    /// 获取符合注册条件的路由类
    /// - Parameters:
    ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
    ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    ///   - urlPath: 将要打开的路由path
    ///   - userInfo: 路由传递的参数
    ///   - forceCheckEnable: 是否支持强制校验，强制校验要求Api声明与对应的类必须实现TheRouterAble协议
    public class func registerRouterMap(_ excludeCocoapods: Bool = false,
                                        _ urlPath: String,
                                        _ userInfo: [String: Any],
                                        forceCheckEnable: Bool = false) -> Any? {
        
        let beginRegisterTime = CFAbsoluteTimeGetCurrent()
        
        if registerRouterList.isEmpty {
            registerRouterList = self.fetchRouterRegisterClass(excludeCocoapods)
        }
        for item in registerRouterList {
            var priority: UInt32 = 0
            if let number = UInt32(item[TheRouterPriority] ?? "0") {
                priority = number
            }
            TheRouter.addRouterItem(patternString: item[TheRouterPath] ?? "", priority: priority, classString: item[TheRouterClassName] ?? "")
        }
        let endRegisterTime = CFAbsoluteTimeGetCurrent()
        TheRouter.routerLoadStatus(true)
        if TheRouterManager.shareInstance.useCache {
            TheRouter.shareInstance.logcat?("使用缓存注册路由耗时：\(endRegisterTime - beginRegisterTime)", .logNormal, "")
        } else {
            TheRouter.shareInstance.logcat?("未使用缓存注册路由耗时：\(endRegisterTime - beginRegisterTime)", .logNormal, "")
        }
        if forceCheckEnable {
#if DEBUG
           routerForceRecheck(excludeCocoapods)
#endif
        }

        return TheRouter.openURL(urlPath, userInfo: userInfo)
    }
    
    
    /// 获取符合注册条件的路由类
    /// - Parameters:
    ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
    ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    ///   - useCache: 是否使用本地缓存
    public class func loadRouterClass(excludeCocoapods: Bool = false,
                                      useCache: Bool = false) {
        TheRouterManager.shareInstance.useCache = useCache
        if TheRouterDebugTool.checkTracing() || !useCache {
            registerRouterList = self.fetchRouterRegisterClass(excludeCocoapods)
        } else {
            let cachePath = fetchCurrentVersionRouterCachePath()
            let fileExists = fileExists(atPath: cachePath)
            var cacheData: Array = [[String: String]]()
            if fileExists {
                cacheData = loadArrayDictFromJSON(path: cachePath)
            }
            
            if useCache && fileExists && !cacheData.isEmpty {
                registerRouterList = cacheData
            } else {
                registerRouterList = self.fetchRouterRegisterClass(excludeCocoapods)
            }
        }
    }
    
    
    // MARK: - 提前获取工程中符合路由注册条件的类
    /// - Parameters:
    ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
    ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    ///   - useCache: 是否使用本地缓存
    public class func fetchRouterRegisterClass(_ excludeCocoapods: Bool = false,
                                               _ localCache: Bool = false) -> [[String: String]] {
        let beginRegisterTime = CFAbsoluteTimeGetCurrent()
        
        var resultXLClass = [AnyClass]()
        
        let bundles = CFBundleGetAllBundles() as? [CFBundle]
        for bundle in bundles ?? [] {
            let identifier = CFBundleGetIdentifier(bundle);
            
            if let id = identifier as? String {
                if excludeCocoapods {
                    if  id.hasPrefix(kSAppleSuffix) || id.hasPrefix(kSCocoaPodsSuffix) {
                        continue
                    }
                } else {
                    if  id.hasPrefix(kSAppleSuffix) {
                        continue
                    }
                }
            }
            
            guard let execURL = CFBundleCopyExecutableURL(bundle) as NSURL? else { continue }
            let imageURL = execURL.fileSystemRepresentation
            let classCount = UnsafeMutablePointer<UInt32>.allocate(capacity: MemoryLayout<UInt32>.stride)
            guard let classNames = objc_copyClassNamesForImage(imageURL, classCount) else {
                continue
            }
            
            
            for idx in 0..<classCount.pointee {
                let currentClassName = String(cString: classNames[Int(idx)])
                guard let currentClass = NSClassFromString(currentClassName) else {
                    continue
                }
                
                if class_getInstanceMethod(currentClass, NSSelectorFromString("methodSignatureForSelector:")) != nil,
                   class_getInstanceMethod(currentClass, NSSelectorFromString("doesNotRecognizeSelector:")) != nil {
                    if let cls =  currentClass as? UIViewController.Type {
                        resultXLClass.append(cls)
                    }
                    
#if DEBUG
                    if let clss = currentClass as? CustomRouterInfo.Type {
                        apiArray.append(clss.patternString)
                        classMapArray.append(clss.routerClass)
                    }
#endif
                }
            }
        }
        
        
        for i in 0 ..< resultXLClass.count {
            let currentClass: AnyClass = resultXLClass[i]
         
            if let cls = currentClass as? TheRouterable.Type {
                let fullName: String = NSStringFromClass(currentClass.self)
                if fullName.contains(kSADelegateClassSensorsSuffix)  {
                    break
                }
                
                for s in 0 ..< cls.patternString.count {
                    if fullName.contains(NSKVONotifyingPrefix) {
                        let range = fullName.index(fullName.startIndex, offsetBy: NSKVONotifyingPrefix.count)..<fullName.endIndex
                        let subString = fullName[range]
                        registerRouterList.append([TheRouterPath: cls.patternString[s], TheRouterClassName: "\(subString)", TheRouterPriority: "\(cls.priority)"])
                    } else {
                        registerRouterList.append([TheRouterPath: cls.patternString[s], TheRouterClassName: fullName, TheRouterPriority: "\(cls.priority)"])
                    }
                }
            } else if currentClass.self.conforms(to: TheRouterableProxy.self) {
                let fullName: String = NSStringFromClass(currentClass.self)
                if fullName.contains(kSADelegateClassSensorsSuffix)  {
                    break
                }
                
                for s in 0 ..< currentClass.patternString().count {
                    if fullName.contains(NSKVONotifyingPrefix) {
                        let range = fullName.index(fullName.startIndex, offsetBy: NSKVONotifyingPrefix.count)..<fullName.endIndex
                        let subString = fullName[range]
                        registerRouterList.append([TheRouterPath: currentClass.patternString()[s], TheRouterClassName: "\(subString)", TheRouterPriority: "\(String(describing: currentClass.priority()))"])
                    } else {
                        registerRouterList.append([TheRouterPath: currentClass.patternString()[s], TheRouterClassName: fullName, TheRouterPriority: "\(String(describing: currentClass.priority()))"])
                    }
                }
            }
        }
        let endRegisterTime = CFAbsoluteTimeGetCurrent()
        TheRouter.shareInstance.logcat?("提前获取工程中符合路由注册条件的类耗时：\(endRegisterTime - beginRegisterTime)", .logNormal, "")
        writeRouterMapToFile(mapArray: registerRouterList)
        return registerRouterList
    }
    
    // MARK: - 如果使用本地缓存，需要再次动态获取注册类来进行debug环境下的一致性教研
    /// - Parameters:
    ///   - excludeCocoapods: 排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是
    ///   org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    class func runtimeRouterList(_ excludeCocoapods: Bool = false) {
        
        let bundles = CFBundleGetAllBundles() as? [CFBundle]
        for bundle in bundles ?? [] {
            let identifier = CFBundleGetIdentifier(bundle);
            
            if let id = identifier as? String {
                if excludeCocoapods {
                    if  id.hasPrefix(kSAppleSuffix) || id.hasPrefix(kSCocoaPodsSuffix) {
                        continue
                    }
                } else {
                    if  id.hasPrefix(kSAppleSuffix) {
                        continue
                    }
                }
            }
            
            guard let execURL = CFBundleCopyExecutableURL(bundle) as NSURL? else { continue }
            let imageURL = execURL.fileSystemRepresentation
            let classCount = UnsafeMutablePointer<UInt32>.allocate(capacity: MemoryLayout<UInt32>.stride)
            guard let classNames = objc_copyClassNamesForImage(imageURL, classCount) else {
                continue
            }
            
            for idx in 0..<classCount.pointee {
                let currentClassName = String(cString: classNames[Int(idx)])
                guard let currentClass = NSClassFromString(currentClassName) else {
                    continue
                }
                
                if class_getInstanceMethod(currentClass, NSSelectorFromString("methodSignatureForSelector:")) != nil,
                   class_getInstanceMethod(currentClass, NSSelectorFromString("doesNotRecognizeSelector:")) != nil  {
                    if let clss = currentClass as? CustomRouterInfo.Type {
                        apiArray.append(clss.patternString)
                        classMapArray.append(clss.routerClass)
                    }
                }
            }
        }
    }
    
    // MARK: - 自动注册服务
    /// 自动注册服务
    /// - Parameter excludeCocoapods:排除一些非业务注册类，这里一般会将 "com.apple", "org.cocoapods" 进行过滤，但是如果组件化形式的，创建的BundleIdentifier也是 org.cocoapods，这里需要手动改下，否则组件内的类将不会被获取。
    public class func registerServices(excludeCocoapods: Bool = false) {
        let beginRegisterTime = CFAbsoluteTimeGetCurrent()
        let bundles = CFBundleGetAllBundles() as? [CFBundle]
        for bundle in bundles ?? [] {
            let identifier = CFBundleGetIdentifier(bundle);
            
            if let id = identifier as? String {
                if excludeCocoapods {
                    if  id.hasPrefix(kSAppleSuffix) || id.hasPrefix(kSCocoaPodsSuffix) {
                        continue
                    }
                } else {
                    if  id.hasPrefix(kSAppleSuffix) {
                        continue
                    }
                }
            }
            
            guard let execURL = CFBundleCopyExecutableURL(bundle) as NSURL? else { continue }
            let imageURL = execURL.fileSystemRepresentation
            let classCount = UnsafeMutablePointer<UInt32>.allocate(capacity: MemoryLayout<UInt32>.stride)
            guard let classNames = objc_copyClassNamesForImage(imageURL, classCount) else {
                continue
            }
            
            for idx in 0..<classCount.pointee {
                let currentClassName = String(cString: classNames[Int(idx)])
                guard let currentClass = NSClassFromString(currentClassName) else {
                    continue
                }
                if class_getInstanceMethod(currentClass, NSSelectorFromString("methodSignatureForSelector:")) != nil,
                   class_getInstanceMethod(currentClass, NSSelectorFromString("doesNotRecognizeSelector:")) != nil,
                   let cls = currentClass as? TheRouterServiceProtocol.Type {
                    TheRouterServiceManager.default.registerService(named: cls.seriverName, lazyCreator: (cls as! NSObject.Type).init())
                }
            }
        }
        
        let endRegisterTime = CFAbsoluteTimeGetCurrent()
        TheRouter.shareInstance.logcat?("服务注册耗时：\(endRegisterTime - beginRegisterTime)", .logNormal, "")
    }
    
    // MARK: - 重定向、剔除、新增、重置路由
    public static func addRelocationHandle(routerMapList: [TheRouterInfo] = []) {
        // 数组为空 return
        if routerMapList.count == 0 {
            return
        }
        // 新增的重定向信息转模型
        var currentRouterInfo = [TheRouterInfo]()
        for routerInfoInstance in routerMapList {
            
            if routerInfoInstance.routerType == TheRouterReloadMapEnum.add.rawValue {
                TheRouter.addRouterItem(routerInfoInstance.path ?? "", classString: routerInfoInstance.className ?? "")
            } else if routerInfoInstance.routerType == TheRouterReloadMapEnum.delete.rawValue {
                TheRouter.removeRouter(routerInfoInstance.path ?? "")
            } else if routerInfoInstance.routerType == TheRouterReloadMapEnum.replace.rawValue ||
                        routerInfoInstance.routerType == TheRouterReloadMapEnum.reset.rawValue {
                currentRouterInfo.append(routerInfoInstance)
            }
        }
        // 模型转化后的数组为空 return
        if currentRouterInfo.count == 0 {
            return
        }
        // 老的重定向数据map
        let routerInfoList: [TheRouterInfo] = TheRouter.shareInstance.reloadRouterMap
        var routerInfoMap: [String: TheRouterInfo] = [String: TheRouterInfo]()
        for list in routerInfoList {
            routerInfoMap[list.orginPath ?? ""] = list
        }
        // 数据对比
        // routerType为delete时
        // orginPath与targetPath一致时，删除所有orginPath的重定向数据
        // orginPath与targetPath不一致时，删除原有orginPath的重定向数据，存储新的orginPath数据并把routerType改为add
        for info in currentRouterInfo {
            if info.routerType == TheRouterReloadMapEnum.reset.rawValue {
                // 如果已经存在相同orginPath的数据 需要先remove
                if routerInfoMap[info.orginPath ?? ""] != nil {
                    routerInfoMap.removeValue(forKey: info.orginPath ?? "")
                }
                if info.orginPath != info.targetPath {
                    var routerInfo = info
                    routerInfo.routerType = TheRouterReloadMapEnum.replace.rawValue
                    routerInfoMap[routerInfo.orginPath ?? ""] = routerInfo
                }
            } else if info.routerType == TheRouterReloadMapEnum.replace.rawValue {
                routerInfoMap[info.orginPath ?? ""] = info
            }
        }
        // [String: TheRouterInfo] 转 [TheRouterInfo]
        var resultInfo = [TheRouterInfo]()
        for (_, routerInfo) in routerInfoMap {
            resultInfo.append(routerInfo)
        }
        TheRouter.shareInstance.reloadRouterMap = resultInfo
    }
    
    // MARK: - 客户端强制校验，是否匹配
    public static func routerForceRecheck(_ excludeCocoapods: Bool = false) {
        TheRouterManager.runtimeRouterList(excludeCocoapods)
        let paths = registerRouterList.compactMap { $0[TheRouterPath] }
        let patternArray = Set(paths)
        let apiPathArray = Set(apiArray)
        let diffArray = patternArray.symmetricDifference(apiPathArray)
        debugPrint("URL差集：\(diffArray)")
        debugPrint("registerRouterList：\(registerRouterList)")
        assert(diffArray.count == 0, "URL 拼写错误，请确认差集中的url是否匹配")
        
        let classNames = registerRouterList.compactMap { $0[TheRouterClassName] }
        let patternValueArray = Set(classNames)
        let classPathArray = Set(classMapArray)
        let diffClassesArray = patternValueArray.symmetricDifference(classPathArray)
        debugPrint("classes差集：\(diffClassesArray)")
        assert(diffClassesArray.count == 0, "classes 拼写错误，请确认差集中的class是否匹配")
    }
    
    // MARK: - 路由映射文件导出
    public static func writeRouterMapToFile(mapArray: [[String: String]]) {
        // 输出plist文件到指定的路径
        let resultJSONPath = fetchCurrentVersionRouterCachePath()
        var jsonData: Data
        do {
            jsonData = try JSONSerialization.data(withJSONObject: mapArray, options: [])
        } catch {
            print("Error converting array to JSON: \(error)")
            return
        }
        
        let url = URL(fileURLWithPath: resultJSONPath)
        try! jsonData.write(to: url, options: .atomic)
    }
    
    public static func fetchCurrentVersionRouterCachePath() -> String {
        let appVersion = (Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as? String) ?? ""
        // 获得沙盒的根路径
        let home = NSHomeDirectory() as NSString
        // 获得Documents路径，使用NSString对象的appendingPathComponent()方法拼接路径
        let plistPath = home.appendingPathComponent("Documents") as NSString
        // 输出plist文件到指定的路径
        let resultJSONPath = "\(plistPath)/\(appVersion)_routerMap.json"
        TheRouter.shareInstance.logcat?("路由缓存文件地址：\(resultJSONPath)", .logNormal, "")
        return resultJSONPath
    }
    
    static func fileExists(atPath path: String) -> Bool {
        return FileManager.default.fileExists(atPath: path)
    }
    
    static func loadArrayDictFromJSON(path: String) -> [[String: String]] {
        let url = URL(fileURLWithPath: path)
        
        do {
            let jsonData = try Data(contentsOf: url)
            if let arrayDict = try JSONSerialization.jsonObject(with: jsonData, options: []) as? [[String: String]] {
                return arrayDict
            }
        } catch {
            return [[String: String]]()
        }
        return [[String: String]]()
    }
    
}
