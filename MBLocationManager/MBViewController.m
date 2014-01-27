//
//  MBViewController.m
//  MBLocationManager
//
//  Created by Mitsukuni Sato on 1/27/14.
//  Copyright (c) 2014 MyBike. All rights reserved.
//

#import <MapKit/MapKit.h>
#import "MBViewController.h"

@interface MBViewController ()

@property (strong, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) IBOutlet UISegmentedControl *updatingLocationSegCtrl;
@property (strong, nonatomic) IBOutlet UISegmentedControl *appRecoverySegCtrl;
@property (strong, nonatomic) MBLocationManager *locationManager;

@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    [self.updatingLocationSegCtrl addObserver:self
                                   forKeyPath:@"selectedSegmentIndex"
                                      options:nil
                                      context:nil];
    [self.appRecoverySegCtrl addObserver:self
                              forKeyPath:@"selectedSegmentIndex"
                                 options:nil
                                 context:nil];

    self.locationManager = [MBLocationManager sharedManager];
    [self.locationManager addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView setShowsUserLocation:TRUE];
}

-(void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView setShowsUserLocation:FALSE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
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

#pragma mark - KVO
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"selectedSegmentIndex"] && [object isEqual:self.updatingLocationSegCtrl]) {
        double desiredAccuracy = kCLLocationAccuracyBest;
        double distanceFilter = kCLLocationAccuracyBest;

        if (self.updatingLocationSegCtrl.selectedSegmentIndex == 0) {
            [self.locationManager startUpdatingWithDesiredAccuracy:desiredAccuracy distanceFilter:distanceFilter];
            NSLog(@"Start updating location with desiredAccuracy=%@ distanceFilter=%@",
                    [NSNumber numberWithDouble:desiredAccuracy],
                    [NSNumber numberWithDouble:distanceFilter]);
        } else if (self.updatingLocationSegCtrl.selectedSegmentIndex == 1) {
            [self.locationManager stopUpdatingWithDesiredAccuracy:kCLLocationAccuracyBest distanceFilter:kCLLocationAccuracyBest];
            NSLog(@"Stop updating location with desiredAccuracy=%@ distanceFilter=%@",
                    [NSNumber numberWithDouble:desiredAccuracy],
                    [NSNumber numberWithDouble:distanceFilter]);
        }

    } else if ([keyPath isEqualToString:@"selectedSegmentIndex"] && [object isEqual:self.appRecoverySegCtrl]) {
        self.locationManager.appRecovery = (self.updatingLocationSegCtrl.selectedSegmentIndex == 0) ? TRUE : FALSE;

        NSLog(@"AppRecovery set to %@", [NSNumber numberWithBool:self.locationManager.appRecovery]);
    } else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

@end
