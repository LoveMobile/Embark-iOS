//
//  HomeListViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "HomeCategoryGridViewController.h"
#import "HomeCategoryGridCell.h"
#import "EventListViewController.h"
#import "CategoryTransitionAnimator.h"
#import "SettingsViewController.h"
#import "SettingsItemViewController.h"
#import "SignUpViewController.h"
#import "AppDelegate.h"

/*
#import "MyAccountViewController.h"
#import "MyEventsViewController.h"
#import "MySettingsViewController.h"
#import "PrivacyPolicyViewController.h"
 */

@interface HomeCategoryGridViewController () <SettingsViewControllerDelegate, SettingsItemViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *categoryInfos;
@property (strong, nonatomic) NSIndexPath *selectedIndexPath;
@property (strong, nonatomic) NSArray *eventsByCategory;
@property (strong, nonatomic) NSMutableDictionary *eventPhotoInfo;
@property (strong, nonatomic) SettingsViewController *settingsViewController;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@end

@implementation HomeCategoryGridViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab_home"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab_home_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.categoryInfos = @[@{@"color" : [UIColor colorWithRed:0.827 green:0.184 blue:0.184 alpha:1],
                             @"imageName" : @"home_food",
                             @"iconImageName" : @"icon_food",
                             @"name" : @"FOOD",
                             @"description" : @"Gather for good eats"},
                           @{@"color" : [UIColor colorWithRed:0.333 green:0.541 blue:0.596 alpha:1],
                             @"imageName" : @"home_drinks",
                             @"iconImageName" : @"icon_drinks",
                             @"name" : @"DRINKS",
                             @"description" : @"Wet your whistle"},
                           @{@"color" : [UIColor colorWithRed:0.867 green:0.643 blue:0.522 alpha:1],
                             @"imageName" : @"home_social",
                             @"iconImageName" : @"icon_social",
                             @"name" : @"SOCIAL",
                             @"description" : @"Everybody get together"},
                           @{@"color" : [UIColor colorWithRed:0.243 green:0.29 blue:0.416 alpha:1],
                             @"imageName" : @"home_nightlife",
                             @"iconImageName" : @"icon_nightlife",
                             @"name" : @"NIGHTLIFE",
                             @"description" : @"Life after dark"},
                           @{@"color" : [UIColor colorWithRed:0.318 green:0.443 blue:0.502 alpha:1],
                             @"imageName" : @"home_adventure",
                             @"iconImageName" : @"icon_adventure",
                             @"name" : @"ADVENTURE",
                             @"description" : @"Say hello to new adventures"},
                           @{@"color" : [UIColor colorWithRed:0.486 green:0.329 blue:0.467 alpha:1],
                             @"imageName" : @"home_attractions",
                             @"iconImageName" : @"icon_attractions",
                             @"name" : @"ATTRACTIONS",
                             @"description" : @"See what you've come for"}];
    
    [self registerNotifications];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.navigationController.delegate = self;
    
    if (!self.eventsByCategory) {
        [self retrieveAllEvents];
    }
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    self.navigationController.delegate = nil;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pushEventListViewController"]) {
        EventListViewController *eventListVC = [segue destinationViewController];
        eventListVC.eventsByCategory = self.eventsByCategory;
        eventListVC.eventPhotoInfo = self.eventPhotoInfo;
        eventListVC.iconImageNames = [self.categoryInfos valueForKeyPath:@"iconImageName"];
        eventListVC.categoryType = self.selectedIndexPath.item;
        eventListVC.categoryColors = [self.categoryInfos valueForKey:@"color"];
        eventListVC.isFromHomeCategoryGrid = YES;
    }
}

#pragma mark - Notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(updateAllEvents:) name:@"HomeCategoryGridViewControllerShouldUpdateNotification" object:nil];
}

- (void)updateAllEvents:(NSNotification *)notification
{
    [self retrieveAllEvents];
}

#pragma mark - Button Actions

- (IBAction)toggleSettings:(id)sender
{
    self.settingsViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"SettingsViewController"];
    self.settingsViewController.delegate = self;
    
    [self.tabBarController addChildViewController:self.settingsViewController];
    [self.tabBarController.view addSubview:self.settingsViewController.view];
    [self.settingsViewController didMoveToParentViewController:self.tabBarController];
}

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
            NSMutableArray *foodEvents = [NSMutableArray array];
            NSMutableArray *drinksEvents = [NSMutableArray array];
            NSMutableArray *socialEvents = [NSMutableArray array];
            NSMutableArray *nightlifeEvents = [NSMutableArray array];
            NSMutableArray *adventureEvents = [NSMutableArray array];
            NSMutableArray *attractionsEvents = [NSMutableArray array];
            NSMutableDictionary *eventFileInfo = [NSMutableDictionary dictionary];
            [objects enumerateObjectsUsingBlock:^(PFObject *event, NSUInteger idx, BOOL *stop) {
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
                eventFileInfo[event.objectId] = event[@"photo"];
            }];
            self.eventsByCategory = @[foodEvents, drinksEvents, socialEvents, nightlifeEvents, adventureEvents, attractionsEvents];
            
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
            });
        }
    }];
}

