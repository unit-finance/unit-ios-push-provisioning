//
//  UNPushProvisioningAppLoaderBridge.m
//  UnitPushProvisioning
//

#import <Foundation/Foundation.h>

@interface UNPushProvisioningAppLoaderBridge : NSObject
@end

@implementation UNPushProvisioningAppLoaderBridge

// Runs when the framework is loaded at app start, so the SDK can observe the launch without the host calling it.
// The Swift loader is looked up by name because this file is built as a separate target in the Swift package.
+ (void)load {
    id loader = [NSClassFromString(@"UNPushProvisioningAppLoader") new];
    SEL appLoaded = NSSelectorFromString(@"appLoaded");
    if ([loader respondsToSelector:appLoaded]) {
#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
        [loader performSelector:appLoaded];
#pragma clang diagnostic pop
    }
}

@end
