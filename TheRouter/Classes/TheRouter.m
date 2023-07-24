//
//  TheRouter.m
//
//  Created by zed on 2019/3/18.
//

#import "TheRouter.h"
#import <pthread.h>
#import <objc/runtime.h>

@interface TheRouter ()

@property (nonatomic, strong) NSMutableDictionary *routers;

@property (nonatomic, strong) NSMutableDictionary *redirects;

@end

static NSString * const THE_ROUTER_HANDLER_KEY = @"_handler";
static NSString * const THE_ROUTER_PATHOLDER_KEY = @"_placeholder";
static NSString * const THE_ROUTER_INTERCEPTOR_KEY = @"_interceptor";
static NSString * const THE_ROUTER_REDIRECTURL_KEY = @"_redirectUrl";

static NSString * const THE_ROUTER_PLACEHOLDER_PATH = @"~:placeHolder";

@implementation TheRouter
{
    pthread_rwlock_t _rwlock;
}

+ (instancetype)shared
{
    static TheRouter *router = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        router = [[self alloc] init];
    });
    return router;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        pthread_rwlock_init(&_rwlock, NULL);
    }
    return self;
}

- (void)registURLString:(NSString *)URLString openHandler:(TheRouterOpenHandler)handler
{
    NSString *orgUrlStr = [self removeWildcardSuffix:URLString];
    NSArray *components = [self pathComponentsWithURLString:orgUrlStr];
    if (components.count < 2) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:\"%@\"The route does not conform to the URL specification, please check for changes", URLString);
        return;
    }
    
    if (!handler) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:The route handler cannot be empty");
        return;
    }
    
    pthread_rwlock_wrlock(&_rwlock);
    __block NSMutableDictionary *subRouters = self.routers;
    __block NSString *keypath = @"";
    
    [components enumerateObjectsUsingBlock:^(NSString *path, NSUInteger idx, BOOL * _Nonnull stop) {
        NSString *currentPath = idx == 0 ? [keypath stringByAppendingString:path] : [keypath stringByAppendingFormat:@".%@", path];
        if (!subRouters[path]) {
            subRouters[path] = [[NSMutableDictionary alloc] initWithCapacity:0];
        }
        
        if (![path isEqualToString:THE_ROUTER_PLACEHOLDER_PATH]) {
            keypath = currentPath; subRouters = subRouters[path];
            return;
        }
        
        // To handle the placeholder, need to add a handle to the placeholder and its parent
        // For example, if hd://test.com/a/:b is registered, then the path to the hd://test.com/a will also need to call handle
        subRouters[THE_ROUTER_HANDLER_KEY] = [handler copy];
        if (keypath.length > 0) {
            NSMutableDictionary *lastInfo = [subRouters valueForKeyPath:keypath];
            lastInfo[THE_ROUTER_HANDLER_KEY] = [handler copy];
        }
        
        keypath = currentPath; subRouters = subRouters[path];
    }];
    
    subRouters[THE_ROUTER_HANDLER_KEY] = [handler copy];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)registInterceptorForURLString:(NSString *)URLString handler:(TheRouterInterceptorHandler)handler
{
    NSString *orgUrlStr = [self removeWildcardSuffix:URLString];
    NSArray *components = [self pathComponentsWithURLString:orgUrlStr];
    if (components.count < 2) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:\"%@\"The interceptor path does not conform to the URL specification, check for modifications", URLString);
        return;
    }
    
    if (!handler) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:The interceptor execution handler cannot be empty");
        return;
    }
    
    pthread_rwlock_wrlock(&_rwlock);
    NSString *keypath = [components componentsJoinedByString:@"."];
    NSMutableDictionary *subRouter = [self.routers valueForKeyPath:keypath];
    if (!subRouter) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:The interceptor must rely on an existing route or its parent path");
        return;
    }
    
    subRouter[THE_ROUTER_INTERCEPTOR_KEY] = [handler copy];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)removeInterceptorForURLString:(NSString *)URLString
{
    NSString *orgUrlStr = [self removeWildcardSuffix:URLString];
    NSArray *components = [self pathComponentsWithURLString:orgUrlStr];
    if (components.count < 2) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:\"%@\"To remove the interceptor path that does not conform to the URL specification, check for modifications", URLString);
        return;
    }
    
    pthread_rwlock_wrlock(&_rwlock);
    NSString *keypath = [components componentsJoinedByString:@"."];
    NSMutableDictionary *subRouter = [self.routers valueForKeyPath:keypath];
    [subRouter removeObjectForKey:THE_ROUTER_INTERCEPTOR_KEY];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)registRedirect:(NSString *)orgURLString to:(NSString *)toURLString
{
    NSArray *components = [self pathComponentsWithURLString:orgURLString];
    if (components.count < 2) return;
    
    components = [self pathComponentsWithURLString:toURLString];
    if (components.count < 2) return;
    
    NSString *orgUrlStr = [self removeWildcardSuffix:orgURLString];
    NSString *toUrlStr = [self removeWildcardSuffix:toURLString];
    
    pthread_rwlock_wrlock(&_rwlock);
    [self.redirects setObject:toUrlStr forKey:orgUrlStr];
    pthread_rwlock_unlock(&_rwlock);
}

