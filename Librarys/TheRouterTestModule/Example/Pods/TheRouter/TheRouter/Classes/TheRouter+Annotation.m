//
//  TheRouter+Annotation.m
//
//  Created by zed on 2020/4/9.
//

#import "TheRouter+Annotation.h"
#import <UIKit/UIKit.h>
#import <objc/runtime.h>

static NSString * const kTheRouterAnnotationFileName       = @"TheRouterAnnotation";
static NSString * const kTheRouterAnnotationsRootKey       = @"TheRouterAnnotations";
static NSString * const kTheRouterControllerSectionKey     = @"vcs";
static NSString * const kTheRouterSBControllerSectionKey   = @"sbvcs";
static NSString * const kTheRouterSelectorSectionKey       = @"sels";

static NSString * const kTheOpenVCCMD = @"__the_router_open_cmd__";

@interface TheRouter (Annotation)

@property (nonatomic, copy) NSString *baseHost;

@end

@implementation TheRouter (Annotation)

- (void)registPathAnnotationsWithHost:(NSString *)host
{
    if (![NSURL URLWithString:host]) {
        NSAssert(NO, @"Illegal domain names"); return;
    }
    
    self.baseHost = host;
    
    dispatch_async(dispatch_get_global_queue(0, 0), ^{ @autoreleasepool {
        
        NSString *annotationFilePath = [[NSBundle mainBundle] pathForResource:kTheRouterAnnotationFileName ofType:@"plist"];
        NSDictionary *annotations = [NSDictionary dictionaryWithContentsOfFile:annotationFilePath];
        
        // Registering Controllers
        NSArray<NSString *> *vcMappers = annotations[kTheRouterControllerSectionKey];
        for (NSString *mapStr in vcMappers) {
            NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@","];
            [self registController:NSClassFromString(components.lastObject) storyBoard:nil path:components.firstObject];
        }
        
        // Register the StoryBoard Controller
        NSArray<NSString *> *sbVCMappers = annotations[kTheRouterSBControllerSectionKey];
        for (NSString *mapStr in sbVCMappers) {
            NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@","];
            if (components.count != 3) continue;
            [self registController:NSClassFromString(components.lastObject) storyBoard:components[1] path:components.firstObject];
        }
        
        // Registering Method
        NSArray<NSString *> *selMappers = annotations[kTheRouterSelectorSectionKey];
        for (NSString *mapStr in selMappers) {
            NSArray<NSString *> *components = [mapStr componentsSeparatedByString:@","];
            if (components.count != 3) continue;
            
            NSString *selector = [components[1] hasSuffix:@":"] ? components[1] : [NSString stringWithFormat:@"%@:", components[1]];
            [self registSelector:NSSelectorFromString(selector) targetClass:NSClassFromString(components.lastObject) path:components.firstObject ];
        }
    }});
}

- (void)registController:(Class)vcClass storyBoard:(NSString *)storyboard path:(NSString *)path
{
    if (!vcClass || !path) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:vcClass or path is empty, check for modifications");
        return;
    }
    
    if (![vcClass isSubclassOfClass:UIViewController.class]) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:%@Not UIViewController type, check for modifications", NSStringFromClass(vcClass));
        return;
    }
    
    NSString *url = [self getURLStringWithPath:path];
    [[TheRouter shared] registURLString:url openHandler:^id(TheRouterInfo *router) {
        id vcObject;
        if (!storyboard.length) {
            vcObject = [[vcClass alloc] init];
        } else {
            vcObject = [self viewControllerWithStoryboard:storyboard identifier:NSStringFromClass(vcClass)];
        }
        
        UIViewController *vc = (UIViewController *)vcObject;
        if (!vc) return nil;
        [self setupVC:vc router:router];
        [self jumpToVC:vc cmd:[router.params[kTheOpenVCCMD] integerValue]];
        return vc;
    }];
}

- (void)registSelector:(SEL)sel targetClass:(Class)targetClass path:(NSString *)path
{
    if (sel == NULL || !targetClass || !path) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:sel, vcClass, or path is empty, check for modifications");
        return;
    }
    
    if (![targetClass respondsToSelector:sel]) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:[%@ %@] The method was not found, check for modifications", NSStringFromClass(targetClass), NSStringFromSelector(sel));
        return;
    }
    
    NSMethodSignature *sign = [targetClass methodSignatureForSelector:sel];
    if (sign.numberOfArguments != 3) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:The registered method must have only one parameter: TheRouteInfo, check for changes");
        return;
    }
    
    if (![self isObjectType:[sign getArgumentTypeAtIndex:2]]) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:The registered method parameters must be of type TheRouteInfo, please check for modifications");
        return;
    }
    
    if (sign.methodReturnLength && ![self isObjectType:sign.methodReturnType]) {
        NSAssert(NO, @"⚠️TheRouterError⚠️:Registered methods must return object or void, check for changes");
        return;
    }
    
    NSString *url = [self getURLStringWithPath:path];
    [[TheRouter shared] registURLString:url openHandler:^id(TheRouterInfo *router) {
        NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:sign];
        [invocation setTarget:targetClass];
        [invocation setSelector:sel];
        [invocation setArgument:&router atIndex:2];
        [invocation invoke];
        if (!sign.methodReturnLength) return nil;
        
        __autoreleasing id ret; [invocation getReturnValue:&ret];
        return ret;
    }];
}

