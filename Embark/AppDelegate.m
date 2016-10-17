//
//  AppDelegate.m
//  Embark
//
//  Created by Irvin Liao on 4/25/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "AppDelegate.h"
#import <Parse/Parse.h>
#import <FBSDKCoreKit.h>
#import <PFFacebookUtils.h>
#import <Crashlytics/Crashlytics.h>
#import "EmbarkButton.h"
#import "EmbarkTitleLabel.h"
#import "EmbarkTextViewPlaceholderLabel.h"
#import "Message.h"
#import "EmbarkUser.h"
#import "EmbarkSegmentedControl.h"

@interface AppDelegate ()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    NSLog(@"launch options: %@", launchOptions);
    
    [application setStatusBarStyle:UIStatusBarStyleLightContent];
    
    // Appearance
    [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
    [[UINavigationBar appearance] setBackgroundImage:[UIImage imageNamed:@"transparent_bg"] forBarMetrics:UIBarMetricsDefault];
    [[UINavigationBar appearance] setShadowImage:[UIImage imageNamed:@"transparent_shadow"]];
    
    [[UINavigationBar appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:18.0], NSForegroundColorAttributeName : [UIColor whiteColor]}];
    
    [[UITextField appearance] setTextColor:[UIColor colorWithRed:0.471 green:0.471 blue:0.471 alpha:1.0]];
    CGFloat textFieldFontSize = 15.0;
    if (self.window.frame.size.width == 375.0) {
        textFieldFontSize = 17.0;
    }
    else if (self.window.frame.size.width == 414.0) {
        textFieldFontSize = 19.0;
    }
    [[UITextField appearance] setFont:[UIFont fontWithName:@"OpenSans" size:textFieldFontSize]];
    [[UILabel appearanceWhenContainedIn:[UITextField class], nil] setTextColor:[UIColor colorWithRed:0.471 green:0.471 blue:0.471 alpha:1.0]];
    
    [[EmbarkTextViewPlaceholderLabel appearance] setFont:[UIFont fontWithName:@"OpenSans" size:textFieldFontSize]];
    [[EmbarkTextViewPlaceholderLabel appearance] setTextColor:[UIColor colorWithRed:0.471 green:0.471 blue:0.471 alpha:1.0]];
    
    CGFloat embarkButtonFontSize = 15.0;
    if (self.window.frame.size.width == 375.0) {
        embarkButtonFontSize = 17.0;
    }
    else if (self.window.frame.size.width == 414.0) {
        embarkButtonFontSize = 19.0;
    }
    [[EmbarkButton appearance] setTitleFont:[UIFont fontWithName:@"OpenSans" size:embarkButtonFontSize]];
    
    CGFloat embarkTitleLabelFontSize = 19.0;
    if (self.window.frame.size.width == 375.0) {
        embarkTitleLabelFontSize = 21.0;
    }
    else if (self.window.frame.size.width == 414.0) {
        embarkTitleLabelFontSize = 23.0;
    }
    [[EmbarkTitleLabel appearance] setFont:[UIFont fontWithName:@"OpenSans" size:embarkTitleLabelFontSize]];
    
    [[EmbarkSegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"segmented_selected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[EmbarkSegmentedControl appearance] setBackgroundImage:[[UIImage imageNamed:@"segmented_unselected"] resizableImageWithCapInsets:UIEdgeInsetsMake(0, 15, 0, 15)] forState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[EmbarkSegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"segmented_both_unselected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[EmbarkSegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"segmented_left_selected"] forLeftSegmentState:UIControlStateSelected rightSegmentState:UIControlStateNormal barMetrics:UIBarMetricsDefault];
    [[EmbarkSegmentedControl appearance] setDividerImage:[UIImage imageNamed:@"segmented_right_selected"] forLeftSegmentState:UIControlStateNormal rightSegmentState:UIControlStateSelected barMetrics:UIBarMetricsDefault];
    [[EmbarkSegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14.0], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateNormal];
    [[EmbarkSegmentedControl appearance] setTitleTextAttributes:@{NSFontAttributeName : [UIFont fontWithName:@"OpenSans" size:14.0], NSForegroundColorAttributeName : [UIColor whiteColor]} forState:UIControlStateSelected];
    
    // Parse
    [Parse setApplicationId:@"9ISlDhrTawXkJEC12QqiObzLakSGh2fMmj5wlgms" clientKey:@"kzj9sU5hJsKhVdsFt2bglhKEKtnCFK2DJWph79Gr"];
    [PFFacebookUtils initializeFacebookWithApplicationLaunchOptions:launchOptions];
    
    // Push Notification
    [application registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:UIUserNotificationTypeAlert | UIUserNotificationTypeBadge | UIUserNotificationTypeSound categories:nil]];
    [application registerForRemoteNotifications];
    
    // Crashlytics
    [Crashlytics startWithAPIKey:@"b65f15f1bba3374ab34153c21de3337a8542a84e"];
    
    // Login
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"isLogin"]) {
        UIStoryboard *storyboard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
        UITabBarController *tabBarController = [storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
        
        self.window.rootViewController = tabBarController;
    }
    
    return [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
    
    [FBSDKAppEvents activateApp];
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
    // Saves changes in the application's managed object context before the application terminates.
    [self saveContext];
}

#pragma mark - Facebook

- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    return [[FBSDKApplicationDelegate sharedInstance] application:application openURL:url sourceApplication:sourceApplication annotation:annotation];
}

