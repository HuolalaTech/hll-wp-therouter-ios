//
//  TheRouterableProxy.h
//  TheRouter
//
//  Created by mars.yao on 2024/4/8.
//

#import <Foundation/Foundation.h>

typedef NS_OPTIONS(NSUInteger, TheRouterPriority) {
    TheRouterPriorityLow = 1000,
    TheRouterPriorityDefault = 1001,
    TheRouterPriorityHeight = 1002
};

NS_ASSUME_NONNULL_BEGIN

@protocol TheRouterableProxy <NSObject>

// 使用类方法替代静态属性
+ (NSArray<NSString *> *)patternString;

@optional
+ (NSUInteger)priority;

@end

NS_ASSUME_NONNULL_END
