//
//  TheRouter.h
//
//  Created by zed on 2019/3/18.
//

#import <Foundation/Foundation.h>

@class TheRouterInfo;

NS_ASSUME_NONNULL_BEGIN

/// Executing the route callback
/// @param router Routing information
typedef id _Nullable (^TheRouterOpenHandler)(TheRouterInfo *router);

/// If NO is returned, the event will wait until continueHandle is manually called, can be used for asynchronous operations
/// If the callback is asynchronous then the return value of the openURLString method becomes nil
/// @param router Routing information
/// @param continueHandle Continue executing the callback, and the return value matches the value returned by TheRouterOpenHandler
typedef BOOL(^TheRouterInterceptorHandler)(TheRouterInfo *router, id _Nullable (^continueHandle)(void));

/// Opens the completed related action
/// That is, A opens B, B is notified when it has done something and sends the result to A
/// @param tag The completion callback identifies.Since B may be doing multiple things to pass to A, you can use the tag as a distinction
/// @param result Complete callback parameters (Dictinary is used because avoiding B passing into the model would create coupling that is not intended for routing)
typedef void (^TheRouterOpenCompleteHandler)(NSString *tag, NSDictionary *_Nullable result);

@interface TheRouter : NSObject

/// The route opens the fail global callback
@property (nonatomic, copy, nullable) TheRouterOpenHandler globalOpenFailedHandler;

/// Redirect information (key is the original URL, value is the redirected URL)
@property (nonatomic, strong, readonly) NSDictionary *redirectInfos;

+ (instancetype)shared;

/// Register a URL to a route
/// @param URLString URLString or URL containing placeholders, such as (hd://test.com/:userID)
/// @param handler Executing the callback
- (void)registURLString:(NSString *)URLString openHandler:(TheRouterOpenHandler)handler;

/// Register a interceptor
- (void)registInterceptorForURLString:(NSString *)URLString handler:(TheRouterInterceptorHandler)handler;

/// Remove a interceptor
- (void)removeInterceptorForURLString:(NSString *)URLString;

/// Register a redirect, such as hd://test.com -> hd://therouter.com
- (void)registRedirect:(NSString *)orgURLString to:(NSString *)toURLString;

/// Remove a redirect
- (void)removeRedirect:(NSString *)orgURLString;

/// Checks whether a URL can be opened properly
- (BOOL)canOpenURLString:(NSString *)URLString;

/// Open a registered URL
- (nullable id)openURLString:(NSString *)URLString;

/// Open a registered URL and execute the completion callback
- (nullable id)openURLString:(NSString *)URLString handler:(nullable TheRouterOpenCompleteHandler)handler;

/// Open a registered URL with the parameters and perform the completion callback
- (nullable id)openURLString:(NSString *)URLString withParams:(nullable NSDictionary *)params hanlder:(nullable TheRouterOpenCompleteHandler)handler;

/// Cancel a registered URL
- (void)cancelURLString:(NSString *)URLString;

@end


@interface TheRouterInfo : NSObject

/// The URL currently called (or the redirected address if the redirection is hit)
@property (nonatomic, copy) NSString *URLString;
/// Open the Completion callback
@property (nonatomic, copy, nullable) TheRouterOpenCompleteHandler openCompleteHandler;
/// Open incoming parameters (both the Query in the URL and the Params passed in)
@property (nonatomic, strong, nullable) NSDictionary *params;
/// Placeholder value information on PathComponents
@property (nonatomic, strong, nullable) NSArray<NSString *> *pathHolderValues;

@end

@interface NSObject (TheRouter)

@property (nonatomic, strong, nullable) TheRouterInfo *the_routerInfo;

@end

@interface NSProxy (TheRouter)

@property (nonatomic, strong, nullable) TheRouterInfo *the_routerInfo;

@end

NS_ASSUME_NONNULL_END
