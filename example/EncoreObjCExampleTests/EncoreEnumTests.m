#import <XCTest/XCTest.h>
@import EncoreObjC;

/// Locks NS_ENUM raw values. These values are part of the public ABI —
/// a patch release must NOT reorder them. When the Swift SDK adds new cases,
/// append to the end (never renumber) and add assertions here.
@interface EncoreEnumTests : XCTestCase
@end

@implementation EncoreEnumTests

- (void)testLogLevelRawValues {
    XCTAssertEqual(EncoreLogLevelNone,  0);
    XCTAssertEqual(EncoreLogLevelError, 1);
    XCTAssertEqual(EncoreLogLevelWarn,  2);
    XCTAssertEqual(EncoreLogLevelInfo,  3);
    XCTAssertEqual(EncoreLogLevelDebug, 4);
}

- (void)testUnlockModeRawValues {
    XCTAssertEqual(EncoreUnlockModeOptimistic, 0);
    XCTAssertEqual(EncoreUnlockModeStrict,     1);
}

- (void)testEntitlementScopeRawValues {
    XCTAssertEqual(EncoreEntitlementScopeAll,      0);
    XCTAssertEqual(EncoreEntitlementScopeVerified, 1);
}

- (void)testEntitlementKindRawValues {
    XCTAssertEqual(EncoreEntitlementKindFreeTrial, 0);
    XCTAssertEqual(EncoreEntitlementKindDiscount,  1);
    XCTAssertEqual(EncoreEntitlementKindCredit,    2);
}

- (void)testEntitlementUnitRawValues {
    XCTAssertEqual(EncoreEntitlementUnitUnspecified, 0);
    XCTAssertEqual(EncoreEntitlementUnitMonths,      1);
    XCTAssertEqual(EncoreEntitlementUnitDays,        2);
    XCTAssertEqual(EncoreEntitlementUnitPercent,     3);
    XCTAssertEqual(EncoreEntitlementUnitDollars,     4);
}

- (void)testPresentationKindRawValues {
    XCTAssertEqual(EncorePresentationKindGranted,    0);
    XCTAssertEqual(EncorePresentationKindNotGranted, 1);
}

- (void)testNotGrantedReasonRawValues {
    XCTAssertEqual(EncoreNotGrantedReasonNone,              0);
    XCTAssertEqual(EncoreNotGrantedReasonUserTappedClose,   1);
    XCTAssertEqual(EncoreNotGrantedReasonUserSwipedDown,    2);
    XCTAssertEqual(EncoreNotGrantedReasonUserTappedOutside, 3);
    XCTAssertEqual(EncoreNotGrantedReasonUserCancelled,     4);
    XCTAssertEqual(EncoreNotGrantedReasonLastOfferDeclined, 5);
    XCTAssertEqual(EncoreNotGrantedReasonDismissed,         6);
    XCTAssertEqual(EncoreNotGrantedReasonNoOffersAvailable, 7);
    XCTAssertEqual(EncoreNotGrantedReasonUnsupportedOS,     8);
    XCTAssertEqual(EncoreNotGrantedReasonExperimentControl, 9);
}

- (void)testErrorCodeRawValues {
    XCTAssertEqual(EncoreErrorCodeTransportNetwork,         100);
    XCTAssertEqual(EncoreErrorCodeTransportPersistence,     101);
    XCTAssertEqual(EncoreErrorCodeProtocolHTTP,             200);
    XCTAssertEqual(EncoreErrorCodeProtocolAPI,              201);
    XCTAssertEqual(EncoreErrorCodeProtocolDecoding,         202);
    XCTAssertEqual(EncoreErrorCodeIntegrationNotConfigured, 300);
    XCTAssertEqual(EncoreErrorCodeIntegrationInvalidApiKey, 301);
    XCTAssertEqual(EncoreErrorCodeIntegrationInvalidURL,    302);
    XCTAssertEqual(EncoreErrorCodeDomain,                   400);
}

@end
