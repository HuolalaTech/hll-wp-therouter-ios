//
//  ViewController.swift
//  TheRouter
//
//  Created by mars.yao on 11/10/2021.
//  Copyright (c) 2021 CocoaPods. All rights reserved.
//

import UIKit
import TheRouter
import Toast
import JKSwiftExtension

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var tableView: UITableView!
    
    var resultDataSource: [[String]] = [["路由动态注册，只需实现RouterAble协议或者RouterAbleProxy协议即可",
                                         "多种注册路由方式",
                                         "动态注册路由并打开",
                                         "懒加载注册路由并打开",
                                         "注册路由是否正确的本地安全检查",
                                         "动态注册路由的性能优化部分",
                                         "OC类路由的动态注册实现",
                                         "OC类路由包含基类的主动注册实现",
                                         "动态注册中KVO派生子类处理",
                                         "缓存跳转",
                                         "是否可打开路由"],
                                        ["无参数跳转",
                                         "有参数跳转",
                                         "多参数类型跳转",
                                         "链式构造器跳转",
                                         "clouse回调参数跳转",
                                         "传递model模型跳转",
                                         "打开web界面",
                                         "打开路由回调方式",
                                         "tabbar跳转"],
                                        ["路由重定向能力",
                                         "重定向移除",
                                         "路由解决本地path编写错误",
                                         "路由适配不同的AndroidPath",
                                         "路由调用本地服务",
                                         "路由远端调用本地服务：服务接口下发，MQTT,JSBridge"]]
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "TheRouter"
        self.view.backgroundColor = .white
        self.tableView.delegate = self
        self.tableView.dataSource = self
        self.tableView.estimatedSectionFooterHeight = 0;
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "routerCell") ?? UITableViewCell.init()
        cell.textLabel?.text = resultDataSource[indexPath.section][indexPath.row]
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return resultDataSource[section].count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return resultDataSource.count
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30
    }
    
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return 0
    }
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UILabel.init(frame: CGRectMake(0, 0, UIScreen.main.bounds.size.width, 30))
        view.backgroundColor = UIColor.hexStringColor(hexString: "0xF2F3F4")
        view.textColor = .black
        view.font = .systemFont(ofSize: 12)
        view.textAlignment = .left
        switch section {
        case 0:
            view.text = "  路由注册介绍"
        case 1:
            view.text = "  路由跳转介绍"
        case 2:
            view.text = "  路由动态能力介绍"
        default:
            break
        }
        return view
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 50
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch indexPath.section {
        case 0:
            self.registerRouter(indexPath: indexPath)
        case 1:
            self.openRouter(indexPath: indexPath)
        case 2:
            self.dynamicRouter(indexPath: indexPath)
        default:
            break
        }
        
    }
    
    // MARK: - 注册路由介绍
    func registerRouter(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            TheRouter.openURL(TheRouterBApi().requiredURL)
            if let window = UIApplication.shared.delegate?.window {
                window?.makeToast("路由是动态注册的，在AppDelegate中初始化成功，会自动注册，只需要在需要打开时调用openURL即可", duration: 1, position: window?.center)
            }
        case 1:
            TheRouter.addRouterItem(RouteItem(path: "scheme://router/demo?&desc=简单注册,直接调用TheRouter.addRouterItem()注册即可", className: "TheRouter_Example.TheRouterController"))
            TheRouter.addRouterItem(["scheme://router/demo?&desc=简单注册,直接调用TheRouter.addRouterItem()注册即可": "TheRouter_Example.TheRouterController"])
            TheRouter.addRouterItem("scheme://router/demo?&desc=简单注册", classString: "TheRouter_Example.TheRouterController")
            TheRouter.addRouterItem(TheRouterApi.patternString, classString: TheRouterApi.routerClass)
            TheRouter.addRouterItem(TheRouterAApi.patternString, classString: TheRouterAApi.routerClass)
            TheRouter.addRouterItem(["scheme://router/demo?&desc=简单注册,直接调用TheRouter.addRouterItem()注册即可": "TheRouter_Example.TheRouterController",
                                     "scheme://router/demo1": "TheRouter_Example.TheRouterControllerA"])
            let wrapper = TheRouerParamsClosureWrapper { params in
                print("Received params: \(params)")
                self.view .makeToast("\(params)")
            }
            TheRouter.openURL(("scheme://router/demo1?id=2&value=3&name=AKyS&desc=直接调用TheRouter.addRouterItem()注册即可，支持单个注册，批量注册字典形式，动态注册TheRouterManager.addGloableRouter，懒加载动态注册 TheRouter.lazyRegisterRouterHandle ",["qrResultCallBack": wrapper]))
            
        case 2:
            let wrapper = TheRouerParamsClosureWrapper { params in
                print("Received params: \(params)")
                self.view .makeToast("\(params)")

            }
            TheRouter.openURL(("scheme://router/demo1?id=2&value=3&name=AKyS&desc=动态注册使用runtime遍历工程类，将路由path与对应的class映射进行存储，进行跳转时，映射解析跳转详情查看Function: TheRouterManager.addGloableRouter",["qrResultCallBack": wrapper]))
        case 3:
            let wrapper = TheRouerParamsClosureWrapper { params in
                print("Received params: \(params)")
                self.view .makeToast("\(params)")
            }
            TheRouter.openURL(("scheme://router/demo1?id=2&value=3&name=AKyS&desc=懒加载的动态注册是在动态注册的基础上，为了解决App初始化就遍历解析的性能问题，只有当用户第一次使用路由打开界面或服务时，才进行动态注册并打开路由,详情查看Function: TheRouterManager.lazyRegisterRouterHandle Clouse回调",["qrResultCallBack": wrapper]))
        case 4:
            TheRouter.openURL("scheme://router/baseB?id=2&value=3&name=AKyS&desc=安全检查是指为了垮模块进行调用，我们统一使用了实现CustomRouterInfo协议的抽象类来管理路由的path与class映射关系，在注册之后，runtime动态注册与抽象类的数据结构映射是否正确，具体实现：TheRouterManager.routerForceRecheck方法中")
        case 5:
            
            let wrapper = TheRouerParamsClosureWrapper { params in
                print("Received params: \(params)")
                self.view .makeToast("\(params)")
            }
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            TheRouter.openURL(("scheme://router/demo?id=2&value=3&name=AKyS&desc=通过TheRouterManager.addGloableRouter()传入registerClassPrifxArray参数，将指定遍历工程中具有特性前缀名的class，降低遍历数量级，减少性能损耗", ["model": model, "qrResultCallBack": wrapper]))
        case 6:
            TheRouter.openURL(TheRouterBApi().requiredURL)
        case 7:
            
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            TheRouter.openURL(("scheme://router/demo2?id=2&value=3&name=AKyS&desc=这是一个OC类的界面，实现路由的跳转需要继承OC类，并实现TheRouterAble协议即可", ["model": model]))
        case 8:
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            TheRouter.openURL(("scheme://router/baseA?id=2&value=3&name=AKyS&desc=基类的路由如何被覆盖重写", ["model": model]))
        case 9:
            TheRouter.openURL("scheme://router/demo9?desc=缓存跳转")
        case 10:
            let canOpenURl =  TheRouter.canOpenURL("scheme://router/demo9?desc=缓存跳转")
            self.view.makeToast(canOpenURl ? "可以打开" : "不可以打开")
        default:
            break
        }
    }
    
    // MARK: - 打开路由介绍
    func openRouter(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
//            TheRouter.openURL(TheRouterLAApi().requiredURL)
            TheRouter.openURL("scheme://router/class_prex_test?value=3&name=AKyS")
        
        case 1:
            TheRouter.openURL("scheme://router/demo?id=2&value=3&name=AKyS")
        case 2:
            TheRouter.openURL(("scheme://router/demo?id=3", ["value": 3, "name": "AKyS"]))
        case 3:
            
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            
            TheRouterBuilder.build("scheme://router/demo")
                .withInt(key: "intValue", value: 2)
                .withString(key: "stringValue", value: "sdsd")
                .withFloat(key: "floatValue", value: 3.1415)
                .withBool(key: "boolValue", value: false)
                .withDouble(key: "doubleValue", value: 2.0)
                .withAny(key: "any", value: model)
                .navigation { params, instance in
                    
                }
            
        case 4:
            let wrapper = TheRouerParamsClosureWrapper { params in
                print("Received params: \(params)")
            }
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            TheRouter.openURL(("scheme://router/demo?id=2&value=3&name=AKyS", ["model": model, "qrResultCallBack": wrapper]))
        case 5:
            
            let model = TheRouterModel.init(name: "AKyS", age: 18)
            TheRouter.openURL(("scheme://router/demo?id=2&value=3&name=AKyS", ["model": model]))
        case 6:
            TheRouter.openWebURL("https://therouter.cn/")
        case 7:
            TheRouter.openURL("https://therouter.cn/" ) { param, instance in
                // 可以在这里进行移除导航栈操作
                debugPrint("\(param ?? [:]) \(instance ?? "")")
            }
        case 8:
            TheRouter.openURL("scheme://router/tabbar?jumpType=5&tabBarSelecIndex=1")
        default:
            break
        }
    }
    
    func dynamicRouter(indexPath: IndexPath) {
        switch indexPath.row {
        case 0:
            let relocationMap: NSDictionary = ["routerType": 1, "targetPath": "scheme://router/demo1", "orginPath": "scheme://router/demo"]
            let data = try! JSONSerialization.data(withJSONObject: relocationMap, options: [])
            let routeReMapInfo = try! JSONDecoder().decode(TheRouterInfo.self, from: data)
            TheRouterManager.addRelocationHandle(routerMapList: [routeReMapInfo])
            TheRouter.openURL("scheme://router/demo?desc=跳转白色界面被重定向到了黄色界面")
        case 1:
            
            let relocationMap: NSDictionary = ["routerType": 4, "targetPath": "scheme://router/demo", "orginPath": "scheme://router/demo"]
            let data = try! JSONSerialization.data(withJSONObject: relocationMap, options: [])
            let routeReMapInfo = try! JSONDecoder().decode(TheRouterInfo.self, from: data)
            TheRouterManager.addRelocationHandle(routerMapList: [routeReMapInfo])
            TheRouter.openURL("scheme://router/demo?desc=跳转白色界面被重定向到了黄色界面之后，根据下发数据又恢复到跳转白色界面")
        case 2:
            let relocationMap: NSDictionary = ["routerType": 2, "className": "TheRouter_Example.TheRouterControllerC", "path": "scheme://router/demo33"]
            let data = try! JSONSerialization.data(withJSONObject: relocationMap, options: [])
            let routeReMapInfo = try! JSONDecoder().decode(TheRouterInfo.self, from: data)
            TheRouterManager.addRelocationHandle(routerMapList: [routeReMapInfo])
            let value = TheRouterCApi.init().requiredURL
            TheRouter.openURL(value)
            
        case 3:
            let relocationMap: NSDictionary = ["routerType": 2, "className": "TheRouter_Example.TheRouterControllerD", "path": "scheme://router/demo5"]
            let data = try! JSONSerialization.data(withJSONObject: relocationMap, options: [])
            let routeReMapInfo = try! JSONDecoder().decode(TheRouterInfo.self, from: data)
            TheRouterManager.addRelocationHandle(routerMapList: [routeReMapInfo])
            TheRouter.openURL("scheme://router/demo5?desc=demo5是Android一个界面的Path,为了双端统一，我们动态增加一个Path,这样远端下发时demo5也就能跳转了")
        case 4:
            if let appConfigService = TheRouter.getService(AppConfigServiceProtocol.self) {
                appConfigService.openMiniProgram(info: [:])
            }
            
            if let routerService = TheRouter.getService(AppRouterProtocol.self) {
                routerService.openRouter(info: [:])
            }
            TheRouter.openURL("scheme://router/demo?desc=通过TheRouter.createService(AppConfigLAServiceProtocol.self)协议调用接口服务，实现本地的服务调用")
        case 5:
            _ = TheRouter.createService(AppConfigServiceProtocol.self)
            let dict: [String: Any] = ["ivar1": ["key":"value"], "resultType": 0]
            let url = "scheme://services?protocol=AppConfigServiceProtocol&method=openMiniProgramWithInfo:"
            TheRouter.openURL((url, dict))
        default:
            break
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}

