//
//  EventListViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EventListViewController.h"
#import "EventListCell.h"
#import "EventDetailViewController.h"

@interface EventListViewController ()

@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) CLLocationManager *locationManager;
@property (strong, nonatomic) CLLocation *currentLocation;
@property (strong, nonatomic) NSLengthFormatter *lengthFormatter;

@end

@implementation EventListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
    [self.locationManager requestWhenInUseAuthorization];
    [self.locationManager startUpdatingLocation];
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

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    if (self.isFromHomeCategoryGrid) {
        self.isFromHomeCategoryGrid = NO;
        /*
        if ([self.eventsByCategory[self.categoryType] count] == 0) {
            
        }
         */
        [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForItem:0 inSection:self.categoryType] atScrollPosition:UICollectionViewScrollPositionTop animated:NO];
    }
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pushEventDetailViewController"]) {
        EventDetailViewController *eventDetailVC = [segue destinationViewController];
        eventDetailVC.event = self.eventsByCategory[self.selectedIndexPath.section][self.selectedIndexPath.item];
        eventDetailVC.categoryType = self.selectedIndexPath.section;
        eventDetailVC.categoryColor = self.categoryColors[self.selectedIndexPath.section];
    }
}

#pragma mark - Button Actions

- (void)toggleBack
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - Custom Actions



#pragma mark - UICollectionViewDataSource

- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return [self.eventsByCategory count];
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.eventsByCategory[section] count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    EventListCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"EventListCell" forIndexPath:indexPath];
    
    [self configureEventListCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureEventListCell:(EventListCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    for (UIView *view in cell.backgroundViews) {
        view.backgroundColor = self.categoryColors[indexPath.section];
    }
    
    cell.upperRadiusBackgroundView.layer.cornerRadius = 1.5;
    cell.lowerRadiusBackgroundView.layer.cornerRadius = 5.0;
    
    PFObject *event = self.eventsByCategory[indexPath.section][indexPath.item];
    
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
    
    cell.eventIV.image = self.eventPhotoInfo[event.objectId];
    cell.eventCategoryIV.image = [UIImage imageNamed:self.iconImageNames[indexPath.section]];
    
    PFGeoPoint *geoPoint = event[@"location"];
    CLLocation *eventLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
    
    if (self.currentLocation) {
        cell.eventDistanceLabel.text = [NSString stringWithFormat:@"%@ away", [self.lengthFormatter stringFromMeters:[self.currentLocation distanceFromLocation:eventLocation]]];
    }
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"pushEventDetailViewController" sender:nil];
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
