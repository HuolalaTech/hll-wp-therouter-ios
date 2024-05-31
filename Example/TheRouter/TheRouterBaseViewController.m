//
//  TheRouterBaseViewController.m
//  TheRouter_Example
//
//  Created by mars.yao on 2024/4/9.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "TheRouterBaseViewController.h"
@import TheRouter;

@interface TheRouterBaseViewController() <TheRouterableProxy>

@end
@implementation TheRouterBaseViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    NSLog(@"---> params = %@", self.params);
}

// 实现协议中的类方法
+ (NSArray<NSString *> *)patternString {
    return @[];
}

+ (NSUInteger)priority {
    return TheRouterPriorityDefault;
}

@end
