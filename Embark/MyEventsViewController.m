//
//  MyEventsViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "MyEventsViewController.h"
#import "EventListCell.h"
#import "CreateEventViewController.h"

@interface MyEventsViewController ()

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (assign, nonatomic) NSInteger segmentIndex;
@property (strong, nonatomic) NSMutableArray *sortedAttendingEvents;
@property (strong, nonatomic) NSMutableArray *sortedMyCreatedEvents;
@property (strong, nonatomic) NSMutableDictionary *attendingEventPhotoInfo;
@property (strong, nonatomic) NSMutableDictionary *myCreatedEventPhotoInfo;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSLengthFormatter *lengthFormatter;

@end

@implementation MyEventsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // My RSVP's: 0; I've Created: 1
    self.segmentIndex = 0;
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self retrieveMyRSVPs];
}
/*
- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    [self retrieveMyRSVPs];
}
*/
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
#pragma mark - Segmented Control

- (IBAction)toggleSegmentedControl:(UISegmentedControl *)sender
{
    self.segmentIndex = sender.selectedSegmentIndex;
    NSLog(@"segment index: %@", @(self.segmentIndex));
    if (self.segmentIndex == 0) {
        // My RSVP's
        if (!self.sortedAttendingEvents) {
            [self retrieveMyRSVPs];
        } else {
            [self.collectionView reloadData];
        }
    } else {
        // I've Created
        if (!self.sortedMyCreatedEvents) {
            [self retrieveMyCreatedEvents];
        } else {
            [self.collectionView reloadData];
        }
    }
}

#pragma mark - Custom Actions

- (void)retrieveMyRSVPs
{
    [self presentEmbarkHUDWithMessage:@"Loading My RSVP's"];
    
    PFQuery *userQuery = [PFUser query];
    [userQuery selectKeys:@[@"attendingEvents"]];
    [userQuery includeKey:@"attendingEvents"];
    
    [userQuery getObjectInBackgroundWithId:[[PFUser currentUser] objectId] block:^(PFObject *user,  NSError *error) {
        if (error) {
            [self dismissEmbarkHUDViewController];
            [self presentEmbarkAlertWithTitle:nil message:[error localizedDescription] actionText:nil];
        } else {
            NSArray *attendingEvents = user[@"attendingEvents"];
            
            NSMutableArray *foodEvents = [NSMutableArray array];
            NSMutableArray *drinksEvents = [NSMutableArray array];
            NSMutableArray *socialEvents = [NSMutableArray array];
            NSMutableArray *nightlifeEvents = [NSMutableArray array];
            NSMutableArray *adventureEvents = [NSMutableArray array];
            NSMutableArray *attractionsEvents = [NSMutableArray array];
            [attendingEvents enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                if ([event[@"category"] isEqualToString:@"FOOD"]) {
                    [foodEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"DRINKS"]) {
                    [drinksEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"SOCIAL"]) {
                    [socialEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"NIGHTLIFE"]) {
                    [nightlifeEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"ADVENTURE"]) {
                    [adventureEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"ATTRACTIONS"]) {
                    [attractionsEvents addObject:event];
                }
            }];
            self.sortedAttendingEvents = [NSMutableArray array];
            if ([foodEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:foodEvents];
            }
            if ([drinksEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:drinksEvents];
            }
            if ([socialEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:socialEvents];
            }
            if ([nightlifeEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:nightlifeEvents];
            }
            if ([adventureEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:adventureEvents];
            }
            if ([attractionsEvents count] > 0) {
                [self.sortedAttendingEvents addObjectsFromArray:attractionsEvents];
            }
            
            self.myCreatedEventPhotoInfo = [NSMutableDictionary dictionary];
            dispatch_group_t group = dispatch_group_create();
            [self.sortedAttendingEvents enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(group);
                PFFile *photo = event[@"photo"];
                [photo getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *eventPhoto = [UIImage imageWithData:imageData];
                            if (eventPhoto) {
                                self.myCreatedEventPhotoInfo[event.objectId] = eventPhoto;
                            }
                        });
                    }
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                [self dismissEmbarkHUDViewController];
                [self.collectionView reloadData];
            });
        }
    }];
}

