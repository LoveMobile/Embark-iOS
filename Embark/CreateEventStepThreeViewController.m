//
//  CreateEventStepThreeViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "CreateEventStepThreeViewController.h"
#import <Parse/Parse.h>

@interface CreateEventStepThreeViewController ()

@property (weak, nonatomic) IBOutlet UITextView *textView;
@property (weak, nonatomic) IBOutlet UIButton *publishButton;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *textViewContainerToBottomSpaceConstraint;

@end

@implementation CreateEventStepThreeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerKeyboardNotifications];
    
    if (!self.isEditing) {
        [self.textView becomeFirstResponder];
    }
    
    if (self.isEditing) {
        self.textView.text = self.eventInfo[@"description"];
        [self.publishButton setTitle:@"Update This Event" forState:UIControlStateNormal];
        [self.publishButton setTitle:@"Update This Event" forState:UIControlStateHighlighted];
    }
//    [self generateEventsData];
}

- (void)viewDidAppear:(BOOL)animated
{
    if (self.isEditing) {
        [self.textView becomeFirstResponder];
    }
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

#pragma mark - Keyboard Notifications

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    if (self.isEditing) {
        self.textViewContainerToBottomSpaceConstraint.constant = keyboardRect.size.height;
    } else {
        self.textViewContainerToBottomSpaceConstraint.constant = keyboardRect.size.height - 49.0;
    }
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.textViewContainerToBottomSpaceConstraint.constant = 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Button Actions

- (IBAction)toggleDescribeEvent:(id)sender
{
    [self.textView becomeFirstResponder];
}

- (IBAction)togglePublish:(id)sender
{
    if ([self validateInputData]) {
        self.eventInfo[@"description"] = [self.textView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        NSLog(@"event info: %@", self.eventInfo);
        
        if (self.isEditing) {
            [self performUpdateEvent];
        } else {
            PFObject *event = [PFObject objectWithClassName:@"Event"];
            event[@"eventDate"] = self.eventInfo[@"eventDate"];
            event[@"guestLimit"] = self.eventInfo[@"guestLimit"];
            event[@"organizer"] = [PFUser currentUser];
            event[@"title"] = self.eventInfo[@"title"];
            event[@"locationName"] = self.eventInfo[@"locationName"];
            event[@"locationAddress"] = self.eventInfo[@"locationAddress"];
            event[@"category"] = self.eventInfo[@"category"];
            event[@"description"] = self.eventInfo[@"description"];
            UIImage *photo = self.eventInfo[@"photo"];
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation(photo)];
            event[@"photo"] = eventPhoto;
            CLLocation *location = self.eventInfo[@"location"];
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            
            [self presentEmbarkHUDWithMessage:@"Publishing"];
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissEmbarkHUDViewController];
                if (error) {
                    NSLog(@"save event error: %@", [error localizedDescription]);
                    [self presentEmbarkAlertWithTitle:nil message:[error localizedDescription] actionText:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeCategoryGridViewControllerShouldUpdateNotification" object:nil];
                    [self presentEmbarkAlertWithTitle:@"Success!" message:@"Published" actionText:nil];
                }
            }];
        }
    }
}

- (void)performUpdateEvent
{
    PFQuery *eventQuery = [PFQuery queryWithClassName:@"Event"];
    
    [self presentEmbarkHUDWithMessage:@"Updating"];
    [eventQuery getObjectInBackgroundWithId:self.event.objectId block:^(PFObject *event,  NSError *error) {
        if (error) {
            [self dismissEmbarkHUDViewController];
            [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
        } else {
            event[@"eventDate"] = self.eventInfo[@"eventDate"];
            event[@"guestLimit"] = self.eventInfo[@"guestLimit"];
            event[@"organizer"] = [PFUser currentUser];
            event[@"title"] = self.eventInfo[@"title"];
            event[@"locationName"] = self.eventInfo[@"locationName"];
            event[@"locationAddress"] = self.eventInfo[@"locationAddress"];
            event[@"category"] = self.eventInfo[@"category"];
            event[@"description"] = self.eventInfo[@"description"];
            UIImage *photo = self.eventInfo[@"photo"];
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation(photo)];
            event[@"photo"] = eventPhoto;
            CLLocation *location = self.eventInfo[@"location"];
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:location.coordinate.latitude longitude:location.coordinate.longitude];
            
            [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
                [self dismissEmbarkHUDViewController];
                if (error) {
                    NSLog(@"save event error: %@", [error localizedDescription]);
                    [self presentEmbarkAlertWithTitle:nil message:[error localizedDescription] actionText:nil];
                } else {
                    [[NSNotificationCenter defaultCenter] postNotificationName:@"HomeCategoryGridViewControllerShouldUpdateNotification" object:nil];
                    [self presentEmbarkAlertWithTitle:@"Success!" message:@"Updated" actionText:nil];
                }
            }];
        }
    }];
}

#pragma mark - Custom Actions

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Enter Event Description";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

