//
// Created by Mitsukuni Sato on 1/24/14.
// Copyright (c) 2014 MyBike. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "MBLocationManager.h"


@interface MBLocationManager ()

@property (nonatomic) NSUInteger count;
@property (nonatomic) NSUInteger appRecoveryCount;
@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) CLLocationManager *appRecoveryLocationManager;
@property (nonatomic, strong) NSMutableArray *desiredAccuracies;
@property (nonatomic, strong) NSMutableArray *distanceFilters;
@property (nonatomic, strong) NSMutableArray *locationUpdateBlocks;
@property (nonatomic) CLLocationAccuracy desiredAccuracy;
@property (nonatomic) CLLocationAccuracy distanceFilter;

@end


@interface MBLocationManagerTests : XCTestCase <MBLocationObserver>
@end


@implementation MBLocationManagerTests {
    MBLocationManager *locationManager;
}

- (void)setUp
{
    [super setUp];

    locationManager = [[MBLocationManager alloc] init];
    locationManager.locationManager.delegate = nil;
}

- (void)tearDown
{
    [super tearDown];

    locationManager = nil;
}

- (void)testLocationServiceEnabled
{
    XCTAssertTrue([MBLocationManager locationServicesEnabled]);
}

- (void)testSharedManager
{
    MBLocationManager *manager1 = [MBLocationManager sharedManager];
    XCTAssertTrue([manager1 isKindOfClass:[MBLocationManager class]]);
    XCTAssertTrue([manager1.locationManager isKindOfClass:[CLLocationManager class]]);
    XCTAssertEqualObjects(manager1.locationManager.delegate, manager1);
    
    MBLocationManager *manager2 = [MBLocationManager sharedManager];
    XCTAssertTrue([manager2 isKindOfClass:[MBLocationManager class]]);
    
    XCTAssertEqualObjects(manager1, manager2);
}

- (void)testDesiredAccuracy
{
    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    XCTAssert([locationManager.desiredAccuracies count] == 1);

    locationManager.desiredAccuracy = kCLLocationAccuracyThreeKilometers;
    XCTAssert([locationManager.desiredAccuracies count] == 2);

    locationManager.desiredAccuracy = kCLLocationAccuracyKilometer;
    XCTAssert([locationManager.desiredAccuracies count] == 3);

    locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters;
    XCTAssert([locationManager.desiredAccuracies count] == 4);

    locationManager.desiredAccuracy = kCLLocationAccuracyNearestTenMeters;
    XCTAssert([locationManager.desiredAccuracies count] == 5);

    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    XCTAssert([locationManager.desiredAccuracies count] == 6);

    locationManager.desiredAccuracy = kCLLocationAccuracyBestForNavigation;
    XCTAssert([locationManager.desiredAccuracies count] == 7);

    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyBestForNavigation);
}

- (void)testDistanceFilter
{
    locationManager.distanceFilter = kCLLocationAccuracyThreeKilometers;
    XCTAssert([locationManager.distanceFilters count] == 1);

    locationManager.distanceFilter = kCLLocationAccuracyKilometer;
    XCTAssert([locationManager.distanceFilters count] == 2);

    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyKilometer);
}

- (void)testStartUpdating
{
    [locationManager startUpdatingWithDesiredAccuracy:kCLLocationAccuracyKilometer distanceFilter:kCLLocationAccuracyKilometer];
    XCTAssert([locationManager.desiredAccuracies count] == 1);
    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyKilometer);
    XCTAssert([locationManager.distanceFilters count] == 1);
    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyKilometer);

    XCTAssert(locationManager.count == 1);

    [locationManager startUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyNearestTenMeters];
    XCTAssert([locationManager.desiredAccuracies count] == 2);
    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyBest);
    XCTAssert([locationManager.distanceFilters count] == 2);
    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyNearestTenMeters);

    XCTAssert(locationManager.count == 2);
}

