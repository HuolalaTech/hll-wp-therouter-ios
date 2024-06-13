//
//  TheRouterDynamicParamsMapping.m
//  TheRouter
//
//  Created by mars.yao on 2023/7/27.
//

#import "TheRouterDynamicParamsMapping.h"

@implementation TheRouterDynamicParamsMapping

+ (instancetype)router {
    static TheRouterDynamicParamsMapping *router;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[TheRouterDynamicParamsMapping alloc] init];
        router.filterKey = @[@"requestURLKey", @"jumpType", @"tabBarSelecIndex"];
    });
    return router;
}
/**
 初始化 类。可直接通过NSClassFromString 获取。在这里为保持路由的美观
 @param className 类字符串名字
 @return 返回类对象
 */
- (Class)routerClassName:(NSString*)className{
    
    Class  class = nil;
    if (className!=nil) {
        class = NSClassFromString(className);
    }
    
    return class;
}
/**
 初始化 类对象。获取类的初始化对象。
 
 @param className 类名
 @return 返回ReturnStruct结构体 包含实例对象 和 返回值。 类的初始化实例
 */
- (id)routerGetInstanceWithClassName:(NSString*)className {
    Class  class = nil;
    if (className!=nil) {
        class = NSClassFromString(className);
        return [[class alloc]init];
    }
    return nil;
}
@end



@implementation NSObject (TheRouterClass)

/**
 kvc模式执行实例对象f设置属性值
 
 @param propertyParameter 属性key-value
 @return 返回值
 */
- (ReturnStruct)setPropertyParameter:(NSDictionary*)propertyParameter{
    // 创建可变字典，以便进行修改
    NSMutableDictionary *filteredDictionary = [propertyParameter mutableCopy];
    
    // 移除指定的键
    [filteredDictionary removeObjectsForKeys:[TheRouterDynamicParamsMapping router].filterKey];
    return [self transferRouterObject:self setPropertyParameter:filteredDictionary methodSelect:nil   parameter:nil];
}
/**
 执行实例方法
 
 @param selectString 方法名
 @param methodParaments 属性key-value
 @return 返回参数
 */
- (ReturnStruct)instanceMethodSelect:(NSString*)selectString parameter:(void *)methodParaments, ... {
    
    NSMutableArray *Parameters = [NSMutableArray array];
    va_list argumentList;
    void   *eachParameter;
    if (methodParaments)
    {
        void *address = &methodParaments;
        [Parameters addObject:[NSValue  value:address withObjCType:@encode(void*)]];
        va_start(argumentList, methodParaments);
        while((eachParameter = va_arg(argumentList, void*)))
        {
            [Parameters addObject: [NSValue  value:&eachParameter withObjCType:@encode(void*)]];
        }
        va_end(argumentList);
    }
    
    return [self transferRouterObject:self setPropertyParameter:nil methodSelect:selectString parameter:Parameters];
}

/**
 执行类方法
 
 @param selectString 方法名
 @param methodParaments 属性key-value
 @return 返回参数
 */
+ (ReturnStruct)classMethodSelect:(NSString*)selectString parameter:(void *)methodParaments, ... {
    
    NSMutableArray *Parameters = [NSMutableArray array];
    va_list argumentList;
    void   *eachParameter;
    if (methodParaments)
    {
        void *address = &methodParaments;
        [Parameters addObject:[NSValue  value:address withObjCType:@encode(void*)]];
        va_start(argumentList, methodParaments);
        while((eachParameter = va_arg(argumentList, void*)))
        {
            [Parameters addObject: [NSValue  value:&eachParameter withObjCType:@encode(void*)]];
        }
        va_end(argumentList);
    }
    
    return   [self transferRouterObject:NSStringFromClass([self class]) setPropertyParameter:nil methodSelect:selectString parameter:Parameters];
}



/**
 AOP kvc 对实例赋值以及进行方法签名，通过函数指针适配任意类型的值的传递 进行方法调用属性赋值等操作。
 
 @param object 类或实例对象
 @param propertyParameter 属性keyvalue
 @param selectString 方法名
 @param Parameters 方法参数
 @return 返回值
 */
