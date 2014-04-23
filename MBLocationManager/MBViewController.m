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
@property (strong, nonatomic) IBOutlet UISwitch *updatingLocationSwitch;
@property (strong, nonatomic) IBOutlet UIButton *retrieveCurrentLocationButton;
@property (strong, nonatomic) IBOutlet UILabel *counter;

@property (strong, nonatomic) MBLocationManager *locationManager;

@end

@implementation MBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];

    self.locationManager = [MBLocationManager sharedManager];
    [self.locationManager addObserver:self];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [self.mapView setShowsUserLocation:TRUE];
    [self.mapView setUserTrackingMode:MKUserTrackingModeNone];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    [self.mapView setShowsUserLocation:FALSE];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Action
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

- (IBAction)updatingLocationSwitchTapped:(id)sender
{
    self.updatingLocationSwitch.selected = !self.updatingLocationSwitch.selected;

    MBLocationFilter filter= MBLocationFilterMake(kCLLocationAccuracyBest, 1.0);

    if (self.updatingLocationSwitch.selected) {
        [self.locationManager startUpdatingWithFilter:filter];
        NSLog(@"Start updating location with desiredAccuracy=%@ distanceFilter=%@",
                [NSNumber numberWithDouble:filter.accuracy],
                [NSNumber numberWithDouble:filter.distance]);
    } else {
        [self.locationManager stopUpdatingWithFilter:filter];
        NSLog(@"Stop updating location with desiredAccuracy=%@ distanceFilter=%@",
                [NSNumber numberWithDouble:filter.accuracy],
                [NSNumber numberWithDouble:filter.distance]);
    }

    self.counter.text = [NSString stringWithFormat:@"%d", (int) self.locationManager.count];
}

#pragma mark - MBLocationObserver
- (void)locationManager:(MBLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    CLLocation *location = [locations lastObject];
    NSLog(@"location=%@", location);
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

@end
