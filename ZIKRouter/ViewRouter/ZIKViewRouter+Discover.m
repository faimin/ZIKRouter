//
//  ZIKViewRouter+Discover.m
//  ZIKRouter
//
//  Created by zuik on 2018/1/22.
//  Copyright © 2017 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "ZIKViewRouter+Discover.h"
#import "ZIKRouterInternal.h"
#import "ZIKRouterPrivate.h"
#import "ZIKViewRouterInternal.h"
#import "ZIKViewRouteRegistry.h"
#import "ZIKRouteRegistryInternal.h"

ZIKAnyViewRouterType *_Nullable _ZIKViewRouterToView(Protocol *viewProtocol) {
    NSCParameterAssert(viewProtocol);
    if (!viewProtocol) {
        [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToView errorDescription:@"ZIKViewRouter.toView() viewProtocol is nil"];
        return nil;
    }
    ZIKRouterType *route = [ZIKViewRouteRegistry routerToDestination:viewProtocol];
    if ([route isKindOfClass:[ZIKViewRouterType class]]) {
        return (ZIKViewRouterType *)route;
    }
    [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToView
                                        errorDescription:@"Didn't find view router for view protocol: %@, this protocol was not registered.",viewProtocol];
    if (ZIKRouteRegistry.registrationFinished) {
        NSCAssert1(NO, @"Didn't find view router for view protocol: %@, this protocol was not registered.",NSStringFromProtocol(viewProtocol));
    } else {
        NSCAssert1(NO, @"❌❌❌❌warning: failed to get router for view protocol (%@), because manually registration is not finished yet! If there're modules running before registration is finished, and modules require some routers before you register them, then you should register those required routers earlier.",NSStringFromProtocol(viewProtocol));
    }
    return nil;
}

ZIKAnyViewRouterType *_Nullable _ZIKViewRouterToModule(Protocol *configProtocol) {
    NSCParameterAssert(configProtocol);
    if (!configProtocol) {
        [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToViewModule errorDescription:@"ZIKViewRouter.toModule() configProtocol is nil"];
        return nil;
    }
    
    ZIKRouterType *route = [ZIKViewRouteRegistry routerToModule:configProtocol];
    if ([route isKindOfClass:[ZIKViewRouterType class]]) {
        return (ZIKViewRouterType *)route;
    }
    [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToViewModule
                                        errorDescription:@"Didn't find view router for config protocol: %@, this protocol was not registered.",configProtocol];
    if (ZIKRouteRegistry.registrationFinished) {
        NSCAssert1(NO, @"Didn't find view router for config protocol: %@, this protocol was not registered.",NSStringFromProtocol(configProtocol));
    } else {
        NSCAssert1(NO, @"❌❌❌❌warning: failed to get router for view config protocol (%@), because manually registration is not finished yet! If there're modules running before registration is finished, and modules require some routers before you register them, then you should register those required routers earlier.",NSStringFromProtocol(configProtocol));
    }
    return nil;
}

ZIKAnyViewRouterType *_Nullable _ZIKViewRouterToIdentifier(NSString *identifier) {
    if (!identifier) {
        [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToView errorDescription:@"ZIKViewRouter.toIdentifier() identifier is nil"];
        return nil;
    }
    
    ZIKRouterType *route = [ZIKViewRouteRegistry routerToIdentifier:identifier];
    if ([route isKindOfClass:[ZIKViewRouterType class]]) {
        return (ZIKViewRouterType *)route;
    }
    return nil;
}

@implementation ZIKViewRouter (Discover)

+ (ZIKViewRouterType<id, ZIKViewRouteConfiguration *> *(^)(Protocol<ZIKViewRoutable> *))toView {
    return ^(Protocol *viewProtocol) {
        // 从静态全局的`CFDictionary`中通过`protocol`取出最开始注册的`ZIKRouter子类Class`(或实例对象),
        // 不管是`Class`还是`实例对象`都会被包装成`ZIKViewRouterType实例对象`,然后通过`ZIKViewRouterType实例对象`执行` performPath:configuring:`方法来生成`ZIKRouter`对象
        // 当要跳转时，执行`router`的`performRouteWithSuccessHandler:`方法即可；
        return _ZIKViewRouterToView(viewProtocol);
    };
}

+ (ZIKViewRouterType<id, ZIKViewRouteConfiguration *> *(^)(Protocol<ZIKViewModuleRoutable> *))toModule {
    return ^(Protocol *configProtocol) {
        return _ZIKViewRouterToModule(configProtocol);
    };
}

+ (NSArray<ZIKAnyViewRouterType *> *(^)(Class))routersToClass {
    return ^(Class destinationClass) {
        NSMutableArray<ZIKAnyViewRouterType *> *routers = [NSMutableArray array];
        NSParameterAssert([destinationClass conformsToProtocol:@protocol(ZIKRoutableView)]);
        [ZIKViewRouteRegistry enumerateRoutersForDestinationClass:[destinationClass class] handler:^(ZIKRouterType * _Nonnull route) {
            ZIKViewRouterType *r = (ZIKViewRouterType *)route;
            if (r) {
                [routers addObject:r];
            }
        }];
        return routers;
    };
}

+ (ZIKAnyViewRouterType *(^)(NSString *))toIdentifier {
    return ^(NSString *identifier) {
        ZIKAnyViewRouterType *routerType = _ZIKViewRouterToIdentifier(identifier);
        if (routerType) {
            return routerType;
        }
        [ZIKViewRouter notifyError_invalidProtocolWithAction:ZIKRouteActionToView
                                            errorDescription:@"Didn't find view router for identifier: %@, this identifier was not registered.",identifier];
        if (ZIKRouteRegistry.registrationFinished) {
            NSCAssert1(NO, @"Didn't find view router for identifier: %@, this identifier was not registered.",identifier);
        } else {
            NSCAssert1(NO, @"❌❌❌❌warning: failed to get router for view identifier (%@), because manually registration is not finished yet! If there're modules running before registration is finished, and modules require some routers before you register them, then you should register those required routers earlier.",identifier);
        }
        return routerType;
    };
}

@end
