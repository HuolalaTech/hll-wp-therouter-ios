//
//  TheRouterBaseBViewController.m
//  TheRouter_Example
//
//  Created by mars.yao on 2024/4/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "TheRouterBaseBViewController.h"
#import <TheRouter/TheRouter-Swift.h>

NSString *const TheRouterTabBarSelecIndex = @"tabBarSelecIndex";
@implementation TheRouterBaseBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        
        [TheRouerBridge openURL:@"scheme://router/tabbar?jumpType=5" userInfo:@{TheRouterTabBarSelecIndex: @1} complateHandler:^(NSDictionary<NSString *,id> *  queries, UIViewController * resultVC) {
                    
        }];
    });
}

#pragma mark - ------------TheRouterableProxy------------
/// 重写实现协议中的类方法
+ (NSArray<NSString *>*)patternString {
    return @[@"scheme://router/baseB"];
}
@end
