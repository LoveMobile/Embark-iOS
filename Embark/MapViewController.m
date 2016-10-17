//
//  MapViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "MapViewController.h"
#import "EventAnnotation.h"
#import "EmbarkLeftCalloutView.h"
#import "EventDetailViewController.h"

@interface MapViewController ()

@property (weak, nonatomic) IBOutlet MKMapView *mapView;
@property (strong, nonatomic) NSMutableDictionary *eventPhotoInfo;
@property (strong, nonatomic) NSMutableArray *eventAnnotations;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) NSArray *categoryColors;

@end

@implementation MapViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab_map"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab_map_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
    
    // 37.771469, -122.468680
    CLLocationCoordinate2D coordinate = CLLocationCoordinate2DMake(37.771469, -122.468680);
    [self.mapView setCenterCoordinate:coordinate];
    [self.mapView setRegion:MKCoordinateRegionMakeWithDistance(coordinate, 5000, 5000)];
    
    self.categoryColors = @[[UIColor colorWithRed:0.827 green:0.184 blue:0.184 alpha:1], [UIColor colorWithRed:0.333 green:0.541 blue:0.596 alpha:1], [UIColor colorWithRed:0.867 green:0.643 blue:0.522 alpha:1], [UIColor colorWithRed:0.243 green:0.29 blue:0.416 alpha:1], [UIColor colorWithRed:0.318 green:0.443 blue:0.502 alpha:1], [UIColor colorWithRed:0.486 green:0.329 blue:0.467 alpha:1]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.eventAnnotations) {
        [self retrieveAllEvents];
    }
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    
    [self.locationManager stopUpdatingLocation];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Custom Actions

- (void)retrieveAllEvents
{
    [self presentEmbarkHUDWithMessage:@"Loading Events"];
    
    PFQuery *query = [PFQuery queryWithClassName:@"Event"];
    [query includeKey:@"organizer"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
        if (error) {
            [self dismissEmbarkHUDViewController];
            [self presentEmbarkAlertWithTitle:nil message:[error localizedDescription] actionText:nil];
        } else {
            NSMutableDictionary *eventFileInfo = [NSMutableDictionary dictionary];
            self.eventAnnotations = [NSMutableArray array];
            [objects enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                eventFileInfo[event.objectId] = event[@"photo"];
                
                PFGeoPoint *geoPoint = event[@"location"];
                // test
                if (geoPoint) {
                    [self.eventAnnotations addObject:[[EventAnnotation alloc] initWithTitle:event[@"title"] subtitle:nil coordinate:CLLocationCoordinate2DMake(geoPoint.latitude, geoPoint.longitude) event:event]];
                }
            }];
            
            self.eventPhotoInfo = [NSMutableDictionary dictionary];
            dispatch_group_t group = dispatch_group_create();
            [eventFileInfo enumerateKeysAndObjectsUsingBlock:^(id key, PFFile *photo, BOOL *stop) {
                dispatch_group_enter(group);
                [photo getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *eventPhoto = [UIImage imageWithData:imageData];
                            if (eventPhoto) {
                                self.eventPhotoInfo[key] = eventPhoto;
                            }
                        });
                    }
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                [self dismissEmbarkHUDViewController];
                
                [self.mapView addAnnotations:self.eventAnnotations];
            });
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
}

#pragma mark - MKMapViewDelegate

