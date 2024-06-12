//
//  TheRouerBridge.swift
//  HPPush
//
//  Created by mars.yao on 2024/5/14.
//

import Foundation

@objcMembers
public class TheRouerBridge: NSObject {
    
    public class func canOpenUrl(_ urlString: String) -> Bool {
      return TheRouter.canOpenURL(urlString)
    }
    
    // 方法1：根据URL字符串打开
    @discardableResult
    public class func openURL(_ urlString: String, userInfo: [String: Any] = [String: Any](), complateHandler: ComplateHandler = nil) -> Any? {
        return TheRouter.openURL(urlString, userInfo: userInfo, complateHandler: complateHandler)
    }
    
    
    // 方法2：根据URL元组打开
     @discardableResult
     public class func openURL(_ uriTuple: (String, [String: Any]), complateHandler: ComplateHandler = nil) -> Any? {
         return TheRouter.openURL(uriTuple, complateHandler: complateHandler)
     }

     // 方法3：根据URL元组打开WebURL
     @discardableResult
     public class func openWebURL(_ uriTuple: (String, [String: Any])) -> Any? {
         return TheRouter.openURL(uriTuple)
     }

     // 方法4：根据URL字符串打开WebURL
     @discardableResult
     public class func openWebURL(_ urlString: String, userInfo: [String: Any] = [String: Any]()) -> Any? {
         return TheRouter.openURL((urlString, userInfo))
     }
}