- (id)openPath:(NSString *)path
{
    return [self openPath:path hanlder:nil];
}

- (id)openPath:(NSString *)path hanlder:(TheRouterOpenCompleteHandler)hanlder
{
    return [self openPath:path withParams:nil hanlder:hanlder];
}

- (id)openPath:(NSString *)path withParams:(NSDictionary *)params hanlder:(TheRouterOpenCompleteHandler)hanlder
{
    NSString *url = [self getURLStringWithPath:path];
    return [self openURLString:url withParams:params hanlder:hanlder];
}

- (id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd
{
    return [self openVCPath:path cmd:cmd hanlder:nil];
}

- (id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd hanlder:(TheRouterOpenCompleteHandler)hanlder
{
    return [self openVCPath:path cmd:cmd withParams:nil hanlder:hanlder];
}

- (id)openVCPath:(NSString *)path cmd:(TheRouterOpenVCCMD)cmd withParams:(NSDictionary *)params hanlder:(TheRouterOpenCompleteHandler)hanlder
{
    NSString *url = [self getURLStringWithPath:path];
    NSMutableDictionary *vcParams = params ? params.mutableCopy : @{}.mutableCopy;
    vcParams[kTheOpenVCCMD] = @(cmd);
    return [self openURLString:url withParams:vcParams hanlder:hanlder];
}

#pragma mark - Private

static char kAssociatedObjectKeyTheRouterBaseHost;
- (void)setBaseHost:(NSString *)baseHost
{
    objc_setAssociatedObject(self, &kAssociatedObjectKeyTheRouterBaseHost, baseHost, OBJC_ASSOCIATION_COPY_NONATOMIC);
}

- (NSString *)baseHost
{
    return objc_getAssociatedObject(self, &kAssociatedObjectKeyTheRouterBaseHost);
}

- (NSString *)getURLStringWithPath:(NSString *)path
{
    if ([self.baseHost hasSuffix:@"/"]) {
        self.baseHost = [self.baseHost substringToIndex:self.baseHost.length - 1];
    }
    
    if ([path hasPrefix:@"/"]) {
        path = [path substringFromIndex:1];
    }
    
    return [NSString stringWithFormat:@"%@/%@", self.baseHost, path];
}

- (NSString *)getClassNameWithSectionData:(NSString *)sectionData
{
    NSString *className = [sectionData componentsSeparatedByString:@"/"].lastObject;
    className = [className stringByReplacingOccurrencesOfString:@".h" withString:@""];
    className = [className stringByReplacingOccurrencesOfString:@".m" withString:@""];
    return className;
}

- (BOOL)isObjectType:(const char *)type
{
    return strncmp(@encode(id), type, strlen(@encode(id))) == 0;
}

- (UIViewController *)viewControllerWithStoryboard:(NSString *)storyboard identifier:(NSString *)identifier
{
    if (!storyboard.length || !identifier.length) return nil;
    UIStoryboard *sb = [UIStoryboard storyboardWithName:storyboard bundle:nil];
    if (!sb) return nil;
    return [sb instantiateViewControllerWithIdentifier:identifier];
}

- (UIViewController *)findTopVCWithRootVC:(UIViewController *)rootVC
{
    if (rootVC.presentedViewController) {
        UIViewController *presentedViewController = rootVC.presentedViewController;
        return [self findTopVCWithRootVC:presentedViewController];
    }
    
    if ([rootVC isKindOfClass:[UITabBarController class]]) {
        UITabBarController *tabBarController = (UITabBarController *)rootVC;
        return [self findTopVCWithRootVC:tabBarController.selectedViewController];
    }
    
    if ([rootVC isKindOfClass:[UINavigationController class]]) {
        UINavigationController *navigationController = (UINavigationController*)rootVC;
        return [self findTopVCWithRootVC:navigationController.topViewController];
    }
    
    return rootVC;
}

- (void)setupVC:(UIViewController *)vc router:(TheRouterInfo *)router
{
    if (!router.params.allKeys.count) return;
    [router.params enumerateKeysAndObjectsUsingBlock:^(NSString *key, id  _Nonnull obj, BOOL * _Nonnull stop) {
        if (![vc respondsToSelector:NSSelectorFromString(key)]) return;
        [vc setValue:obj forKey:key];
    }];
}

- (void)jumpToVC:(UIViewController *)vc cmd:(TheRouterOpenVCCMD)cmd
{
    if (cmd == TheRouterOpenCMDNone) return;
    
    UIViewController *topVC = [self findTopVCWithRootVC:[UIApplication sharedApplication].delegate.window.rootViewController];
    UINavigationController *nav = topVC.navigationController;
    
    switch (cmd) {
        case TheRouterOpenCMDPush: {
            [nav pushViewController:vc animated:YES];
        }
            break;
            
        case TheRouterOpenCMDPresent: {
            vc.modalPresentationStyle = UIModalPresentationFullScreen;
            [topVC presentViewController:vc animated:YES completion:nil];
        }
            break;
            
        case TheRouterOpenCMDPresentInNav: {
            UINavigationController *newNav = [[UINavigationController alloc] initWithRootViewController:vc];
            newNav.modalPresentationStyle = UIModalPresentationFullScreen;
            [topVC presentViewController:newNav animated:YES completion:nil];
        }
            break;
            
        default:
            break;
    }
}

@end


