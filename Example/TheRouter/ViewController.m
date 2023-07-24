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
    
//    [TheRouter.shared registRedirect:@"hd://com.therouter.test/test" to:@"hd://test.com/test/test/vc"];
//    TheRouter.shared.globalOpenFailedHandler = ^id _Nullable(TheRouterInfo * _Nonnull router) {
//        NSLog(@"not found router %@", router.URLString);
//        return nil;
//    };
    
    [TheRouter.shared registInterceptorForURLString:@"hd://com.therouter.test/*" handler:^BOOL(TheRouterInfo * _Nonnull router, id  _Nullable (^ _Nonnull continueHandle)(void)) {
        NSLog(@"will execute router %@", router.URLString);
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