- (void)removeRedirect:(NSString *)orgURLString
{
    if (!orgURLString.length) return;
    
    NSString *orgUrlStr = [self removeWildcardSuffix:orgURLString];
    pthread_rwlock_wrlock(&_rwlock);
    [self.redirects removeObjectForKey:orgUrlStr];
    pthread_rwlock_unlock(&_rwlock);
}

- (BOOL)canOpenURLString:(NSString *)URLString
{
    NSArray *pathComponents = [self pathComponentsWithURLString:URLString];
    if (pathComponents.count < 2) return NO;
    
    pthread_rwlock_rdlock(&_rwlock);
    NSDictionary *route = [self matchRouterWithURLString:URLString interceptors:nil];
    BOOL canOpen = route[THE_ROUTER_HANDLER_KEY] ? YES : NO;
    pthread_rwlock_unlock(&_rwlock);
    return canOpen;
}

- (id)openURLString:(NSString *)URLString
{
    return [self openURLString:URLString handler:nil];
}

- (id)openURLString:(NSString *)URLString handler:(TheRouterOpenCompleteHandler)handler
{
    return [self openURLString:URLString withParams:nil hanlder:handler];
}

- (id)openURLString:(NSString *)URLString withParams:(NSDictionary *)params hanlder:(TheRouterOpenCompleteHandler)handler
{
    if (!URLString.length) return nil;
    
    NSArray<NSString *> *components = [self pathComponentsWithURLString:URLString];
    if (components.count < 2) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:\"%@\"Invalid URL, please check for modifications", URLString);
        return nil;
    }
    
    pthread_rwlock_rdlock(&_rwlock);
    NSArray *interceptors = nil;
    NSDictionary *routeInfo = [self matchRouterWithURLString:URLString interceptors:&interceptors];
    pthread_rwlock_unlock(&_rwlock);
    
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableDictionary *allParams = params ? params.mutableCopy : @{}.mutableCopy;
    NSURLComponents *urlComponents = [[NSURLComponents alloc] initWithString:URL.absoluteString];
    [urlComponents.queryItems enumerateObjectsUsingBlock:^(NSURLQueryItem * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (!obj.name.length || !obj.value) return;
        [allParams setObject:obj.value forKey:obj.name];
    }];
    
    NSString *redirectURL = routeInfo[THE_ROUTER_REDIRECTURL_KEY];
    TheRouterInfo *route = [TheRouterInfo new];
    route.URLString = redirectURL.length ? redirectURL : URLString;
    route.params = allParams.copy;
    route.openCompleteHandler = handler;
    route.pathHolderValues = routeInfo[THE_ROUTER_PATHOLDER_KEY];
    
    TheRouterOpenHandler openHandler = routeInfo[THE_ROUTER_HANDLER_KEY];
    if (!openHandler) {
        !self.globalOpenFailedHandler ? nil : self.globalOpenFailedHandler(route);
        return nil;
    }
    
    // Give priority to interceptors
    if (interceptors.count) {
        id obj = [self executeInterceptors:interceptors idx:0 openHandler:openHandler route:route];
        [obj setValue:route forKey:@"the_routerInfo"];
        return obj;
    } else {
        id obj = openHandler(route);
        [obj setValue:route forKey:@"the_routerInfo"];
        return obj;
    }
}

