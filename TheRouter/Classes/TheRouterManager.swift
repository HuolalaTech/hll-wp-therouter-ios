//
//  TheRouterManager.swift
//  TheRouter
//
//  Created by mars.yao on 2023/7/27.
//

import Foundation

/// 对于KVO监听，动态创建子类，需要特殊处理
public let NSKVONotifyingPrefix = "NSKVONotifying_"

public class TheRouterManager: NSObject {
    
    static public let shareInstance = TheRouterManager()
    
    // MARK: - 注册路由
    public static func addGloableRouter(_ registerClassPrifxArray: [String], _ urlPath: String, _ userInfo: [String: Any]) -> Any? {
        
        TheRouter.globalOpenFailedHandler { (info) in
            guard let matchFailedKey = info[TheRouter.matchFailedKey] as? String else { return }
            debugPrint(matchFailedKey)
            TheRouter.shareInstance.logcat?("TheRouter: globalOpenFailedHandler", .logError, "\(matchFailedKey)")
        }
        
        return TheRouterManager.registerRouterMap(registerClassPrifxArray, urlPath, userInfo)
    }
    
    // MARK: -注册web与服务调用
    public static func injectRouterServiceConfig(_ webPath: String?, _ serviceHost: String) {
        TheRouter.injectRouterServiceConfig(webPath, serviceHost)
    }
}

extension TheRouterManager {
    
    /// 类名和枚举值的映射表
    static var pagePathMap: Dictionary = [String: String]()
    static var apiArray = [String]()
    static var classMapArray = [String]()
    static var mapJOSN: Array = [[String: String]]()
    
    // MARK: - 自动注册路由
    public class func registerRouterMap(_ registerClassPrifxArray: [String], _ urlPath: String, _ userInfo: [String: Any]) -> Any? {
        
        let beginRegisterTime = CFAbsoluteTimeGetCurrent()
        
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        
        var resultXLClass = [AnyClass]()
        for i in 0 ..< actualClassCount {
            
            let currentClass: AnyClass = allClasses[Int(i)]
            let fullClassName: String = NSStringFromClass(currentClass.self)
            
            for value in registerClassPrifxArray {
                if (fullClassName.containsSubString(substring: value))  {
                    if (class_getInstanceMethod(currentClass, NSSelectorFromString("methodSignatureForSelector:")) != nil),
                       (class_getInstanceMethod(currentClass, NSSelectorFromString("doesNotRecognizeSelector:")) != nil), let cls =  currentClass as? UIViewController.Type {
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
                
                for s in 0 ..< cls.patternString.count {
                    
                    if fullName.hasPrefix(NSKVONotifyingPrefix) {
                        let range = fullName.index(fullName.startIndex, offsetBy: NSKVONotifyingPrefix.count)..<fullName.endIndex
                        let subString = fullName[range]
                        pagePathMap[cls.patternString[s]] = "\(subString)"
                        TheRouter.addRouterItem(cls.patternString[s], classString: "\(subString)")
                        mapJOSN.append(["path": cls.patternString[s], "class": "\(subString)"])
                    } else {
                        pagePathMap[cls.patternString[s]] = fullName
                        TheRouter.addRouterItem(cls.patternString[s], classString: fullName)
                        mapJOSN.append(["path": cls.patternString[s], "class": fullName])
                    }
                }
            }
        }
        
        let endRegisterTime = CFAbsoluteTimeGetCurrent()
        TheRouter.shareInstance.logcat?("注册路由耗时：\(endRegisterTime - beginRegisterTime)", .logNormal, "")
        TheRouter.routerLoadStatus(true)
#if DEBUG
        debugPrint(mapJOSN)
        writeRouterMapToFile(mapArray: mapJOSN)
        routerForceRecheck()
#endif
        return TheRouter.openURL(urlPath, userInfo: userInfo)
    }
    
    // MARK: - 自动注册服务
    public class func registerServices() {
        
        let expectedClassCount = objc_getClassList(nil, 0)
        let allClasses = UnsafeMutablePointer<AnyClass>.allocate(capacity: Int(expectedClassCount))
        let autoreleasingAllClasses = AutoreleasingUnsafeMutablePointer<AnyClass>(allClasses)
        let actualClassCount: Int32 = objc_getClassList(autoreleasingAllClasses, expectedClassCount)
        var resultXLClass = [AnyClass]()
        for i in 0 ..< actualClassCount {
            
            let currentClass: AnyClass = allClasses[Int(i)]
            if (class_getInstanceMethod(currentClass, NSSelectorFromString("methodSignatureForSelector:")) != nil),
               (class_getInstanceMethod(currentClass, NSSelectorFromString("doesNotRecognizeSelector:")) != nil),
               let cls = currentClass as? TheRouterServiceProtocol.Type {
                print(currentClass)
                resultXLClass.append(cls)
                
                TheRouterServiceManager.default.registerService(named: cls.seriverName, lazyCreator: (cls as! NSObject.Type).init())
            }
        }
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
    public static func routerForceRecheck() {
        let patternArray = Set(pagePathMap.keys)
        let apiPathArray = Set(apiArray)
        let diffArray = patternArray.symmetricDifference(apiPathArray)
        debugPrint("URL差集：\(diffArray)")
        debugPrint("pagePathMap：\(pagePathMap)")
        assert(diffArray.count == 0, "URL 拼写错误，请确认差集中的url是否匹配")
        
        let patternValueArray = Set(pagePathMap.values)
        let classPathArray = Set(classMapArray)
        let diffClassesArray = patternValueArray.symmetricDifference(classPathArray)
        debugPrint("classes差集：\(diffClassesArray)")
        assert(diffClassesArray.count == 0, "classes 拼写错误，请确认差集中的class是否匹配")
    }
    
    // MARK: - 路由映射文件导出
    public static func writeRouterMapToFile(mapArray: [[String: String]]) {
        debugPrint(mapJOSN)
        let array: NSArray = mapJOSN as NSArray
        
        // 获得沙盒的根路径
        let home = NSHomeDirectory() as NSString
        // 获得Documents路径，使用NSString对象的appendingPathComponent()方法拼接路径
        let plistPath = home.appendingPathComponent("Documents") as NSString
        // 输出plist文件到指定的路径
        let resultPath = "\(plistPath)/routerMap.plist"
        let resultJSONPath = "\(plistPath)/routerMap.json"
        
        debugPrint("routerMapPlist文件地址：\(resultPath)")
        debugPrint("routerMapJSON文件地址：\(resultJSONPath)")
        array.write(toFile: resultPath, atomically: true)
        
        let data = try! JSONSerialization.data(withJSONObject: mapJOSN,
                                               options: JSONSerialization.WritingOptions.prettyPrinted)
        let url = URL(fileURLWithPath: resultJSONPath)
        try! data.write(to: url, options: .atomic)
    }
}
