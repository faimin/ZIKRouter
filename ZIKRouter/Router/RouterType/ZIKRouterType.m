//
//  ZIKRouterType.m
//  ZIKRouter
//
//  Created by zuik on 2018/1/21.
//  Copyright © 2017 zuik. All rights reserved.
//
//  This source code is licensed under the MIT-style license found in the
//  LICENSE file in the root directory of this source tree.
//

#import "ZIKRouterType.h"
#import "ZIKRoute.h"
#import "ZIKRouter.h"

@interface ZIKRouterType()
@property (nonatomic, strong) Class routerClass;
@property (nonatomic, strong) ZIKRoute *route;
@end

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wincomplete-implementation"

@implementation ZIKRouterType

- (nullable instancetype)initWithRouterClass:(Class)routerClass {
    if ([routerClass class] != routerClass) {
        return nil;
    }
    if ([routerClass isSubclassOfClass:[ZIKRouter class]] == NO) {
        return nil;
    }
    if (self = [super init]) {
        _routerClass = routerClass;
    }
    return self;
}

- (nullable instancetype)initWithRoute:(ZIKRoute *)route {
    NSParameterAssert(route);
    if (self = [super init]) {
        _route = route;
    }
    return self;
}

+ (nullable instancetype)tryMakeRouterTypeForRoute:(id)route {
    ZIKRouterType *routerType = [[self alloc] initWithRouterClass:route];
    if (routerType) {
        return routerType;
    }
    routerType = [[self alloc] initWithRoute:route];
    if (routerType) {
        return routerType;
    }
    return nil;
}

- (id)routeObject {
    if (_routerClass) {
        return _routerClass;
    }
    return _route;
}

- (BOOL)respondsToSelector:(SEL)aSelector {
    if ([super respondsToSelector:aSelector]) {
        return YES;
    }
    return [self.routeObject respondsToSelector:aSelector];
}

- (BOOL)conformsToProtocol:(Protocol *)protocol {
    if ([super conformsToProtocol:protocol]) {
        return YES;
    }
    return [self.routeObject conformsToProtocol:protocol];
}

- (id)forwardingTargetForSelector:(SEL)aSelector {
    // 转发给routeObject中同名的类方法或者实例方法;
    // runtime不区分aSelector到底是实例方法还是类方法,在runtime眼里aSelector只是一个字符串,触发消息转发的时候会执行到这里把方法转发给routeObject处理,如果routeObject是实例就调用与aSelector同名的实例方法,是Class就调用与aSelector同名的类方法;
    return self.routeObject;
}

- (NSString *)description {
    if (self.routerClass) {
        return [NSString stringWithFormat:@"%@: routerClass: %@",[super description], NSStringFromClass(self.routerClass)];
    } else {
        return [NSString stringWithFormat:@"%@: route: %@",[super description], self.route];
    }
}

@end

#pragma clang diagnostic pop