- (MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation
{
    if ([annotation isMemberOfClass:[EventAnnotation class]]) {
        MKAnnotationView *annotationView = [mapView dequeueReusableAnnotationViewWithIdentifier:@"EventAnnotation"];
        if (!annotationView) {
            annotationView = [[MKAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"EventAnnotation"];
            EmbarkLeftCalloutView *leftCallout = [[EmbarkLeftCalloutView alloc] initWithFrame:CGRectMake(0, 0, 45, 45) icon:[UIImage imageNamed:@"callout_icon_attractions"]];
            annotationView.leftCalloutAccessoryView = leftCallout;
            annotationView.rightCalloutAccessoryView = [UIButton buttonWithType:UIButtonTypeDetailDisclosure];
        }
        UIImage *eventAnnotationImage;
        UIColor *backgroundColor;
        UIImage *calloutIcon;
        if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"FOOD"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_food"];
            backgroundColor = self.categoryColors[0];
            calloutIcon = [UIImage imageNamed:@"icon_food"];
        }
        else if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"DRINKS"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_drinks"];
            backgroundColor = self.categoryColors[1];
            calloutIcon = [UIImage imageNamed:@"icon_drinks"];
        }
        else if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"SOCIAL"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_social"];
            backgroundColor = self.categoryColors[2];
            calloutIcon = [UIImage imageNamed:@"icon_social"];
        }
        else if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"NIGHTLIFE"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_nightlife"];
            backgroundColor = self.categoryColors[3];
            calloutIcon = [UIImage imageNamed:@"icon_nightlife"];
        }
        else if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"ADVENTURE"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_adventure"];
            backgroundColor = self.categoryColors[4];
            calloutIcon = [UIImage imageNamed:@"icon_adventure"];
        }
        else if ([[(EventAnnotation *)annotation event][@"category"] isEqualToString:@"ATTRACTIONS"]) {
            eventAnnotationImage = [UIImage imageNamed:@"map_pin_attractions"];
            backgroundColor = self.categoryColors[5];
            calloutIcon = [UIImage imageNamed:@"icon_attractions"];
        }
        annotationView.image = eventAnnotationImage;
        annotationView.leftCalloutAccessoryView.backgroundColor = backgroundColor;
        [[(EmbarkLeftCalloutView *)annotationView.leftCalloutAccessoryView iconIV] setImage:calloutIcon];
        
        annotationView.annotation = annotation;
        annotationView.centerOffset = CGPointMake(30.0 / 2, -eventAnnotationImage.size.height / 2 + 12.0 / 2);
        annotationView.calloutOffset = CGPointMake(-30.0 / 2, 0);
        annotationView.canShowCallout = YES;
        
        return annotationView;
    }
    return nil;
}

- (void)mapView:(MKMapView *)mapView didSelectAnnotationView:(MKAnnotationView *)view
{
    
}

- (void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control
{
    EventAnnotation *annotation = view.annotation;
    
    PFObject *event = annotation.event;
    CategoryType categoryType;
    UIColor *categoryColor;
    if ([event[@"category"] isEqualToString:@"FOOD"]) {
        categoryType = CategoryTypeFood;
        categoryColor = self.categoryColors[0];
    }
    else if ([event[@"category"] isEqualToString:@"DRINKS"]) {
        categoryType = CategoryTypeDrinks;
        categoryColor = self.categoryColors[1];
    }
    else if ([event[@"category"] isEqualToString:@"SOCIAL"]) {
        categoryType = CategoryTypeSocial;
        categoryColor = self.categoryColors[2];
    }
    else if ([event[@"category"] isEqualToString:@"NIGHTLIFE"]) {
        categoryType = CategoryTypeNightLife;
        categoryColor = self.categoryColors[3];
    }
    else if ([event[@"category"] isEqualToString:@"ADVENTURE"]) {
        categoryType = CategoryTypeAdventure;
        categoryColor = self.categoryColors[4];
    }
    else if ([event[@"category"] isEqualToString:@"ATTRACTIONS"]) {
        categoryType = CategoryTypeAttractions;
        categoryColor = self.categoryColors[5];
    }
    
    EventDetailViewController *eventDetailVC = [self.storyboard instantiateViewControllerWithIdentifier:@"EventDetailViewController"];
    eventDetailVC.event = event;
    eventDetailVC.categoryType = categoryType;
    eventDetailVC.categoryColor = categoryColor;
    eventDetailVC.hidesBottomBarWhenPushed = YES;
    
    [self.navigationController pushViewController:eventDetailVC animated:YES];
}

@end
