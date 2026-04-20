#import "AppDelegate.h"
@import EncoreObjC;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    EncoreOptions *options = [[EncoreOptions alloc] init];
    options.logLevel   = EncoreLogLevelDebug;
    options.unlockMode = EncoreUnlockModeOptimistic;
    [[EncoreClient shared] configureWithApiKey:@"pk_test_demo_key" options:options];

    EncoreUserAttributes *attrs = [[EncoreUserAttributes alloc] init];
    attrs.email = @"demo@encorekit.com";
    attrs.subscriptionTier = @"free";
    [[EncoreClient shared] identifyWithUserId:@"user_demo_1" attributes:attrs];

    [[EncoreClient shared] onPurchaseRequest:^(EncorePurchaseRequest *request,
                                               void (^done)(NSError *error)) {
        NSLog(@"[ObjCDemo] purchase request productId=%@ placementId=%@",
              request.productId, request.placementId);
        done(nil);
    }];

    [[EncoreClient shared] onPassthrough:^(NSString *placementId) {
        NSLog(@"[ObjCDemo] passthrough for placement %@", placementId);
    }];

    return YES;
}

- (UISceneConfiguration *)application:(UIApplication *)application
    configurationForConnectingSceneSession:(UISceneSession *)connectingSceneSession
                                   options:(UISceneConnectionOptions *)options {
    return [[UISceneConfiguration alloc] initWithName:@"Default Configuration"
                                          sessionRole:connectingSceneSession.role];
}

@end
