//
//  EventDetailViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/5/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EventDetailViewController.h"
#import "EventAnnotation.h"
#import "CreateMessageViewController.h"

@interface EventDetailViewController ()

@property (weak, nonatomic) IBOutlet UIImageView *statusBarIV;
@property (weak, nonatomic) IBOutlet UIImageView *eventIV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *eventPhotoActivityIndicator;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *avatarActivityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *eventNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerLabel;
@property (weak, nonatomic) IBOutlet UILabel *organizerNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *distanceLabel;
@property (weak, nonatomic) IBOutlet UIView *attendingTabRoundedBackground;
@property (weak, nonatomic) IBOutlet UIView *attendingTabRectangleBackground;
@property (weak, nonatomic) IBOutlet UILabel *goingLabel;
@property (weak, nonatomic) IBOutlet UILabel *attendingAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationLabel;
@property (weak, nonatomic) IBOutlet UILabel *locationNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceAvailableLabel;
@property (weak, nonatomic) IBOutlet UILabel *spaceAvailableAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *descriptionLabel;
@property (weak, nonatomic) IBOutlet UILabel *sendOrganizerMessageLabel;
@property (weak, nonatomic) IBOutlet MKMapView *mapView;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSLengthFormatter *lengthFormatter;
@property (strong, nonatomic) PFUser *organizer;

@end