- (void)cancelURLString:(NSString *)URLString
{
    NSArray *components = [self pathComponentsWithURLString:URLString];
    if (components.count < 2) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:\"%@\"Invalid URL, please check for modifications", URLString);
        return;
    }
    
    pthread_rwlock_wrlock(&_rwlock);
    NSString *keypath = [components componentsJoinedByString:@"."];
    NSMutableDictionary *subRouter = [self.routers valueForKeyPath:keypath];
    [subRouter removeObjectForKey:THE_ROUTER_HANDLER_KEY];
    pthread_rwlock_unlock(&_rwlock);
}

- (NSDictionary *)redirectInfos
{
    return self.redirects.copy;
}

- (NSString *)description
{
    pthread_rwlock_rdlock(&_rwlock);
    NSDictionary *desc = [self.routers copy];
    pthread_rwlock_unlock(&_rwlock);
    return desc.description;
}

#pragma mark - Private
- (NSArray *)pathComponentsWithURLString:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSMutableArray *components = [[NSMutableArray alloc] initWithCapacity:0];
    if (!URL) return [components copy];
    
    if (URL.scheme.length) {
        [components addObject:URL.scheme];
    }
    
    if (URL.host.length) {
        [components addObject:[URL.host stringByReplacingOccurrencesOfString:@"." withString:@"-"]];
    }
    
    for (NSString *path in URL.pathComponents) {
        if ([path isEqualToString:@"/"]) continue;
        if ([path hasPrefix:@":"]) { // The placeholder uniformly uses a path
            [components addObject:THE_ROUTER_PLACEHOLDER_PATH];
        } else {
            [components addObject:path];
        }
    }
    
    return [components copy];
}

- (NSDictionary *)matchRouterWithURLString:(NSString *)URLString interceptors:(NSArray **)interceptors
{
    NSString *redirect = [self findRedirectString:URLString];
    NSArray *components = [self pathComponentsWithURLString:redirect.length ? redirect : URLString];
    
    NSMutableDictionary *info = [NSMutableDictionary dictionary];
    info[THE_ROUTER_REDIRECTURL_KEY] = redirect ?: @"";
    
    NSString *keypath = [NSString stringWithFormat:@"%@.%@", components[0], components[1]];
    NSDictionary *currentRouter = [self.routers valueForKeyPath:keypath];
    
    // The host path is not registered and returns nil
    if (!currentRouter) return info;
    
    NSMutableArray<NSString *> *pathValues = [NSMutableArray array];
    NSMutableArray<TheRouterInterceptorHandler> *interceptorHandles = [NSMutableArray array];
    TheRouterInterceptorHandler handler = currentRouter[THE_ROUTER_INTERCEPTOR_KEY];
    if (handler) [interceptorHandles addObject:handler];
    
    components = [components subarrayWithRange:NSMakeRange(2, components.count - 2)];
    for (NSString *path in components) {
        NSString *realPath = [keypath stringByAppendingFormat:@".%@", path];
        NSMutableDictionary *realRoute = [self.routers valueForKeyPath:realPath];
        
        NSString *placeholderPath = [keypath stringByAppendingFormat:@".%@", THE_ROUTER_PLACEHOLDER_PATH];
        NSMutableDictionary *placeholderRoute = [self.routers valueForKeyPath:placeholderPath];
        
        NSMutableDictionary *route = realRoute ?: placeholderRoute;
        if (!route) return info;
        
        currentRouter = route;
        keypath = realRoute ? realPath : placeholderPath;
        if (placeholderRoute && ![path isEqualToString:THE_ROUTER_PLACEHOLDER_PATH]) {
            [pathValues addObject:path];
        }
        
        TheRouterInterceptorHandler handler = route[THE_ROUTER_INTERCEPTOR_KEY];
        if (handler) [interceptorHandles addObject:handler];
    }
    
    if (!currentRouter[THE_ROUTER_HANDLER_KEY]) return info;
    if (interceptors) *interceptors = interceptorHandles.copy;
    
    info[THE_ROUTER_PATHOLDER_KEY] = pathValues;
    info[THE_ROUTER_HANDLER_KEY] = currentRouter[THE_ROUTER_HANDLER_KEY];
    return [info copy];
}