- (void)performLogOut
{
    NSFetchRequest *messageFetchRequest = [[NSFetchRequest alloc] init];
    [messageFetchRequest setEntity:[NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext]];
    [messageFetchRequest setIncludesPropertyValues:NO];
    
    NSError *fetchMessageError = nil;
    NSArray *fetchedMessages = [self.managedObjectContext executeFetchRequest:messageFetchRequest error:&fetchMessageError];
    if (fetchMessageError) {
        NSLog(@"fetch messages error: %@", [fetchMessageError localizedDescription]);
    }
    for (NSManagedObject *message in fetchedMessages) {
        [self.managedObjectContext deleteObject:message];
    }
    
    NSFetchRequest *embarkUserFetchRequest = [[NSFetchRequest alloc] init];
    [embarkUserFetchRequest setEntity:[NSEntityDescription entityForName:@"EmbarkUser" inManagedObjectContext:self.managedObjectContext]];
    [embarkUserFetchRequest setIncludesPropertyValues:NO];
    
    NSError *fetchEmbarkUserError = nil;
    NSArray *fetchedEmbarkUsers = [self.managedObjectContext executeFetchRequest:embarkUserFetchRequest error:&fetchEmbarkUserError];
    if (fetchEmbarkUserError) {
        NSLog(@"fetch embark user error: %@", [fetchEmbarkUserError localizedDescription]);
    }
    for (NSManagedObject *embarkUser in fetchedEmbarkUsers) {
        [self.managedObjectContext deleteObject:embarkUser];
    }
    
    NSError *error;
    if (![self.managedObjectContext save:&error]) {
        NSLog(@"error after delete all managed objects: %@", [error localizedDescription]);
    }
    
    [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"isLogin"];
    [[NSUserDefaults standardUserDefaults] synchronize];
    
    UINavigationController *navigationController = [self.storyboard instantiateInitialViewController];
    SignUpViewController *signUpVC = (SignUpViewController *)[navigationController topViewController];
    signUpVC.isLogOut = YES;
    signUpVC.view.alpha = 0;
    [[[[UIApplication sharedApplication] delegate] window] setRootViewController:navigationController];
}

#pragma mark - UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return [self.categoryInfos count];
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    HomeCategoryGridCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"HomeCategoryGridCell" forIndexPath:indexPath];
    
    [self configureHomeCategoryGridCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureHomeCategoryGridCell:(HomeCategoryGridCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    NSDictionary *categoryInfo = self.categoryInfos[indexPath.item];
    for (UIView *view in cell.backgroundViews) {
        view.backgroundColor = categoryInfo[@"color"];
    }
    cell.upperRadiusBackgroundView.layer.cornerRadius = 1.5;
    cell.lowerRadiusBackgroundView.layer.cornerRadius = 5.0;
    
    cell.categoryIV.image = [UIImage imageNamed:categoryInfo[@"imageName"]];
    cell.categoryIV.layer.cornerRadius = 1.5;
    cell.categoryIconIV.image = [UIImage imageNamed:categoryInfo[@"iconImageName"]];
    
    cell.categoryNameLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
    cell.categoryNameLabel.text = categoryInfo[@"name"];
    
    cell.categoryDescriptionLabel.font = [UIFont fontWithName:@"OpenSansLight-Italic" size:10.0];
    cell.categoryDescriptionLabel.text = categoryInfo[@"description"];
}

#pragma mark - UICollectionViewDelegate

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedIndexPath = indexPath;
    
    [self performSegueWithIdentifier:@"pushEventListViewController" sender:nil];
}

#pragma mark - UICollectionViewDelegateFlowLayout

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    CGFloat ratio = 1.0 / 320 * collectionView.frame.size.width;
    return CGSizeMake(130 * ratio, 129 * ratio);
}

- (UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    CGFloat ratio = 1.0 / 320 * collectionView.frame.size.width;
    return UIEdgeInsetsMake(16 * ratio, 24 * ratio, 16 * ratio, 24 * ratio);
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0 / 320 * collectionView.frame.size.width;
}

- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout minimumLineSpacingForSectionAtIndex:(NSInteger)section
{
    return 10.0 / 320 * collectionView.frame.size.width;
}

#pragma mark - UINavigationControllerDelegate

- (id<UIViewControllerAnimatedTransitioning>)navigationController:(UINavigationController *)navigationController animationControllerForOperation:(UINavigationControllerOperation)operation fromViewController:(UIViewController *)fromVC toViewController:(UIViewController *)toVC
{
    if (operation == UINavigationControllerOperationPush) {
        CategoryTransitionAnimator *animator = [[CategoryTransitionAnimator alloc] init];
        animator.isPresenting = YES;
        
        return animator;
    }
    return nil;
}

#pragma mark - SettingsViewControllerDelegate

- (void)settingsViewControllerDidTapIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == 4) {
        // Log Out
        [self.settingsViewController willMoveToParentViewController:nil];
        [self.settingsViewController.view removeFromSuperview];
        [self.settingsViewController removeFromParentViewController];
        
        [self performLogOut];
    } else {
        SettingsItemViewController *settingsItemVC;
        if (indexPath.row == 0) {
            // My Account
            settingsItemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyAccountViewController"];
        }
        else if (indexPath.row == 1) {
            // My Events
            settingsItemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MyEventsViewController"];
        }
        else if (indexPath.row == 2) {
            // My Settings
            settingsItemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MySettingsViewController"];
        }
        else if (indexPath.row == 3) {
            // Privacy Policy
            settingsItemVC = [self.storyboard instantiateViewControllerWithIdentifier:@"PrivacyPolicyViewController"];
        }
        settingsItemVC.delegate = self;
        
        self.settingsViewController.view.hidden = YES;
        
        [self.tabBarController addChildViewController:settingsItemVC];
        [self.tabBarController.view addSubview:settingsItemVC.view];
        [settingsItemVC didMoveToParentViewController:self.tabBarController];
        
        [settingsItemVC viewDidAppear:YES];
    }
}

#pragma mark - SettingsItemViewControllerDelegate

- (void)settingsItemViewControllerDidClose
{
    self.settingsViewController.view.hidden = NO;
}

@end
