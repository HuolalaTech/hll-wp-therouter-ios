//
//  TheRouterBaseBViewController.m
//  TheRouter_Example
//
//  Created by mars.yao on 2024/4/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "TheRouterBaseBViewController.h"

@implementation TheRouterBaseBViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor brownColor];
    
}

#pragma mark - ------------TheRouterableProxy------------
/// 重写实现协议中的类方法
+ (NSArray<NSString *>*)patternString {
    return @[@"scheme://router/baseB"];
}
@end
