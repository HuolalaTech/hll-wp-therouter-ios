//
//  TheRouterDynamicParamsMapping.h
//  TheRouter
//
//  Created by mars.yao on 2023/7/27.
//

#import <Foundation/Foundation.h>

typedef struct ReturnStruct{
    __unsafe_unretained id        instanceObject;
    __unsafe_unretained id        returnValue;
}ReturnStruct;

@interface TheRouterDynamicParamsMapping : NSObject

@property (nonatomic, strong) NSArray *filterKey;

+ (instancetype)router;

/**
 初始化 类。可直接通过NSClassFromString 获取。在这里为保持陆游的美观。才写上
 
 @param className 类字符串名字
 @return 返回类对象
 */
- (Class)routerClassName:(NSString*)className;

/**
 初始化 类对象。获取类的初始化对象。
 
 @param className 类名
 @return 返回ReturnStruct结构体 包含实例对象 和 返回值。 类的初始化实例
 */
- (id)routerGetInstanceWithClassName:(NSString*)className;
@end


@interface NSObject (TheRouterClass)

/**
 实例子对象 给属性 赋值
 @param propertyParameter 属性字典组合。  key为属性的字符串。 value为属性需要赋予的值
 @return 返回
 */
- (ReturnStruct)setPropertyParameter:(NSDictionary*)propertyParameter;


/**
 执行实例子方法
 
 @param selectString 方法名
 @param methodParaments 方法参数 --- 指针参数 对应参数 以指针类型传入
 @return 返回值
 */
- (ReturnStruct)instanceMethodSelect:(NSString*)selectString parameter:(void *)methodParaments, ... NS_REQUIRES_NIL_TERMINATION;

/**
 执行类方法
 
 @param selectString 方法名
 @param methodParaments 方法参数 --- 指针参数 对应参数 以指针类型传入
 @return 返回值
 */
+ (ReturnStruct)classMethodSelect:(NSString*)selectString parameter:(void *)methodParaments, ... NS_REQUIRES_NIL_TERMINATION;

@end
