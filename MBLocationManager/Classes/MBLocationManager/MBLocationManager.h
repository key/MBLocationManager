//
// Created by Mitsukuni Sato on 1/24/14.
// Copyright (c) 2014 MyBike. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreLocation/CoreLocation.h>

@protocol MBLocationObserver;


typedef struct {
    CLLocationAccuracy accuracy;
    CLLocationDistance distance;
} MBLocationFilter;
typedef void (^MBLocationUpdateBlock)(CLLocation *location, NSError *error);

MBLocationFilter MBLocationFilterMake(CLLocationAccuracy accuracy, CLLocationDistance distance);


@interface MBLocationManager : NSObject <CLLocationManagerDelegate>

@property (nonatomic, readonly) NSUInteger count;
@property (nonatomic, readonly) CLLocationAccuracy desiredAccuracy;
@property (nonatomic, readonly) CLLocationDistance distanceFilter;
@property (nonatomic, strong, readonly) CLLocationManager *locationManager;
@property (nonatomic, strong, readonly) NSMutableArray *observers;
@property (nonatomic, strong, readonly) CLLocation *lastLocation;

+ (BOOL)locationServicesEnabled;

/* MBLocationManagerのインスタスを取得します */
+ (instancetype)sharedManager;

/* 指定された精度で位置情報取得を開始します */
- (void)startUpdatingWithFilter:(MBLocationFilter)filter;

/* 指定された精度の位置情報取得を停止します */
- (void)stopUpdatingWithFilter:(MBLocationFilter)filter;

/* 1度だけ最高の精度で位置情報を取得します。 */
- (void)retrieveLocationWithBlock:(MBLocationUpdateBlock)locationUpdateBlock;

/* 位置情報を受け取るオブザーバを追加します */
- (void)addObserver:(id <MBLocationObserver>)observer;

/* 位置情報を受け取るオブザーバを削除します */
- (void)removeObserver:(id <MBLocationObserver>)observer;

@end


@protocol MBLocationObserver <NSObject>

@optional
/* 位置情報を取得します */
- (void)locationManager:(MBLocationManager *)manager didUpdateLocations:(NSArray *)locations;

/* 位置情報取得時のエラーを取得します */
- (void)locationManager:(MBLocationManager *)manager didFailWithError:(NSError *)error;

@end
