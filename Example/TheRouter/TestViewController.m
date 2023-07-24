//
//  TestViewController.m
//  TheRouter_Example
//
//  Created by Zed on 2023/2/10.
//  Copyright © 2023 zed.wang. All rights reserved.
//

#import "TestViewController.h"

@interface TestViewController ()

@end

@implementation TestViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = UIColor.whiteColor;
}

- (void)dealloc
{
    !self.the_routerInfo.openCompleteHandler ?: self.the_routerInfo.openCompleteHandler(@"dealloc", @{@"key":self.title});
}

@end
