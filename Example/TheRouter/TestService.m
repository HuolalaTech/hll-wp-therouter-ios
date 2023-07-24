//
//  TestService.m
//  TheRouter_Example
//
//  Created by Zed on 2023/2/10.
//  Copyright © 2023 zed.wang. All rights reserved.
//

#import "TestService.h"
#import "TheRouter_Mappings.h"
#import <TheRouter/TheRouter+Annotation.h>

@implementation TestService

TheRouterSelector(test/jump, jumpToTestVC, TestService)
+ (id)jumpToTestVC:(TheRouterInfo *)routerInfo
{
    UIViewController *vc = [TheRouter.shared openVCPath:kRouterPathTestVcVC
                                                    cmd:TheRouterOpenCMDPush
                                             withParams:@{@"title":@"123"}
                                                hanlder:^(NSString * _Nonnull tag, NSDictionary * _Nullable result) {
        !routerInfo.openCompleteHandler ?: routerInfo.openCompleteHandler(tag, result);
    }];
    return vc;
}

@end