#pragma mark - Push Notifications

- (void)application:(UIApplication *)application didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken
{
    NSLog(@"didRegisterForRemoteNotificationsWithDeviceToken: %@", [[[deviceToken.description stringByReplacingOccurrencesOfString:@"<" withString:@""] stringByReplacingOccurrencesOfString:@">" withString:@""] stringByReplacingOccurrencesOfString:@" " withString:@""]);
    
    [[PFInstallation currentInstallation] setDeviceTokenFromData:deviceToken];
    if ([PFUser currentUser]) {
        [PFInstallation currentInstallation][@"user"] = [PFUser currentUser];
    }
    [[PFInstallation currentInstallation] saveInBackground];
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo
{
    NSLog(@"didReceiveRemoteNotification: %@", userInfo);
    
//    [PFPush handlePush:userInfo];
    
    /*
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationDidReceiveRemoteNotification" object:nil userInfo:userInfo];
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateInactive) {
        
    }
    if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateBackground) {
        
    }
     */
}

- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)userInfo fetchCompletionHandler:(void (^)(UIBackgroundFetchResult))completionHandler
{
    NSLog(@"didReceiveRemoteNotification fetchCompletionHandler: %@", userInfo);
    if (application.applicationState == UIApplicationStateActive) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"UIApplicationDidReceiveRemoteNotification" object:nil userInfo:userInfo];
        completionHandler(UIBackgroundFetchResultNewData);
    } else {
        NSString *fromUserID = userInfo[@"fromUserID"];
        PFQuery *fromUserIDQuery = [PFQuery queryWithClassName:@"Message"];
        [fromUserIDQuery whereKey:@"fromUserID" equalTo:fromUserID];
        
        [fromUserIDQuery findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
            if (error) {
                NSLog(@"Remote Fetch error: %@", [error localizedDescription]);
                completionHandler(UIBackgroundFetchResultFailed);
            } else {
                if ([messages count] > 0) {
                    for (PFObject *message in messages) {
                        // Message
                        NSFetchRequest *messageRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"FetchMessageByMessageID" substitutionVariables:@{@"messageID" : message.objectId}];
                        Message *fetchedMessage = [[self.managedObjectContext executeFetchRequest:messageRequest error:NULL] lastObject];
                        if (!fetchedMessage) {
                            fetchedMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
                            fetchedMessage.messageID = message.objectId;
                            fetchedMessage.content = message[@"content"];
                            fetchedMessage.createdAt = message.createdAt;
                            fetchedMessage.fromUserID = message[@"fromUserID"];
                            fetchedMessage.toUserID = message[@"toUserID"];
//                            fetchedMessage.isRead = message[@"isRead"];
                            fetchedMessage.isRead = @NO;
                            
                            // Embark User
                            NSFetchRequest *embarkUserRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"FetchEmbarkUserByUserID" substitutionVariables:@{@"userID" : message[@"fromUserID"]}];
                            EmbarkUser *fetchedEmbarkUser = [[self.managedObjectContext executeFetchRequest:embarkUserRequest error:NULL] lastObject];
                            if (!fetchedEmbarkUser) {
                                fetchedEmbarkUser = [NSEntityDescription insertNewObjectForEntityForName:@"EmbarkUser" inManagedObjectContext:self.managedObjectContext];
                                fetchedEmbarkUser.userID = message[@"fromUserID"];
                            }
                            fetchedEmbarkUser.nickname = message[@"fromUserNickname"];
                            fetchedEmbarkUser.updatedAt = message.createdAt;
                            [fetchedEmbarkUser addMessagesObject:fetchedMessage];
                        }
                    }
                    NSError *error;
                    if (![self.managedObjectContext save:&error]) {
                        NSLog(@"Remote Fetch save error: %@", [error localizedDescription]);
                    }
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"hasNewData"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    completionHandler(UIBackgroundFetchResultNewData);
                } else {
                    completionHandler(UIBackgroundFetchResultNoData);
                }
            }
        }];
    }
}

