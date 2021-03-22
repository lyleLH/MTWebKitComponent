//
//  MTWebBridgeHandlerAction.m
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/18.
//

#import "MTWebBridgeHandlerAction.h"


@implementation MTWebBridgeHandlerAction


- (instancetype)initWithFunctionModel:(MTWebBridgeHandlerModel*)model {
    if (self = [super init]) {
        
    }
    return self;
}

- (void)processTheFunction {}


@end

 

@implementation MTWebBridgeActionCenter

+ (instancetype)center {
    static MTWebBridgeActionCenter *center;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        center = [[MTWebBridgeActionCenter alloc] init];
    });
    return center;
}


+ (void)registerAction:(Class)action {
    dispatch_async(webBridgeHandlerActionsQueue(), ^{
        webBridgeHandlerActionsLock();
        [[self handlerActions] addObject:NSStringFromClass(action)];
        webBridgeHandlerActionsUnLock();
    });
}

+ (dispatch_queue_t) webBridgeHandlerActionsQueue {
    
    return webBridgeHandlerActionsQueue();
}

+ (NSMutableArray *)handlerActions {
    static NSMutableArray *actions;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        actions = [NSMutableArray new];
    });
    return actions;
}

@end

