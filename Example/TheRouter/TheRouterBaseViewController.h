//
//  TheRouterBaseViewController.h
//  TheRouter_Example
//
//  Created by mars.yao on 2024/4/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>



NS_ASSUME_NONNULL_BEGIN

// 定义Block类型
typedef void (^QRResultBlock)(NSString *qrResult, BOOL qrStatus);


@interface TheRouterBaseViewController : UIViewController

@property (strong, nonatomic) NSDictionary *params; //!< 参数

@end

NS_ASSUME_NONNULL_END