#pragma mark - Core Data stack

@synthesize managedObjectContext = _managedObjectContext;
@synthesize managedObjectModel = _managedObjectModel;
@synthesize persistentStoreCoordinator = _persistentStoreCoordinator;

- (NSURL *)applicationDocumentsDirectory {
    // The directory the application uses to store the Core Data store file. This code uses a directory named "com.irvin.Embark" in the application's documents directory.
    return [[[NSFileManager defaultManager] URLsForDirectory:NSDocumentDirectory inDomains:NSUserDomainMask] lastObject];
}

- (NSManagedObjectModel *)managedObjectModel {
    // The managed object model for the application. It is a fatal error for the application not to be able to find and load its model.
    if (_managedObjectModel != nil) {
        return _managedObjectModel;
    }
    NSURL *modelURL = [[NSBundle mainBundle] URLForResource:@"Embark" withExtension:@"momd"];
    _managedObjectModel = [[NSManagedObjectModel alloc] initWithContentsOfURL:modelURL];
    return _managedObjectModel;
}

- (NSPersistentStoreCoordinator *)persistentStoreCoordinator {
    // The persistent store coordinator for the application. This implementation creates and return a coordinator, having added the store for the application to it.
    if (_persistentStoreCoordinator != nil) {
        return _persistentStoreCoordinator;
    }
    
    // Create the coordinator and store
    
    _persistentStoreCoordinator = [[NSPersistentStoreCoordinator alloc] initWithManagedObjectModel:[self managedObjectModel]];
    NSURL *storeURL = [[self applicationDocumentsDirectory] URLByAppendingPathComponent:@"Embark.sqlite"];
    NSError *error = nil;
    NSString *failureReason = @"There was an error creating or loading the application's saved data.";
    if (![_persistentStoreCoordinator addPersistentStoreWithType:NSSQLiteStoreType configuration:nil URL:storeURL options:nil error:&error]) {
        // Report any error we got.
        NSMutableDictionary *dict = [NSMutableDictionary dictionary];
        dict[NSLocalizedDescriptionKey] = @"Failed to initialize the application's saved data";
        dict[NSLocalizedFailureReasonErrorKey] = failureReason;
        dict[NSUnderlyingErrorKey] = error;
        error = [NSError errorWithDomain:@"YOUR_ERROR_DOMAIN" code:9999 userInfo:dict];
        // Replace this with code to handle the error appropriately.
        // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
        NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
        abort();
    }
    
    return _persistentStoreCoordinator;
}


- (NSManagedObjectContext *)managedObjectContext {
    // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.)
    if (_managedObjectContext != nil) {
        return _managedObjectContext;
    }
    
    NSPersistentStoreCoordinator *coordinator = [self persistentStoreCoordinator];
    if (!coordinator) {
        return nil;
    }
    _managedObjectContext = [[NSManagedObjectContext alloc] init];
    [_managedObjectContext setPersistentStoreCoordinator:coordinator];
    return _managedObjectContext;
}

#pragma mark - Core Data Saving support

- (void)saveContext {
    NSManagedObjectContext *managedObjectContext = self.managedObjectContext;
    if (managedObjectContext != nil) {
        NSError *error = nil;
        if ([managedObjectContext hasChanges] && ![managedObjectContext save:&error]) {
            // Replace this implementation with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            NSLog(@"Unresolved error %@, %@", error, [error userInfo]);
            abort();
        }
    }
}

@end