// test
- (void)generateEventsData
{
    for (NSInteger i = 0; i < 6; i++) {
        PFObject *event = [PFObject objectWithClassName:@"Event"];
        event[@"eventDate"] = [NSDate date];
        NSNumber *guestLimit = @((arc4random_uniform(10) + 1) * 5);
        event[@"guestLimit"] = guestLimit;
        event[@"organizer"] = [PFUser currentUser];
        if (i % 6 == 0) {
            event[@"title"] = @"Sky Gathering";
            event[@"locationName"] = @"Santee Alley";
            event[@"locationAddress"] = @"210 E Olympic Blvd #202, Los Angeles, CA 90015, United States";
            event[@"category"] = @"FOOD";
            event[@"description"] = @"Shedd Aquarium is the world's largest aquarium! Join our group for an evening of blues and jazz at the Shedd...";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"food_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:34.037470 longitude:-118.255604];
        }
        if (i % 6 == 1) {
            event[@"title"] = @"Willis Tower";
            event[@"locationName"] = @"Willis Tower";
            event[@"locationAddress"] = @"Willis Tower, 233 S Wacker Dr, Chicago, IL 60606, USA";
            event[@"category"] = @"DRINKS";
            event[@"description"] = @"With two floors and three different atmospheres Sound-Bar guarantees to have something for all tastes. Join us for the end of Release for the 2014 year...";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"drinks_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:41.878876 longitude:-87.635899];
        }
        if (i % 6 == 2) {
            event[@"title"] = @"California Academy of Sciences";
            event[@"locationName"] = @"California Academy of Sciences";
            event[@"locationAddress"] = @"55 Music Concourse Dr, San Francisco, CA 94118, USA";
            event[@"category"] = @"SOCIAL";
            event[@"description"] = @"Come check out the NMMA and Pilsen if you've never been! The museum is free every day but I have yet to visit! They have a Museum Late Night (6-8PM) ...";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"social_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:37.769840 longitude:-122.466090];
        }
        if (i % 6 == 3) {
            event[@"title"] = @"House of Pancakes";
            event[@"locationName"] = @"House of Pancakes";
            event[@"locationAddress"] = @"937 Taraval St, San Francisco, CA 94116, United States";
            event[@"category"] = @"NIGHTLIFE";
            event[@"description"] = @"The theme of this bar crawl is TBOX ZOO, where folks are encouraged to dress as their favorite zoo animal or come in an holiday costume...";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"nightlife_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:37.742892 longitude:-122.476418];
        }
        if (i % 6 == 4) {
            event[@"title"] = @"Outerlands";
            event[@"locationName"] = @"Outerlands";
            event[@"locationAddress"] = @"4001 Judah St, San Francisco, CA 94122, United States";
            event[@"category"] = @"ADVENTURE";
            event[@"description"] = @"A glass-enclosed box that extends four feet out from the 103rd floor (the sky deck), at 1353 feet above the ground ";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"adventure_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:37.760249 longitude:-122.505028];
        }
        if (i % 6 == 5) {
            event[@"title"] = @"Cassava";
            event[@"locationName"] = @"Cassava";
            event[@"locationAddress"] = @"3519 Balboa St, San Francisco, CA 94121, United States";
            event[@"category"] = @"ATTRACTIONS";
            event[@"description"] = @"Shedd Aquarium is the world's largest aquarium! Join our group for an evening of blues and jazz at the Shedd...";
            PFFile *eventPhoto = [PFFile fileWithName:@"event.png" data:UIImagePNGRepresentation([UIImage imageNamed:@"attractions_event_photo"])];
            event[@"photo"] = eventPhoto;
            event[@"location"] = [PFGeoPoint geoPointWithLatitude:37.775567 longitude:-122.496559];
        }
        // Santee Alley
        // 210 E Olympic Blvd #202, Los Angeles, CA 90015, United States
        // 34.037470, -118.255604
        
        // Willis Tower
        // Willis Tower, 233 S Wacker Dr, Chicago, IL 60606, USA
        // 41.878876, -87.635899
        
        // California Academy of Sciences
        // 55 Music Concourse Dr, San Francisco, CA 94118, USA
        // 37.769840, -122.466090
        
        // House of Pancakes
        // 937 Taraval St, San Francisco, CA 94116, United States
        // 37.742892, -122.476418
        
        // Outerlands
        // 4001 Judah St, San Francisco, CA 94122, United States
        // 37.760249, -122.505028
        
        // Cassava
        // 3519 Balboa St, San Francisco, CA 94121, United States
        // 37.775567, -122.496559
        
        [event saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                NSLog(@"save event error: %@", [error localizedDescription]);
            }
        }];
    }
}

#pragma mark - EmbarkAlertViewControllerDelegate

- (void)embarkAlertViewControllerDidDismiss
{
    [super embarkAlertViewControllerDidDismiss];
    
    [self performSegueWithIdentifier:@"unwindToCreateEventViewControllerFromCreateEventStepThreeViewController" sender:nil];
}

@end
