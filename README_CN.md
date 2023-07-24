![](https://therouter.cn/assets/img/logo/logo4.png)

# TheRouter

[![**license**](https://img.shields.io/hexpm/l/plug.svg)](https://www.apache.org/licenses/LICENSE-2.0)
[![**Platform**](https://img.shields.io/badge/platform-iOS-blue.svg)]()
[![**Language**](https://img.shields.io/badge/language-ObjectC-green.svg)]()
[![**wiki**](https://img.shields.io/badge/Wiki-open-brightgreen.svg)](https://xxx.com)

## 功能介绍

TheRouter是货拉拉打造的一款同时支持[Android](https://github.com/HuolalaTech/hll-wp-therouter-android)及iOS的轻量级路由中间件，在iOS端吸取了其他其他语言的特性，支持[注解](https://juejin.cn/post/6999484997782470669)功能，极大提升了路由在iOS端的使用体感。摒弃了传统ioser的target-action或protocol理念，向更广的后台或Android应用对齐。

`TheRouter 核心功能具备四大能力：`

* **页面导航跳转能力**：支持常规vc或Storyboard的push/present跳转能力；
* **自动注册能力**：实现类似Java注解功能，在vc类或任意方法上标注即可完成路由注册；
* **硬编码消除**：内置脚本会自动将注册的path转为静态字符串常量供业务使用；
* **动态化能力**：支持添加重定向、拦截器等等；

## 模块描述

```
.
├── Classes
│   ├── TheRouter+Annotation.h
│   ├── TheRouter+Annotation.m  // 路由注解器及Path功能扩展
│   ├── TheRouter.h
│   └── TheRouter.m             // 路由库核心代码（增删改查，重定向/拦截器）
└── Resources
    └── scan.py                 // 注解扫描及硬编码处理脚本（该脚本只会被引用不会参与编译和打包）
```

## 使用介绍

#### Cocoapods 引入

```ruby
pod 'TheRouter'
```

#### 注解使用

**step1**

创建`TheRouterAnnotation.plist`文件，必须在MainBundle下。

**step2**

为项目创建一个Aggregate类型的target：

<img src="GuideImages/guide1.jpeg">

**step3**

在新建的target添加脚本：

<img src="GuideImages/guide2.jpeg">

图中实例脚本参数含义：

```shell
python3 $SRCROOT/../TheRouter/Resources/scan.py     # 脚本路径
$SRCROOT/                                           # 参数1：扫描路径,一般为项目根目录
$SRCROOT/TheRouter/                                 # 参数2：路径定义头文件存放目录 一般为存放至公共模块 
$SRCROOT/TheRouter/TheRouterAnnotation.plist        # 参数3：TheRouterAnnotation文件路径
```

**step4**

在应用加载完成时注册host，在想要跳转的VC类上添加路由注解或创建对应模块的Service类，在Service中的方法上添加注解即可，例如：

注册该项目的host：

```
[TheRouter.shared registPathAnnotationsWithHost:@"hd://com.therouter.test"];
```

添加vc注解：

```
TheRouterController(test/vc, TestViewController)
@interface TestViewController : UIViewController

@end
```

添加Service注解：

```
#import "TestService.h"
#import "TheRouter_Mappings.h"
#import <TheRouter/TheRouter+Annotation.h>

@implementation TestService

TheRouterSelector(test/jump, jumpToTestVC, TestService)
+ (id)jumpToTestVC:(TheRouterInfo *)routerInfo
{
    UIViewController *vc = [TheRouter.shared openVCPath:kRouterPathTestVcVC
                                                    cmd:TheRouterOpenCMDPush
                                             withParams:@{@"title":@"123"}
                                                hanlder:^(NSString * _Nonnull tag, NSDictionary * _Nullable result) {
        !routerInfo.openCompleteHandler ?: routerInfo.openCompleteHandler(tag, result);
    }];
    return vc;
}

@end

```

**step5**

在每次对路由进行增删改时编译一次创建好的target，会自动向`TheRouterAnnotation.plist`文件写入信息，并在指定的目录下生成`TheRouter_Mappings.h`文件，将此文件拖入对应模块即可

<img src="GuideImages/guide3.jpeg">

#### 拦截器和重定向

**拦截器：**

```
// 只要访问hd://com.therouter.test或其子路径 (hd://com.therouter.test/xxx) 都会进入该回调
// 如果返回YES那么对应的路由事件可以正常执行，反之则会被拦截不会执行路由事件
[TheRouter.shared registInterceptorForURLString:@"hd://com.therouter.test/*" handler:^BOOL(TheRouterInfo * _Nonnull router, id  _Nullable (^ _Nonnull continueHandle)(void)) {
    NSLog(@"will execute router %@", router.URLString);
    return YES;
}];
```

**重定向：**

```
// 重定向是指访问 hd://test.com/test 时会走 hd://test.com/test/vc的事件，用来迁移老路径或线上遇到问题时可快速更改至其他页面承接业务
[TheRouter.shared registRedirect:@"hd://test.com/test" to:@"hd://test.com/test/vc"];
```

#### 执行路由事件

```
UIViewController *vc = [TheRouter.shared openVCPath:kRouterPathTestVcVC    // 传入Path
                                                cmd:TheRouterOpenCMDPush   // 指定打开命令
                                         withParams:@{@"title":@"123"}     // 指定参数，这里支持对kvc赋值
                                            hanlder:^(NSString * _Nonnull tag, NSDictionary * _Nullable result) {
        !routerInfo.openCompleteHandler ?: routerInfo.openCompleteHandler(tag, result);
}];
```

## 关于作者

[货拉拉移动端技术团队](https://juejin.cn/user/1768489241815070)

## 开源协议

TheRouter 采用Apache2.0协议，详情参考[LICENSE](LICENSE)
