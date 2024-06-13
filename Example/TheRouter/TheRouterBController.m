//
//  TheRouterBController.m
//  TheRouter_Example
//
//  Created by mars.yao on 2023/7/27.
//  Copyright © 2023 CocoaPods. All rights reserved.
//

#import "TheRouterBController.h"
@import TheRouter;
@interface TheRouterBController () <TheRouterableProxy>

@end

@implementation TheRouterBController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor yellowColor];
    [self.view addSubview:self.desLabel];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (self.resultBlock) {
            self.resultBlock(@"跳转成功了", true);
        }
    });
    // Do any additional setup after loading the view.
}

- (UILabel *)desLabel {
    if (!_desLabel) {
        _desLabel = [[UILabel alloc]initWithFrame:CGRectMake(([UIScreen mainScreen].bounds.size.width -300)/2, ([UIScreen mainScreen].bounds.size.height -200)/2, 300, 200)];
        _desLabel.font = [UIFont systemFontOfSize:12];
        _desLabel.numberOfLines = 0;
        _desLabel.textAlignment = NSTextAlignmentCenter;
        _desLabel.textColor = [UIColor blackColor];
    }
    return _desLabel;
}

// 实现协议中的类方法
+ (NSArray<NSString *> *)patternString {
    return @[@"scheme://router/demo2"];
}

@end
