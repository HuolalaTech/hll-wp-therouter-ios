//
//  TheRouter+Annotation.h
//
//  Created by zed on 2020/4/9.
//

#import "TheRouter.h"

// ⚠️⚠️If you want to use a macro definition annotation routing must be registered in the mainBundle add "TheRouterAnnotation. Plist files⚠️⚠️

/// VC annotators, equivalent to call registController: clazzName storyBoard: nil path: routerPath
#define TheRouterController(routerPath,clazzName)

/// Storyboard VC annotators, equivalent to call registController: clazzName Storyboard: sbName path: routerPath
#define TheRouterStoryboardController(routerPath,sbName,clazzName)

/// Method annotator, equivalent to calling registSelector:selName targetClass:clazzName path:routerPath
#define TheRouterSelector(routerPath,selName,clazzName)

typedef NS_ENUM(NSUInteger, TheRouterOpenVCCMD) {
    TheRouterOpenCMDNone,           /// No operations just return the vc object
    TheRouterOpenCMDPush,           /// Automatically get the navigator of the current top-level vc for push operation and return the vc object
    TheRouterOpenCMDPresent,        /// Automatically get the current top-level vc for present operation and return the vc object
    TheRouterOpenCMDPresentInNav,   /// Automatically get the current top-level vc for present new navigator operation and return the vc object
};

NS_ASSUME_NONNULL_BEGIN

@interface TheRouter (Annotation)

/// Register all annotation routes and specify a host
/// @param host The APP's public domain name, such as: hd://test.com
- (void)registPathAnnotationsWithHost:(NSString *)host;

/// Register a route VC
- (void)registController:(Class)vcClass storyBoard:(nullable NSString *)storyboard path:(NSString *)path;

/// Register a route method
- (void)registSelector:(SEL)sel targetClass:(Class)targetClass path:(NSString *)path;

/// Open the specified path
- (nullable id)openPath:(NSString *)path;

/// Opens the specified path and receives the associated callback
- (nullable id)openPath:(NSString *)path hanlder:(nullable TheRouterOpenCompleteHandler)hanlder;

/// Opens the specified parameter path and receives the associated callback
- (nullable id)openPath:(NSString *)path withParams:(nullable NSDictionary *)params hanlder:(nullable TheRouterOpenCompleteHandler)hanlder;

/// Opening a vc on the given command returns the vc object
- (nullable id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd;

/// Opening a vc on the given command returns the vc object
- (nullable id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd hanlder:(nullable TheRouterOpenCompleteHandler)hanlder;

/// Opening a vc on the given command returns the vc object
- (nullable id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd withParams:(nullable NSDictionary *)params hanlder:(nullable TheRouterOpenCompleteHandler)hanlder;

@end

NS_ASSUME_NONNULL_END