- (void)retrieveMyCreatedEvents
{
    [self presentEmbarkHUDWithMessage:@"Loading I've Created"];
    
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    [eventQuery whereKey:@"organizer" equalTo:[PFUser currentUser]];
    
    [eventQuery findObjectsInBackgroundWithBlock:^(NSArray *events, NSError *error) {
        if (error) {
            [self dismissEmbarkHUDViewController];
            [self presentEmbarkAlertWithTitle:nil message:[error localizedDescription] actionText:nil];
        } else {
            NSMutableArray *foodEvents = [NSMutableArray array];
            NSMutableArray *drinksEvents = [NSMutableArray array];
            NSMutableArray *socialEvents = [NSMutableArray array];
            NSMutableArray *nightlifeEvents = [NSMutableArray array];
            NSMutableArray *adventureEvents = [NSMutableArray array];
            NSMutableArray *attractionsEvents = [NSMutableArray array];
            [events enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                if ([event[@"category"] isEqualToString:@"FOOD"]) {
                    [foodEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"DRINKS"]) {
                    [drinksEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"SOCIAL"]) {
                    [socialEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"NIGHTLIFE"]) {
                    [nightlifeEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"ADVENTURE"]) {
                    [adventureEvents addObject:event];
                }
                else if ([event[@"category"] isEqualToString:@"ATTRACTIONS"]) {
                    [attractionsEvents addObject:event];
                }
            }];
            self.sortedMyCreatedEvents = [NSMutableArray array];
            if ([foodEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:foodEvents];
            }
            if ([drinksEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:drinksEvents];
            }
            if ([socialEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:socialEvents];
            }
            if ([nightlifeEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:nightlifeEvents];
            }
            if ([adventureEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:adventureEvents];
            }
            if ([attractionsEvents count] > 0) {
                [self.sortedMyCreatedEvents addObjectsFromArray:attractionsEvents];
            }
            
            self.myCreatedEventPhotoInfo = [NSMutableDictionary dictionary];
            dispatch_group_t group = dispatch_group_create();
            [self.sortedMyCreatedEvents enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
                dispatch_group_enter(group);
                PFFile *photo = event[@"photo"];
                [photo getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                    if (!error) {
                        dispatch_async(dispatch_get_main_queue(), ^{
                            UIImage *eventPhoto = [UIImage imageWithData:imageData];
                            if (eventPhoto) {
                                self.myCreatedEventPhotoInfo[event.objectId] = eventPhoto;
                            }
                        });
                    }
                    dispatch_group_leave(group);
                }];
            }];
            
            dispatch_group_notify(group, dispatch_get_main_queue(), ^{
                [self dismissEmbarkHUDViewController];
                [self.collectionView reloadData];
            });
        }
    }];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    NSInteger numberOfItems;
    if (self.segmentIndex == 0) {
        // My RSVP's
        numberOfItems = [self.sortedAttendingEvents count];
    } else {
        // I've Created
        numberOfItems = [self.sortedMyCreatedEvents count];
    }
    return numberOfItems;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EventListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventListCell" forIndexPath:indexPath];
    
    [self configureEventListCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureEventListCell:(EventListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PFObject *event;
    if (self.segmentIndex == 0) {
        // My RSVP's
        event = self.sortedAttendingEvents[indexPath.item];
    } else {
        // I've Created
        event = self.sortedMyCreatedEvents[indexPath.item];
    }
    
    UIColor *backgroundColor;
    NSString *categoryIconImageName;
    if ([event[@"category"] isEqualToString:@"FOOD"]) {
        backgroundColor = [UIColor colorWithRed:0.827 green:0.184 blue:0.184 alpha:1];
        categoryIconImageName = @"icon_food";
    }
    else if ([event[@"category"] isEqualToString:@"DRINKS"]) {
        backgroundColor = [UIColor colorWithRed:0.333 green:0.541 blue:0.596 alpha:1];
        categoryIconImageName = @"icon_drinks";
    }
    else if ([event[@"category"] isEqualToString:@"SOCIAL"]) {
        backgroundColor = [UIColor colorWithRed:0.867 green:0.643 blue:0.522 alpha:1];
        categoryIconImageName = @"icon_social";
    }
    else if ([event[@"category"] isEqualToString:@"NIGHTLIFE"]) {
        backgroundColor = [UIColor colorWithRed:0.243 green:0.29 blue:0.416 alpha:1];
        categoryIconImageName = @"icon_nightlife";
    }
    else if ([event[@"category"] isEqualToString:@"ADVENTURE"]) {
        backgroundColor = [UIColor colorWithRed:0.318 green:0.443 blue:0.502 alpha:1];
        categoryIconImageName = @"icon_adventure";
    }
    else if ([event[@"category"] isEqualToString:@"ATTRACTIONS"]) {
        backgroundColor = [UIColor colorWithRed:0.486 green:0.329 blue:0.467 alpha:1];
        categoryIconImageName = @"icon_attractions";
    }
    
    for (UIView *view in cell.backgroundViews) {
        view.backgroundColor = backgroundColor;
    }
    
    cell.upperRadiusBackgroundView.layer.cornerRadius = 1.5;
    cell.lowerRadiusBackgroundView.layer.cornerRadius = 5.0;
    
    UIFont *eventTitleFont = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
    if (self.view.frame.size.width == 375.0) {
        eventTitleFont = [UIFont fontWithName:@"OpenSans-Bold" size:13.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        eventTitleFont = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    }
    cell.eventTitleLabel.font = eventTitleFont;
    
    UIFont *descriptionFont = [UIFont fontWithName:@"OpenSansLight-Italic" size:10.0];
    if (self.view.frame.size.width == 375.0) {
        descriptionFont = [UIFont fontWithName:@"OpenSansLight-Italic" size:11.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        descriptionFont = [UIFont fontWithName:@"OpenSansLight-Italic" size:12.0];
    }
    cell.eventDescriptionLabel.font = descriptionFont;
    
    UIFont *distanceFont = [UIFont fontWithName:@"OpenSans" size:10.0];
    if (self.view.frame.size.width == 375.0) {
        distanceFont = [UIFont fontWithName:@"OpenSans" size:11.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        distanceFont = [UIFont fontWithName:@"OpenSans" size:12.0];
    }
    cell.eventDistanceLabel.font = distanceFont;
    
    cell.eventTitleLabel.text = event[@"title"];
    
    NSString *description = event[@"description"];
    int maxDescriptionLength = 140;
    cell.eventDescriptionLabel.text = description.length > maxDescriptionLength ? [NSString stringWithFormat:@"%@...", [description substringToIndex:maxDescriptionLength]] : description;
    
    cell.eventIV.image = self.myCreatedEventPhotoInfo[event.objectId];
    cell.eventCategoryIV.image = [UIImage imageNamed:categoryIconImageName];
    
    PFGeoPoint *geoPoint = event[@"location"];
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    if (self.currentLocation) {
        cell.eventDistanceLabel.text = [NSString stringWithFormat:@"%@ away", [self.lengthFormatter stringFromMeters:[self.currentLocation distanceFromLocation:eventLocation]]];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.segmentIndex == 1) {
        // I've Created
        CreateEventViewController *createEventVC = [self.storyboard instantiateViewControllerWithIdentifier:@"CreateEventViewController"];
        createEventVC.event = self.sortedMyCreatedEvents[indexPath.item];
        createEventVC.isEditing = YES;
        
        UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:createEventVC];
        [self presentViewController:navigationController animated:YES completion:nil];
    }
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ratio = 1.0 / 320 * collectionView.frame.size.width;
    return CGSizeMake(265 * ratio, 107 * ratio);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    return UIEdgeInsetsMake(0, 0, 6.0, 0);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.0;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 8.0;
}

#pragma mark - CLLocationManagerDelegate

- (void)locationManager:(CLLocationManager *)manager didChangeAuthorizationStatus:(CLAuthorizationStatus)status
{
    NSLog(@"didChangeAuthorizationStatus");
}

- (void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray *)locations
{
    NSLog(@"didUpdateLocations last location: %@", [locations lastObject]);
    if (!self.currentLocation) {
        self.currentLocation = [locations lastObject];
        [self.collectionView reloadData];
    }
    //    self.currentLocation = [locations lastObject];
    
    if (!self.lengthFormatter) {
        self.lengthFormatter = [[NSLengthFormatter alloc] init];
        NSNumberFormatter *numberFormatter = [[NSNumberFormatter alloc] init];
        [numberFormatter setMaximumFractionDigits:1];
        [self.lengthFormatter setNumberFormatter:numberFormatter];
    }
}

@end
