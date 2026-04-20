#import <XCTest/XCTest.h>
@import EncoreObjC;

@interface EncoreObjCBridgeTests : XCTestCase
@end

@implementation EncoreObjCBridgeTests

- (void)testSharedSingletonExists {
    XCTAssertNotNil([EncoreClient shared]);
    XCTAssertEqual([EncoreClient shared], [EncoreClient shared], @"shared should be a singleton");
}

- (void)testConfigureAndIdentifyDoNotCrash {
    EncoreOptions *opts = [[EncoreOptions alloc] init];
    opts.logLevel = EncoreLogLevelNone;
    opts.unlockMode = EncoreUnlockModeOptimistic;

    XCTAssertNoThrow([[EncoreClient shared] configureWithApiKey:@"pk_test_bridge" options:opts]);

    EncoreUserAttributes *attrs = [[EncoreUserAttributes alloc] init];
    attrs.email = @"bridge-test@encorekit.com";
    attrs.subscriptionTier = @"free";
    XCTAssertNoThrow([[EncoreClient shared] identifyWithUserId:@"bridge-test" attributes:attrs]);
    XCTAssertNoThrow([[EncoreClient shared] setUserAttributes:attrs]);
}

- (void)testPlacementReturnsBuilder {
    EncorePlacementBuilder *b = [[EncoreClient shared] placement:@"unit_test_placement"];
    XCTAssertNotNil(b);
    XCTAssertTrue([b isKindOfClass:[EncorePlacementBuilder class]]);
}

- (void)testEntitlementFactoryMethods {
    EncoreEntitlement *ft = [EncoreEntitlement freeTrialWithValue:@7 unit:EncoreEntitlementUnitDays];
    XCTAssertEqual(ft.kind, EncoreEntitlementKindFreeTrial);
    XCTAssertEqualObjects(ft.value, @7);
    XCTAssertEqual(ft.unit, EncoreEntitlementUnitDays);

    EncoreEntitlement *d = [EncoreEntitlement discountWithValue:@20 unit:EncoreEntitlementUnitPercent];
    XCTAssertEqual(d.kind, EncoreEntitlementKindDiscount);
    XCTAssertEqualObjects(d.value, @20);

    EncoreEntitlement *c = [EncoreEntitlement creditWithValue:nil unit:EncoreEntitlementUnitUnspecified];
    XCTAssertEqual(c.kind, EncoreEntitlementKindCredit);
    XCTAssertNil(c.value);
    XCTAssertEqual(c.unit, EncoreEntitlementUnitUnspecified);
}

- (void)testPurchaseHandlerRegistration {
    XCTAssertNoThrow([[EncoreClient shared] onPurchaseRequest:^(EncorePurchaseRequest *request,
                                                                void (^done)(NSError *)) {
        done(nil);
    }]);
    XCTAssertNoThrow([[EncoreClient shared] onPassthrough:^(NSString *placementId) {
        // no-op
    }]);
}

@end
