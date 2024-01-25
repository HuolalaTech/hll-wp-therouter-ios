//
//  ViewController.m
//  TheRouter-ObjectiveCDemo
//
//  Created by mars.yao on 2024/1/25.
//

#import "ViewController.h"
#import "TheRouter_ObjectiveCDemo-Swift.h"

@interface ViewController ()
- (IBAction)push:(id)sender;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.view.backgroundColor = [UIColor whiteColor];
    // Do any additional setup after loading the view.
}


- (IBAction)push:(id)sender {
    
    [TheRouterService openURL:TheRouterApi.patternString :[[[TheRouterApi alloc] init] generateParams] :^(NSDictionary * _Nullable params, NSObject * _Nullable classInstance) {
        
    }];
    // 下方为H5跳转Demo
    //    [TheRouterService openWebURL:@"https://therouter.cn/" :@{}];
}

@end
