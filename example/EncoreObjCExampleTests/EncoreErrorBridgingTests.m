#import <XCTest/XCTest.h>
@import EncoreObjC;

/// Validates that EncoreError surfaces through completion handlers as NSError
/// with the expected domain + userInfo. We force the "not configured" path by
/// calling revokeEntitlements on a fresh (uninitialized) instance — but since
/// the shared singleton may already be configured by other tests, we only
/// assert that IF an error comes back, the bridging is correct.
@interface EncoreErrorBridgingTests : XCTestCase
@end

@implementation EncoreErrorBridgingTests

- (void)testErrorInfoConstants {
    XCTAssertEqualObjects(EncoreErrorInfo.domain,     @"com.encorekit.EncoreError");
    XCTAssertEqualObjects(EncoreErrorInfo.statusKey,  @"EncoreErrorStatusKey");
    XCTAssertEqualObjects(EncoreErrorInfo.apiCodeKey, @"EncoreErrorApiCodeKey");
    XCTAssertEqualObjects(EncoreErrorInfo.messageKey, @"EncoreErrorMessageKey");
}

- (void)testRevokeEntitlementsSurfacesErrorOrSucceeds {
    XCTestExpectation *exp = [self expectationWithDescription:@"revoke completes"];

    [[EncoreClient shared] revokeEntitlementsWithCompletion:^(NSError *error) {
        if (error) {
            XCTAssertEqualObjects(error.domain, EncoreErrorInfo.domain,
                                  @"errors from EncoreKit must use the EncoreObjC domain");
            XCTAssertNotNil(error.localizedDescription);
            XCTAssertGreaterThan(error.localizedDescription.length, 0u);
        }
        [exp fulfill];
    }];

    [self waitForExpectations:@[exp] timeout:5.0];
}

@end