@implementation EventDetailViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    UIFont *openSansBoldFont14 = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    if (self.view.frame.size.width == 375.0) {
        openSansBoldFont14 = [UIFont fontWithName:@"OpenSans-Bold" size:15.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        openSansBoldFont14 = [UIFont fontWithName:@"OpenSans-Bold" size:16.0];
    }
    
    UIFont *openSansBoldFont12 = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
    if (self.view.frame.size.width == 375.0) {
        openSansBoldFont12 = [UIFont fontWithName:@"OpenSans-Bold" size:13.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        openSansBoldFont12 = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    }
    
    UIFont *openSansRegularFont12 = [UIFont fontWithName:@"OpenSans" size:12.0];
    if (self.view.frame.size.width == 375.0) {
        openSansRegularFont12 = [UIFont fontWithName:@"OpenSans" size:13.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        openSansRegularFont12 = [UIFont fontWithName:@"OpenSans" size:14.0];
    }
    
    UIFont *openSansRegularFont10 = [UIFont fontWithName:@"OpenSans" size:10.0];
    if (self.view.frame.size.width == 375.0) {
        openSansRegularFont10 = [UIFont fontWithName:@"OpenSans" size:11.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        openSansRegularFont10 = [UIFont fontWithName:@"OpenSans" size:12.0];
    }
    
    self.eventNameLabel.font = openSansBoldFont14;
    self.attendingAmountLabel.font = openSansBoldFont14;
    
    self.organizerNameLabel.font = openSansBoldFont12;
    self.locationLabel.font = openSansBoldFont12;
    self.spaceAvailableLabel.font = openSansBoldFont12;
    
    self.organizerLabel.font = openSansRegularFont12;
    self.locationNameLabel.font = openSansRegularFont12;
    self.spaceAvailableAmountLabel.font = openSansRegularFont12;
    self.descriptionLabel.font = openSansRegularFont12;
    self.sendOrganizerMessageLabel.font = openSansRegularFont12;
    self.goingLabel.font = openSansRegularFont12;
    
    self.dateLabel.font = openSansRegularFont10;
    self.timeLabel.font = openSansRegularFont10;
    self.distanceLabel.font = openSansRegularFont10;
    
    self.eventPhotoActivityIndicator.color = self.categoryColor;
    PFFile *eventPhoto = self.event[@"photo"];
    [eventPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        self.eventIV.image = [UIImage imageWithData:imageData];
        [self.eventPhotoActivityIndicator stopAnimating];
    }];
    
    self.attendingTabRoundedBackground.layer.cornerRadius = 8.0;
    
    self.eventNameLabel.text = self.event[@"title"];
    
    self.organizer = self.event[@"organizer"];
    self.organizerNameLabel.text = self.organizer[@"nickName"];
    
    self.avatarActivityIndicator.color = self.categoryColor;
    PFFile *organizerAvatar = self.organizer[@"avatar"];
    [organizerAvatar getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        self.avatarIV.image = [UIImage imageWithData:imageData];
        [self.avatarActivityIndicator stopAnimating];
    }];
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    [self.dateFormatter setDateStyle:NSDateFormatterShortStyle];
    self.dateLabel.text = [self.dateFormatter stringFromDate:self.event[@"eventDate"]];
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    [self.timeFormatter setTimeStyle:NSDateFormatterShortStyle];
    self.timeLabel.text = [self.timeFormatter stringFromDate:self.event[@"eventDate"]];
    
    self.locationNameLabel.text = self.event[@"locationName"];
    self.spaceAvailableAmountLabel.text = [self.event[@"guestLimit"] stringValue];
    
    self.descriptionLabel.text = self.event[@"description"];
    
    NSArray *attendants = self.event[@"attendants"];
    self.attendingAmountLabel.text = @([attendants count]).stringValue;
    
    UIImage *statusBarImage;
    switch (self.categoryType) {
        case CategoryTypeFood:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_food"];
            break;
        
        case CategoryTypeDrinks:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_drinks"];
            break;
            
        case CategoryTypeSocial:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_social"];
            break;
            
        case CategoryTypeNightLife:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_nightlife"];
            break;
            
        case CategoryTypeAdventure:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_adventure"];
            break;
            
        case CategoryTypeAttractions:
            statusBarImage = [UIImage imageNamed:@"status_bar_bg_attractions"];
            break;
            
        default:
            break;
    }
    self.statusBarIV.image = statusBarImage;
    
    self.avatarIV.layer.cornerRadius = self.avatarIV.frame.size.width / 2;
    self.avatarIV.layer.borderWidth = 2.0;
    self.avatarIV.layer.borderColor = [self.categoryColor CGColor];
    
    self.attendingTabRoundedBackground.backgroundColor = self.categoryColor;
    self.attendingTabRectangleBackground.backgroundColor = self.categoryColor;
    
    self.sendOrganizerMessageLabel.attributedText = [[NSAttributedString alloc] initWithString:self.sendOrganizerMessageLabel.text attributes:@{NSUnderlineStyleAttributeName : @(NSUnderlineStyleSingle)}];
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    /*
    // 33.941571, -118.408525
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(33.941571, -118.408525);
    EventAnnotation *eventAnnotation = [[EventAnnotation alloc] initWithTitle:self.event[@"title"] subtitle:nil coordinate:coordinate category:@"FOOD"];
     */
    PFGeoPoint *geoPoint = self.event[@"location"];
    CLLocation *location = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    EventAnnotation *eventAnnotation = [[EventAnnotation alloc] initWithTitle:self.event[@"title"] subtitle:nil coordinate:location.coordinate category:self.event[@"category"]];
    [self.mapView addAnnotation:eventAnnotation];
    [self.mapView setCenterCoordinate:location.coordinate];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(location.coordinate, 5000, 5000)];
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = self.eventIV.bounds;
    gradient.colors = @[(id)[[UIColor blackColor] CGColor], (id)[[UIColor clearColor] CGColor]];
    gradient.startPoint = CGPointMake(0.5, 0.75);
    gradient.endPoint = CGPointMake(0.5, 1);
    self.eventIV.layer.mask = gradient;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Actions

- (IBAction)toggleSendOrganizerAMessage:(id)sender
{
    CreateMessageViewController *createMessageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateMessageViewController"];
    createMessageVC.isToOrganizer = YES;
    createMessageVC.organizer = self.organizer;
    
    [self.navigationController pushViewController:createMessageVC animated:YES];
}

- (IBAction)toggleRSVP:(id)sender
{
    [self.event addUniqueObject:[PFUser currentUser] forKey:@"attendants"];
    
    [self presentEmbarkHUDWithMessage:@"Sending RSVP"];
    [self.event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        if (error) {
            [self dismissEmbarkHUDViewController];
            [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
        } else {
            PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
            [eventQuery getObjectInBackgroundWithId:self.event.objectId block:^(PFObject *object,  NSError *error) {
                if (error) {
                    [self dismissEmbarkHUDViewController];
                    [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
                } else {
                    NSArray *attendants = object[@"attendants"];
                    dispatch_async(dispatch_get_main_queue(), ^{
                        self.attendingAmountLabel.text = @([attendants count]).stringValue;
                    });
                    [[PFUser currentUser] addUniqueObject:self.event forKey:@"attendingEvents"];
                    [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                        [self dismissEmbarkHUDViewController];
                        if (error) {
                            [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
                        } else {
                            [self presentEmbarkAlertWithTitle:@"RSVP Sent!" message:@"You have confirmed you are attending this event!" actionText:nil];
                        }
                    }];
                }
            }];
        }
    }];
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations last location: %@", [locations lastObject]);
    self.currentLocation = [locations lastObject];
    
    if (!self.lengthFormatter) {
        self.lengthFormatter = [[NSLengthFormatter alloc] init];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMaximumFractionDigits:1];
        [self.lengthFormatter setNumberFormatter:numberFormatter];
    }
    
    PFGeoPoint *geoPoint = self.event[@"location"];
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    self.distanceLabel.text = [NSString stringWithFormat:@"%@ away", [self.lengthFormatter stringFromMeters:[self.currentLocation distanceFromLocation:eventLocation]]];
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isMemberOfClass:[EventAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"EventAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"EventAnnotation"];
            UIImage *eventAnnotationImage;
            switch (self.categoryType) {
                case CategoryTypeFood:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_food"];
                    break;
                    
                case CategoryTypeDrinks:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_drinks"];
                    break;
                    
                case CategoryTypeSocial:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_social"];
                    break;
                
                case CategoryTypeNightLife:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_nightlife"];
                    break;
                
                case CategoryTypeAdventure:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_adventure"];
                    break;
                
                case CategoryTypeAttractions:
                    eventAnnotationImage = [UIImage imageNamed:@"map_pin_attractions"];
                    break;
                    
                default:
                    break;
            }
            annotationView.image = eventAnnotationImage;
            annotationView.centerOffset = CGPointMake(30.0 / 2, -eventAnnotationImage.size.height / 2 + 12.0 / 2);
            annotationView.calloutOffset = CGPointMake(-30.0 / 2, 0);
            annotationView.canShowCallout = NO;
        }
        annotationView.annotation = annotation;
        return annotationView;
    }
    return nil;
}

@end
