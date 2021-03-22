//
//  MTWebBridgeHandlerModel.h
//  YKWebKitComponent
//
//  Created by Tom.Liu on 2021/3/16.
//

#import <Foundation/Foundation.h>
#import <MJExtension/MJExtension.h>



NS_ASSUME_NONNULL_BEGIN

static NSString * kJsCallNativeMethodName = @"invokeNativeByH5";
static NSString * kNativeCallJSMethodName = @"invokeH5ByNative";

@interface MTWebBridgeHandlerModel : NSObject

@property (nonatomic,copy)NSString * methodName;
@property (nonatomic,strong)NSDictionary * params;

- (id)dataToPassTojS;

@end

 

NS_ASSUME_NONNULL_END
