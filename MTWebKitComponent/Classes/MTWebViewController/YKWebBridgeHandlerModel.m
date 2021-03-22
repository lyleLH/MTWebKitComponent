//
//  MTWebBridgeHandlerModel.m
//  YKWebKitComponent
//
//  Created by Tom.Liu on 2021/3/16.
//

#import "MTWebBridgeHandlerModel.h"


@implementation MTWebBridgeHandlerModel

- (id)dataToPassTojS {
    NSString * JsString = [NSString stringWithFormat:@"%@(%@)",kNativeCallJSMethodName,[self mj_keyValues]];
    return JsString;
}


@end



