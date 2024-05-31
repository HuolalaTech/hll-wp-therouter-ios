//
//  TheRouterBController.h
//  TheRouter_Example
//
//  Created by mars.yao on 2023/7/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TheRouterBaseViewController.h"
NS_ASSUME_NONNULL_BEGIN

@interface TheRouterBController : TheRouterBaseViewController

@property (nonatomic, copy) QRResultBlock resultBlock;

@property (nonatomic, strong) UILabel *desLabel;
@end

NS_ASSUME_NONNULL_END