- (ReturnStruct)transferRouterObject:(id)object setPropertyParameter:(NSDictionary*)propertyParameter methodSelect:(NSString*)selectString parameter:(NSArray*)Parameters {
    NSString  *className = nil;
    if ([object isKindOfClass:[NSString class]]) {
        className = [NSString stringWithFormat:@"%@",object];
        Class  class = NSClassFromString(className);
        //默认obj的 描述方法  下面重新赋值
        NSString  *methodpString = nil;
        if (selectString!=nil) {
            methodpString = selectString;
        }
        SEL methodSelect = NSSelectorFromString(methodpString);
        if ([class  respondsToSelector:methodSelect]) {
            @synchronized (self) {
                NSMethodSignature *singnature = [class methodSignatureForSelector:methodSelect];
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:singnature];
                invocation.target = class;
                invocation.selector = methodSelect;
                
                [Parameters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    NSUInteger bufferSize = 0;
                    NSGetSizeAndAlignment([obj objCType], &bufferSize, NULL);
                    void *buffer = malloc(bufferSize);
                    [obj getValue:&buffer];
                    [invocation setArgument:buffer atIndex:(2+idx)];
                }];;
                
                [invocation retainArguments];
                [invocation invoke];
                return [self  getreturnResultDependSingnature:singnature dependInvocation:invocation  withInstance:nil];
            }
            
        }
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = nil;
        returnInfoStrut.returnValue = nil;
        
        return returnInfoStrut;
        
        
        
    }else{
        
        className = NSStringFromClass([object class]);
        Class  class = NSClassFromString(className);
        //实例方法
        id  instanceCtrl = nil;
        
        if ([object isKindOfClass:[NSString class]]) {
            instanceCtrl =  [[class alloc] init];
        }else{
            
            instanceCtrl = object;
        }
        
        NSString  *methodpString = nil;
        if (selectString!=nil) {
            methodpString = selectString;
        }
        SEL methodSelect = NSSelectorFromString(methodpString);
        
        @synchronized (self) {
            [propertyParameter  enumerateKeysAndObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull key, id  _Nonnull obj, BOOL * _Nonnull stop) {
                
                NSString *setterSelectorName = [NSString stringWithFormat:@"set%@%@:", [[key substringToIndex:1] uppercaseString], [key substringFromIndex:1]];
                SEL setterSelector = NSSelectorFromString(setterSelectorName);
                
                if ([instanceCtrl respondsToSelector:setterSelector]) {
                    [instanceCtrl setValue:obj forKey:key];
                } else {
#ifdef DEBUG
                    NSLog(@"⚠️⚠️ ⚠️  Warning: %@ does not respond to setter for key '%@'", instanceCtrl, key);
#endif
                }
            }];
            
            if ([instanceCtrl respondsToSelector:methodSelect]) {
                NSMethodSignature *singnature = [instanceCtrl  methodSignatureForSelector:methodSelect];
                
                NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:singnature];
                invocation.target = instanceCtrl;
                invocation.selector = methodSelect;
                [Parameters enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                    
                    NSUInteger bufferSize = 0;
                    NSGetSizeAndAlignment([obj objCType], &bufferSize, NULL);
                    void *buffer = malloc(bufferSize);
                    [obj getValue:&buffer];
                    [invocation setArgument:buffer atIndex:(2+idx)];
                }];
                
                [invocation retainArguments];
                [invocation invoke];
                
                return [self  getreturnResultDependSingnature:singnature dependInvocation:invocation withInstance:instanceCtrl];
                
            }
            
        }
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = nil;
        returnInfoStrut.returnValue = nil;
        
        return returnInfoStrut;
    }
}


/**
 返回参数处理 --- 本例列举了大部分返回数据类型  也可根据自己的需要拓展 后续版本会j优化
 
 @param singnature 方法签名
 @param invocation 方法调用
 @param instanceObj 实例或者类
 @return 返回结果
 */
- (ReturnStruct)getreturnResultDependSingnature:(NSMethodSignature*)singnature dependInvocation:(NSInvocation*)invocation withInstance:(NSObject*)instanceObj{
    const char* retType = [singnature methodReturnType];
    if (strcmp(retType, @encode(void)) == 0){
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = nil;
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(BOOL)) == 0){
        
        BOOL resultback = 0;
        [invocation getReturnValue:&resultback];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = [NSNumber numberWithBool:resultback];
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(NSInteger)) == 0){
        
        NSInteger resultback = 0;
        [invocation getReturnValue:&resultback];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = [NSNumber numberWithInteger:resultback];
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(NSUInteger)) == 0){
        
        NSUInteger resultback = 0;
        [invocation getReturnValue:&resultback];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = [NSNumber numberWithUnsignedInteger:resultback];
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(int)) == 0){
        
        int resultback = 0;
        [invocation getReturnValue:&resultback];
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = [NSNumber numberWithInt:resultback];
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(CGFloat)) == 0){
        
        CGFloat resultback = 0.0;
        [invocation getReturnValue:&resultback];
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = [NSNumber numberWithFloat:resultback];
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(double)) == 0
              ||strcmp(retType, @encode(float)) == 0
              ||strcmp(retType, @encode(long)) == 0
              ||strcmp(retType, @encode(long long)) == 0
              ||strcmp(retType, @encode(unsigned int)) == 0
              ||strcmp(retType, @encode(unsigned long)) == 0
              ||strcmp(retType, @encode(unsigned short)) == 0
              ||(strcmp(retType, @encode(char)) == 0)
              ){
        __unsafe_unretained id resultback = nil;
        //返回值长度
        NSUInteger length = [singnature methodReturnLength];
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        //为变量赋值
        [invocation getReturnValue:buffer];
        
        resultback = [NSNumber valueWithBytes:buffer objCType:retType];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = resultback;
        return returnInfoStrut;
        
    }else if (strcmp(retType, @encode(id)) == 0){
        __unsafe_unretained id resultback = nil;
        [invocation getReturnValue:&resultback];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = resultback;
        return returnInfoStrut;
    }else{
        __unsafe_unretained id resultback = nil;
        //返回值长度
        NSUInteger length = [singnature methodReturnLength];
        //根据长度申请内存
        void *buffer = (void *)malloc(length);
        //为变量赋值
        [invocation getReturnValue:buffer];
        
        resultback = [NSValue valueWithBytes:buffer objCType:retType];
        
        ReturnStruct  returnInfoStrut;
        returnInfoStrut.instanceObject = instanceObj;
        returnInfoStrut.returnValue = resultback;
        return returnInfoStrut;
    }
}

@end
