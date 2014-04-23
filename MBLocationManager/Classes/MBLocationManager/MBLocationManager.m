//
// Created by Mitsukuni Sato on 1/24/14.
// Copyright (c) 2014 MyBike. All rights reserved.
//

#import "MBLocationManager.h"


@interface MBLocationManager ()

@property (nonatomic, strong) CLLocationManager *locationManager;
@property (nonatomic, strong) NSMutableArray *locationUpdateBlocks;
@property (nonatomic, strong) NSMutableArray *desiredAccuracies;
@property (nonatomic, strong) NSMutableArray *distanceFilters;

@end

MBLocationFilter MBLocationFilterMake(CLLocationAccuracy accuracy, CLLocationDistance distance) {
    MBLocationFilter filter = {accuracy, distance};
    return filter;
}

static MBLocationManager *manager = nil;

@implementation MBLocationManager {
    NSUInteger _count;
    NSMutableArray *_desiredAccuracies;
    NSMutableArray *_distanceFilters;
}

+ (BOOL)locationServicesEnabled
{
    return [CLLocationManager locationServicesEnabled];
}

+ (instancetype)sharedManager
{
    static dispatch_once_t once;
    dispatch_once(&once, ^{
        manager = [[MBLocationManager alloc] init];
    });

    return manager;
}

- (id)init
{
    self = [super init];
    if (self) {
        _count = 0;
        _locationManager = [[CLLocationManager alloc] init];
        _locationManager.delegate = self;
        _observers = [[NSMutableArray alloc] init];

        [self clear];
    }
    return self;
}

- (void)startUpdatingWithFilter:(MBLocationFilter)filter
{
    _count++;

    double old_desired_accuracy = self.desiredAccuracy;
    double old_distance_filter = self.distanceFilter;

    self.desiredAccuracy = filter.accuracy;
    self.distanceFilter = filter.distance;

    double new_desired_accuracy = self.desiredAccuracy;
    double new_distance_filter = self.distanceFilter;

    if (new_desired_accuracy < old_desired_accuracy || new_distance_filter < old_distance_filter) {
        [self refresh];
    }
}

- (void)stopUpdatingWithFilter:(MBLocationFilter)filter
{
    if (_count > 0) {
        _count--;

        NSUInteger idx;

        NSNumber *accuracyNumber = [NSNumber numberWithDouble:filter.accuracy];
        if ([_desiredAccuracies containsObject:accuracyNumber]) {
            idx = [_desiredAccuracies indexOfObject:accuracyNumber];
            [_desiredAccuracies removeObjectAtIndex:idx];
        }

        NSNumber *distanceNumber = [NSNumber numberWithDouble:filter.distance];
        if ([_distanceFilters containsObject:distanceNumber]) {
            idx = [_distanceFilters indexOfObject:distanceNumber];
            [_distanceFilters removeObjectAtIndex:idx];
        }
    }

    // カウンタがゼロなら精度情報をクリアする
    if (_count == 0) {
        [self clear];
    }

    [self refresh];
}

- (void)retrieveLocationWithBlock:(MBLocationUpdateBlock)locationUpdateBlock
{
    if (locationUpdateBlock) {
        [_locationUpdateBlocks addObject:locationUpdateBlock];
        [self startUpdatingWithFilter:MBLocationFilterMake(kCLLocationAccuracyBest, kCLLocationAccuracyBest)];
    }
}

- (void)clear
{
    _locationUpdateBlocks = [[NSMutableArray alloc] initWithCapacity:0];
    _desiredAccuracies = [[NSMutableArray alloc] initWithCapacity:0];
    _distanceFilters = [[NSMutableArray alloc] initWithCapacity:0];
}

- (void)refresh
{
    [_locationManager stopUpdatingLocation];

    _locationManager.desiredAccuracy = self.desiredAccuracy;
    _locationManager.distanceFilter = self.distanceFilter;

    if (_count > 0) {
        [_locationManager startUpdatingLocation];
    }
}

#pragma mark - Setter / Getter
/* 設定されている精度のうち、最も高いものを返す。 */
- (CLLocationAccuracy)desiredAccuracy
{
    return [[_desiredAccuracies valueForKeyPath:@"@min.self"] doubleValue];
}

- (void)setDesiredAccuracy:(CLLocationAccuracy)desiredAccuracy
{
    [_desiredAccuracies addObject:[NSNumber numberWithDouble:desiredAccuracy]];
}

- (CLLocationAccuracy)distanceFilter
{
    return [[_distanceFilters valueForKeyPath:@"@min.self"] doubleValue];
}

- (void)setDistanceFilter:(CLLocationAccuracy)distanceFilter
{
    [_distanceFilters addObject:[NSNumber numberWithDouble:distanceFilter]];
}

- (void)addObserver:(id <MBLocationObserver>)observer
{
    [_observers addObject:observer];
}

- (void)removeObserver:(id <MBLocationObserver>)observer
{
    [_observers removeObject:observer];
}

#pragma mark - CLLocationManagerDelegate
- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *lastLocation = [locations lastObject];
    if (lastLocation) {
        _lastLocation = lastLocation;
    }

    for (id observer in _observers) {
        if ([observer respondsToSelector:@selector(locationManager:didUpdateLocations:)]) {
            [observer performSelector:@selector(locationManager:didUpdateLocations:)
                           withObject:self
                           withObject:locations];
        }
    }

    for (MBLocationUpdateBlock locationUpdateBlock in _locationUpdateBlocks) {
        locationUpdateBlock(_lastLocation, nil);
        [_locationUpdateBlocks removeObject:locationUpdateBlock];
        [self stopUpdatingWithFilter:MBLocationFilterMake(kCLLocationAccuracyBest, kCLLocationAccuracyBest)];
    }
}

- (void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error
{
    for (id observer in _observers) {
        if ([observer respondsToSelector:@selector(locationManager:didFailWithError:)]) {
            [observer performSelector:@selector(locationManager:didFailWithError:)
                           withObject:self
                           withObject:error];
        }
    }

    for (MBLocationUpdateBlock locationUpdateBlock in _locationUpdateBlocks) {
        locationUpdateBlock(nil, error);
        [_locationUpdateBlocks removeObject:locationUpdateBlock];
        [self stopUpdatingWithFilter:MBLocationFilterMake(kCLLocationAccuracyBest, kCLLocationAccuracyBest)];
    }
}

@end