- (NSString *)findRedirectString:(NSString *)orgURLString
{
    if (!self.redirects.count) return nil;
    
    NSString *orgUrlStr = [self removeWildcardSuffix:orgURLString];
    NSString *redirect = self.redirects[orgUrlStr];
    if (redirect.length) {
        NSString *result = [orgURLString stringByReplacingOccurrencesOfString:orgUrlStr withString:redirect];
        return result;
    }
    
    NSURL *URL = [NSURL URLWithString:orgUrlStr];
    NSString *currentPath = [NSString stringWithFormat:@"%@://%@", URL.scheme, URL.host];
    redirect = self.redirects[currentPath];
    if (redirect.length) {
        NSString *result = [orgURLString stringByReplacingOccurrencesOfString:currentPath withString:redirect];
        return result;
    }
    
    NSString *result = @"";
    for (NSString *path in URL.pathComponents) {
        if ([path isEqualToString:@"/"]) continue;
        
        NSString *temp = [currentPath stringByAppendingFormat:@"/%@", path];
        if (!self.redirects[temp]) {
            currentPath = temp; continue;
        } else {
            result = temp; redirect = self.redirects[temp];
        }
    }
    
    if (!result.length) return nil;
    result = [orgURLString stringByReplacingOccurrencesOfString:result withString:redirect];
    return result;
}

- (NSString *)removeWildcardSuffix:(NSString *)URLString
{
    NSURL *URL = [NSURL URLWithString:URLString];
    NSString *orgUrlStr = [NSString stringWithFormat:@"%@://%@%@", URL.scheme, URL.host, URL.path ?: @""];
    
    if ([orgUrlStr hasSuffix:@"*"]) {
        orgUrlStr = [orgUrlStr substringToIndex:orgUrlStr.length - 1];
    }
    
    if ([orgUrlStr hasSuffix:@"/"]) {
        orgUrlStr = [orgUrlStr substringToIndex:orgUrlStr.length - 1];
    }
    
    return orgUrlStr.copy;
}

- (id)executeInterceptors:(NSArray<TheRouterInterceptorHandler> *)handlers idx:(NSUInteger)idx openHandler:(TheRouterOpenHandler)openHandler route:(TheRouterInfo *)route
{
    __block id returnObj = nil;
    if (idx >= handlers.count) {
        returnObj = openHandler(route);
        return returnObj;
    }
    
    TheRouterInterceptorHandler handler = handlers[idx];
    NSUInteger nextIdx = idx + 1;
    id (^continueHandle)(void)  = ^id (void){
        return [self executeInterceptors:handlers idx:nextIdx openHandler:openHandler route:route];
    };
    
    BOOL shouldContinue = handler(route, continueHandle);
    if (shouldContinue) {
        continueHandle = nil;
        returnObj = [self executeInterceptors:handlers idx:nextIdx openHandler:openHandler route:route];
    }
    
    return returnObj;
}

#pragma mark - Lazy Load
- (NSMutableDictionary *)routers
{
    if (!_routers) {
        _routers = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _routers;
}

- (NSMutableDictionary *)redirects
{
    if (!_redirects) {
        _redirects = [[NSMutableDictionary alloc] initWithCapacity:0];
    }
    return _redirects;
}

@end


@implementation TheRouterInfo

- (NSString *)description
{
    NSMutableDictionary *desc = [NSMutableDictionary dictionary];
    desc[@"URLString"] = self.URLString;
    desc[@"Params"] = self.params;
    desc[@"PathHolderValues"] = self.pathHolderValues;
    desc[@"CompleteBlock"] = self.openCompleteHandler;
    return [NSString stringWithFormat:@"%@", desc];
}

@end

@implementation NSObject (TheRouter)

static char kAssociatedObjectKeyTheRouterInfo;

- (void)setThe_routerInfo:(TheRouterInfo *)the_routerInfo
{
    objc_setAssociatedObject(self, &kAssociatedObjectKeyTheRouterInfo, the_routerInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TheRouterInfo *)the_routerInfo
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKeyTheRouterInfo);
}

@end

@implementation NSProxy (TheRouter)

static char kAssociatedObjectKeyTheRouterInfo;

- (void)setThe_routerInfo:(TheRouterInfo *)the_routerInfo
{
    objc_setAssociatedObject(self, &kAssociatedObjectKeyTheRouterInfo, the_routerInfo, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
}

- (TheRouterInfo *)the_routerInfo
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKeyTheRouterInfo);
}

@end