- (void)testStopUpdating
{
    // カウンタチェック
    XCTAssert(locationManager.count == 0);
    [locationManager stopUpdatingWithDesiredAccuracy:kCLLocationAccuracyNearestTenMeters distanceFilter:kCLLocationAccuracyBest];

    // 精度チェック
    [locationManager startUpdatingWithDesiredAccuracy:kCLLocationAccuracyThreeKilometers distanceFilter:kCLLocationAccuracyThreeKilometers];
    [locationManager startUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
    [locationManager startUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyBest);
    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyBest);

    [locationManager stopUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyBest);
    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyBest);

    [locationManager stopUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
    XCTAssert(locationManager.count == 1);
    XCTAssert(locationManager.distanceFilter == kCLLocationAccuracyThreeKilometers);
    XCTAssert(locationManager.desiredAccuracy == kCLLocationAccuracyThreeKilometers);

    [locationManager stopUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
    XCTAssert(locationManager.count == 0);
}

- (void)testAddObservers
{
    [locationManager addObserver:self];
    XCTAssertTrue([locationManager.observers containsObject:self]);
}

- (void)testRemoveObservers
{
    [locationManager removeObserver:self];
    XCTAssertTrue(![locationManager.observers containsObject:self]);
}

- (void)testDidUpdateLocations
{
    CLLocation *location = [[CLLocation alloc] initWithLatitude:39.5 longitude:135.0];
    [locationManager locationManager:nil didUpdateLocations:@[location]];

    XCTAssertEqualObjects(locationManager.lastLocation, location);
}

- (void)testAppRecovery
{
    // 初期状態ではapp recoveryオフ
    XCTAssertFalse(locationManager.appRecovery);
    XCTAssertTrue(locationManager.appRecoveryCount == 0);
    XCTAssertNil(locationManager.appRecoveryLocationManager);

    // カウンタチェック
    [locationManager setAppRecovery:TRUE];

    XCTAssertTrue(locationManager.appRecovery);
    XCTAssertTrue(locationManager.appRecoveryCount == 1);
    XCTAssert(locationManager.appRecoveryLocationManager);

    [locationManager setAppRecovery:TRUE];

    XCTAssertTrue(locationManager.appRecovery);
    XCTAssertTrue(locationManager.appRecoveryCount == 2);
    XCTAssert(locationManager.appRecoveryLocationManager);

    // カウンタチェック
    [locationManager setAppRecovery:FALSE];

    XCTAssertTrue(locationManager.appRecovery);
    XCTAssertTrue(locationManager.appRecoveryCount == 1);
    XCTAssert(locationManager.appRecoveryLocationManager);

    // カウンタがゼロになったらlocation managerを破棄
    [locationManager setAppRecovery:FALSE];

    XCTAssertTrue(locationManager.appRecoveryCount == 0);
    XCTAssertFalse(locationManager.appRecovery);
    XCTAssertNil(locationManager.appRecoveryLocationManager);
}

- (void)testRetrieveLocationWithBlock
{
    __block CLLocation *newLocation = nil;
    __block NSError *newError = nil;
    void (^b)(CLLocation *location, NSError *error) = ^(CLLocation *location, NSError *error) {
        newLocation = location;
        newError = error;
    };

    CLLocation *dummyLocation = [[CLLocation alloc] initWithLatitude:45.5 longitude:-120.0];

    // 正常取得。ブロック数と値チェック。
    [locationManager retrieveLocationWithBlock:b];
    XCTAssertTrue([locationManager.locationUpdateBlocks count] == 1);
    XCTAssertTrue(locationManager.count == 1);

    [locationManager locationManager:nil didUpdateLocations:@[dummyLocation]];
    XCTAssertTrue([locationManager.locationUpdateBlocks count] == 0);
    XCTAssertTrue(locationManager.count == 0);
    XCTAssertTrue([newLocation isKindOfClass:[CLLocation class]]);
    XCTAssertEqual(newLocation, dummyLocation);
    XCTAssertNil(newError);

    // 取得エラー
    [locationManager retrieveLocationWithBlock:b];
    XCTAssertTrue([locationManager.locationUpdateBlocks count] == 1);

    NSError *dummyError = [[NSError alloc] init];
    [locationManager locationManager:nil didFailWithError:dummyError];
    XCTAssertTrue([locationManager.locationUpdateBlocks count] == 0);
    XCTAssertNil(newLocation);
    XCTAssertEqual(newError, dummyError);

    //nilブロックは実行されない
    [locationManager retrieveLocationWithBlock:nil];
    XCTAssertTrue([locationManager.locationUpdateBlocks count] == 0);
    XCTAssertTrue(locationManager.count == 0);
}

@end
