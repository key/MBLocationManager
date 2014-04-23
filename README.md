[![Build Status](https://travis-ci.org/key/MBLocationManager.svg?branch=develop)](https://travis-ci.org/key/MBLocationManager)

MBLocationManager
=================

MBLocationManagerはアプリケーション内で単一のLocationManagerインスタンスとして機能します（シングルトンオブジェクトとして機能します）。
位置情報取得開始時に任意の位置情報精度を設定することができ、設定された精度情報のうち最も高いものを利用して位置情報を取得し、複数のオブザーバへコールバックします。

位置情報を1度だけ取得する場合にも、ブロック構文で簡単に取得することが出来ます。


# 使い方

## LocationManagerの監視

```objectivec
import "MBLocationManager.h"

@implementation MBViewController {
	MBLocationManager *_locationManager;
}


- (void)viewDidLoad
{
	//MBLocationManagerのシングルトンインスタンス取得
	_locationManager = MBLocationManager sharedManager];

	//オブザーバの登録
	[_locationManager addObserver:self];
}

#pragma mark - MBLocationObserver
- (void)locationManager:(MBLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    [self.mapView setCenterCoordinate:location.coordinate animated:YES];
}

- (void)locationManager:(MBLocationManager *)manager didFailWithError:(NSError *)error
{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                    message:[error debugDescription]
                                                   delegate:nil
                                          cancelButtonTitle:@"Dismiss"
                                          otherButtonTitles:nil];
    [alert show];
}
```

## 位置情報を一度だけ取得

```objectivec
- (void)viewDidLoad
{
	// MBLocationManagerの初期化
	_locationManager = MBLocationManager sharedManager];
}

- (IBAction)retrieveButtonTapped:(id)sender
{
    [self.locationManager retrieveLocationWithBlock:^(CLLocation *location, NSError *error) {
        if (error) {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:[error debugDescription]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        } else {
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Success"
                                                            message:[NSString stringWithFormat:@"latitude=%f longitude=%f", location.coordinate.latitude, location.coordinate.longitude]
                                                           delegate:nil
                                                  cancelButtonTitle:@"Dismiss"
                                                  otherButtonTitles:nil];
            [alert show];
        }
    }];
}
```
