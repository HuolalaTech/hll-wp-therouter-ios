//
//  TheRouterTabBarController.m
//  TheRouter_Example
//
//  Created by 姚亚杰 on 2024/5/31.
//  Copyright © 2024 CocoaPods. All rights reserved.
//

#import "TheRouterTabBarController.h"
#import <TheRouter/TheRouterableProxy.h>

@interface TheRouterTabBarController () <TheRouterableProxy>

@end

@implementation TheRouterTabBarController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}

+ (instancetype)sharedInstance {
    static TheRouterTabBarController *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[TheRouterTabBarController alloc] init];
    });
    return instance;
}

- (instancetype)copyWithZone:(NSZone *)zone {
    return self;
}

- (instancetype)mutableCopyWithZone:(NSZone *)zone {
    return self;
}

+ (NSArray<NSString *> *)patternString {
    return @[@"scheme://router/tabbar"];
}

+ (NSUInteger)priority { 
    return TheRouterPriorityDefault;
}

+ (id)registerActionWithInfo:(NSDictionary<NSString *, id> *)info {
    TheRouterTabBarController *vc = self.class.new;
    return vc;
}


@end
