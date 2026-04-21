#import "AppDelegate.h"
@import EncoreObjC;

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application
    didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {

    // Seeded local-dev key (encore-backend/packages/db/src/seeds/seed.ts).
    // Paired with Xcode scheme env var `EncoreEnvironment = local` → backend
    // must be running on localhost:4000. For production use a real pk_live_.
    EncoreOptions *options = [[EncoreOptions alloc] init];
    options.logLevel   = EncoreLogLevelDebug;
    options.unlockMode = EncoreUnlockModeOptimistic;
    [[EncoreClient shared] configureWithApiKey:@"pk_test_13l47ocax6k9uev981kq0tle" options:options];

    EncoreUserAttributes *attrs = [[EncoreUserAttributes alloc] init];
    attrs.email = @"demo@encorekit.com";
    attrs.subscriptionTier = @"free";
    // Forces the post-grant purchase path to fire — SDK falls back to
    // userAttributes.iapProductId when the placement's remote config has no
    // iapProductId of its own. Purely for exercising onPurchaseRequest end-to-end.
    attrs.iapProductId = @"com.encorekit.monthly_premium";
    [[EncoreClient shared] identifyWithUserId:@"demo_user_objc_001" attributes:attrs];

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
