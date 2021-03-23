//
//  MTWebBridgeHandlerAction.h
//  MTWebKitComponent
//
//  Created by Tom.Liu on 2021/3/18.
//

#import <Foundation/Foundation.h>
#import "MTWebBridgeHandlerModel.h"
NS_ASSUME_NONNULL_BEGIN

//static变量的作用域被限制在单一的文件中,所以改成 MTWebBridgeActionCenter的静态成员方法 返回一个变量

//static NSMutableArray *sytNotificationActions() {
//    static NSMutableArray *notificationActions;
//    static dispatch_once_t onceToken;
//    dispatch_once(&onceToken, ^{
//        notificationActions = [NSMutableArray new];
//    });
//    return notificationActions;
//};


static dispatch_queue_t webBridgeHandlerActionsQueue() {
    static dispatch_queue_t queue;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        queue = dispatch_queue_create("com.shouyintong.SYTNotification.notificationActions.queue", DISPATCH_QUEUE_CONCURRENT);
//        NSLog(@"---");
    });
    return queue;
}



static dispatch_semaphore_t _webBridgeHandlerActionsLock() {
   static dispatch_semaphore_t notificationActionsLock;
   static dispatch_once_t onceToken;
   dispatch_once(&onceToken, ^{
       notificationActionsLock = dispatch_semaphore_create(1);
   });
   return notificationActionsLock;
}


static inline void webBridgeHandlerActionsLock() {
    dispatch_semaphore_wait(_webBridgeHandlerActionsLock(), DISPATCH_TIME_FOREVER);
}

static inline void webBridgeHandlerActionsUnLock() {
    dispatch_semaphore_signal(_webBridgeHandlerActionsLock());
}

//
//static void registerAction(Class action) {
//    dispatch_async(webBridgeHandlerActionsQueue(), ^{
//        webBridgeHandlerActionsLock();
//        
//        [webBridgeHandlerActions() addObject:NSStringFromClass(action)];
//        NSLog(@"-------- 11 --- %@,%@",action,webBridgeHandlerActions() );
//        webBridgeHandlerActionsUnLock();
//    });
//}
//


@interface MTWebBridgeHandlerAction : NSObject

 

- (instancetype)initWithFunctionModel:(MTWebBridgeHandlerModel*)model;

- (void)processTheFunction;

@end


@interface MTWebBridgeActionCenter : NSObject

+ (instancetype)center ;
 
+ (void)registerAction:(Class)action;


+ (NSMutableArray *)handlerActions ;

@end



NS_ASSUME_NONNULL_END
