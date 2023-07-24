//
//  TheRouterTests.m
//  TheRouterTests
//
//  Created by zed.wang on 02/09/2023.
//  Copyright (c) 2023 zed.wang. All rights reserved.
//

@import XCTest;
#import <TheRouter/TheRouter+Annotation.h>

@interface Tests : XCTestCase

@end

@implementation Tests

- (void)setUp
{
    [super setUp];
    // Put setup code here. This method is called before the invocation of each test method in the class.
}

- (void)tearDown
{
    // Put teardown code here. This method is called after the invocation of each test method in the class.
    [super tearDown];
}

- (void)testExample
{
    NSMutableArray *urls = [NSMutableArray new];
    for (int i = 0; i < 10000; i++) {
        NSString *url = [NSString stringWithFormat:@"hd://com.therouter.test/%@", @(i)];
        [urls addObject:url];
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [TheRouter.shared registURLString:url openHandler:^id _Nullable(TheRouterInfo * _Nonnull router) {
                NSLog(@"%@", router.URLString); return nil;
            }];
        });
    }
    
    for (NSString *url in urls) {
        dispatch_async(dispatch_get_global_queue(0, 0), ^{
            [TheRouter.shared openURLString:url];
        });
    }
}

@end

