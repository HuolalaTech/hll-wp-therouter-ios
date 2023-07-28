//
//  ViewController.m
//  TheRouter
//
//  Created by zed.wang on 02/09/2023.
//  Copyright (c) 2023 zed.wang. All rights reserved.
//

#import "ViewController.h"
#import "TheRouter_Mappings.h"
#import <TheRouter/TheRouter+Annotation.h>

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    // 全局失败回调
    TheRouter.shared.globalOpenFailedHandler = ^id _Nullable(TheRouterInfo * _Nonnull router) {
        NSLog(@"not found route %@", router);
        return nil;
    };
    
    // 注册重定向
    [TheRouter.shared registRedirect:@"demo://therouter.com/test" to:@"demo://therouter.com/vc"];
    
    // 注册拦截器，可以用于不同host/path路由事件的拦截及监听
    [TheRouter.shared registInterceptorForURLString:@"demo://therouter.com/*" handler:^BOOL(TheRouterInfo * _Nonnull router, id  _Nullable (^ _Nonnull continueHandle)(void)) {
        NSLog(@"will execute route %@", router);
        return YES;
    }];
}

- (IBAction)btnAction:(id)sender
{
    id value = [TheRouter.shared openPath:kRouterPathTestJumpSel hanlder:^(NSString * _Nonnull tag, NSDictionary * _Nullable result) {
        NSLog(@"%@", result);
    }];
    NSLog(@"%@", value);
}

@end
