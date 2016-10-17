//
//  MessageViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "InboxViewController.h"
#import "InboxCell.h"
#import "AppDelegate.h"
#import "Message.h"
#import "EmbarkUser.h"
#import "MessageViewController.h"

@interface InboxViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UILabel *noEntityLabel;

@property (strong, nonatomic) UIFont *largeRegularFont;
@property (strong, nonatomic) UIFont *largeBoldFont;
@property (strong, nonatomic) UIFont *smallRegularFont;
@property (strong, nonatomic) UIFont *smallBoldFont;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;
@property (strong, nonatomic) NSManagedObjectModel *managedObjectModel;

@property (strong, nonatomic) NSArray *retrievedMessages;
@property (strong, nonatomic) NSArray *embarkUsers;
@property (strong, nonatomic) PFQuery *fromUserMessageQuery;
@property (strong, nonatomic) PFQuery *toUserMessageQuery;
@property (strong, nonatomic) NSMutableDictionary *avatarInfo;
@property (strong, nonatomic) NSMutableDictionary *userInfo;

@end

@implementation InboxViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab_message"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab_message_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.largeRegularFont = [UIFont fontWithName:@"OpenSans" size:14.0];
    self.largeBoldFont = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    self.smallRegularFont = [UIFont fontWithName:@"OpenSans" size:12.0];
    self.smallBoldFont = [UIFont fontWithName:@"OpenSans-Bold" size:12.0];
    
    self.noEntityLabel.font = [UIFont fontWithName:@"OpenSans" size:16.0];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    self.managedObjectModel = appDelegate.managedObjectModel;
    
    [self registerNotifications];
    
    self.avatarInfo = [NSMutableDictionary dictionary];
    self.userInfo = [NSMutableDictionary dictionary];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (!self.retrievedMessages) {
        [self retrieveAllMessages];
    }
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasNewData"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasNewData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self fetchEmbarkUsers];
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

#pragma mark - Notifications

- (void)registerNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveFromUserIDMessages:) name:@"UIApplicationDidReceiveRemoteNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(retrieveMessagesSentToUserID:) name:@"MessagesSentByMeDidSucceedNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(reloadToUpdateReadState:) name:@"InboxViewControllerShouldUpdateReadStateNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(applicationDidBecomeActive:) name:UIApplicationDidBecomeActiveNotification object:nil];
}

- (void)retrieveFromUserIDMessages:(NSNotification *)notification
{
    NSString *fromUserID = [notification userInfo][@"fromUserID"];
    if (self.fromUserMessageQuery) {
        [self.fromUserMessageQuery cancel];
    }
    self.fromUserMessageQuery = [PFQuery queryWithClassName:@"Message"];
    [self.fromUserMessageQuery whereKey:@"fromUserID" equalTo:fromUserID];
    [self.fromUserMessageQuery whereKey:@"toUserID" equalTo:[[PFUser currentUser] objectId]];
    
    [self.fromUserMessageQuery findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        if (error) {
            NSLog(@"Remote Fetch error: %@", [error localizedDescription]);
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
//                        fetchedMessage.isRead = message[@"isRead"];
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
            }
            [self fetchEmbarkUsers];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InboxViewControllerDidRetrieveMessageFromUserIDNotification" object:nil userInfo:@{@"fromUserID" : fromUserID}];
        }
    }];
}

- (void)retrieveMessagesSentToUserID:(NSNotification *)notification
{
    NSString *toUserID = [notification userInfo][@"toUserID"];
    if (self.toUserMessageQuery) {
        [self.toUserMessageQuery cancel];
    }
    self.toUserMessageQuery = [PFQuery queryWithClassName:@"Message"];
    [self.toUserMessageQuery whereKey:@"toUserID" equalTo:toUserID];
    [self.toUserMessageQuery whereKey:@"fromUserID" equalTo:[[PFUser currentUser] objectId]];
    
    [self.toUserMessageQuery findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        if (error) {
            NSLog(@"Remote Fetch error: %@", [error localizedDescription]);
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
//                        fetchedMessage.isRead = message[@"isRead"];
                        fetchedMessage.isRead = @NO;
                        
                        // Embark User
                        NSFetchRequest *embarkUserRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"FetchEmbarkUserByUserID" substitutionVariables:@{@"userID" : message[@"toUserID"]}];
                        EmbarkUser *fetchedEmbarkUser = [[self.managedObjectContext executeFetchRequest:embarkUserRequest error:NULL] lastObject];
                        if (!fetchedEmbarkUser) {
                            fetchedEmbarkUser = [NSEntityDescription insertNewObjectForEntityForName:@"EmbarkUser" inManagedObjectContext:self.managedObjectContext];
                            fetchedEmbarkUser.userID = message[@"toUserID"];
                        }
                        fetchedEmbarkUser.nickname = message[@"toUserNickname"];
                        fetchedEmbarkUser.updatedAt = message.createdAt;
                        [fetchedEmbarkUser addMessagesObject:fetchedMessage];
                    }
                }
                NSError *error;
                if (![self.managedObjectContext save:&error]) {
                    NSLog(@"Remote Fetch save error: %@", [error localizedDescription]);
                }
            }
            [self fetchEmbarkUsers];
            [[NSNotificationCenter defaultCenter] postNotificationName:@"InboxViewControllerDidRetrieveMessageToUserIDNotification" object:nil userInfo:@{@"toUserID" : toUserID}];
        }
    }];
}

- (void)reloadToUpdateReadState:(NSNotification *)notification
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmbarkUser" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    self.embarkUsers = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"fetch embarkUser error: %@", [error localizedDescription]);
    }
    [self.tableView reloadData];
}

- (void)applicationDidBecomeActive:(NSNotification *)notification
{
    if ([[NSUserDefaults standardUserDefaults] boolForKey:@"hasNewData"]) {
        [[NSUserDefaults standardUserDefaults] setBool:NO forKey:@"hasNewData"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
        [self fetchEmbarkUsers];
    }
}

#pragma mark - Custom Actions

- (void)retrieveAllMessages
{
    [self presentEmbarkHUDWithMessage:@"Loading Messages"];
    
    PFQuery *toUserIDQuery = [PFQuery queryWithClassName:@"Message"];
    [toUserIDQuery whereKey:@"toUserID" equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *fromUserIDQuery = [PFQuery queryWithClassName:@"Message"];
    [fromUserIDQuery whereKey:@"fromUserID" equalTo:[[PFUser currentUser] objectId]];
    
    PFQuery *query = [PFQuery orQueryWithSubqueries:@[toUserIDQuery, fromUserIDQuery]];
    [query orderByAscending:@"createdAt"];
    
    [query findObjectsInBackgroundWithBlock:^(NSArray *messages, NSError *error) {
        self.retrievedMessages = messages;
        if ([messages count] > 0) {
            for (PFObject *message in messages) {
                NSFetchRequest *messageRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"FetchMessageByMessageID" substitutionVariables:@{@"messageID" : message.objectId}];
                Message *fetchedMessage = [[self.managedObjectContext executeFetchRequest:messageRequest error:NULL] lastObject];
                if (!fetchedMessage) {
                    fetchedMessage = [NSEntityDescription insertNewObjectForEntityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
                    fetchedMessage.messageID = message.objectId;
                    fetchedMessage.content = message[@"content"];
                    fetchedMessage.createdAt = message.createdAt;
                    fetchedMessage.fromUserID = message[@"fromUserID"];
                    fetchedMessage.toUserID = message[@"toUserID"];
//                    fetchedMessage.isRead = message[@"isRead"];
                    fetchedMessage.isRead = @NO;
                    
                    // Embark User
                    NSString *userID = [message[@"fromUserID"] isEqualToString:[[PFUser currentUser] objectId]] ? message[@"toUserID"] : message[@"fromUserID"];
                    
                    NSFetchRequest *embarkUserRequest = [self.managedObjectModel fetchRequestFromTemplateWithName:@"FetchEmbarkUserByUserID" substitutionVariables:@{@"userID" : userID}];
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
                NSLog(@"save retrieved messages error: %@", [error localizedDescription]);
            }
        }
        [self fetchEmbarkUsers];
        [self dismissEmbarkHUDViewController];
    }];
}

- (void)fetchEmbarkUsers
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"EmbarkUser" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"updatedAt" ascending:NO];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    self.embarkUsers = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"fetch embarkUser error: %@", [error localizedDescription]);
    }
    self.avatarInfo = [NSMutableDictionary dictionary];
    self.userInfo = [NSMutableDictionary dictionary];
    [self.tableView reloadData];
}

- (NSString *)formatDuration:(NSTimeInterval)duration
{
    NSInteger minute = duration / 60;
    NSInteger hour = duration / (60 * 60);
    NSInteger day = duration / (24 * 60 * 60);
    NSInteger week = duration / (7 * 24 * 60 * 60);
    NSInteger month = duration / (30 * 24 * 60 * 60);
    
    NSString *durationString = @"now";
    if (month > 0) {
        durationString = month > 1 ? [NSString stringWithFormat:@"%@ months ago", @(month)] : [NSString stringWithFormat:@"%@ month ago", @(month)];
    }
    else if (week > 0) {
        durationString = week > 1 ? [NSString stringWithFormat:@"%@ weeks ago", @(week)] : [NSString stringWithFormat:@"%@ week ago", @(week)];
    }
    else if (day > 0) {
        durationString = day > 1 ? [NSString stringWithFormat:@"%@ days ago", @(day)] : [NSString stringWithFormat:@"%@ day ago", @(day)];
    }
    else if (hour > 0) {
        durationString = hour > 1 ? [NSString stringWithFormat:@"%@ hours ago", @(hour)] : [NSString stringWithFormat:@"%@ hour ago", @(hour)];
    }
    else if (minute > 0) {
        durationString = minute > 1 ? [NSString stringWithFormat:@"%@ mins ago", @(minute)] : [NSString stringWithFormat:@"%@ min ago", @(minute)];
    }
    
    return durationString;
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    if (self.embarkUsers) {
        self.noEntityLabel.hidden = [self.embarkUsers count] > 0 ? YES : NO;
    }
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.embarkUsers count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InboxCell *cell = [tableView dequeueReusableCellWithIdentifier:@"InboxCell"];
    cell.nameLabel.font = self.largeBoldFont;
    cell.messageLabel.font = self.largeRegularFont;
    cell.durationLabel.font = self.smallRegularFont;
    cell.avatarIV.image = nil;
    
    [self configureInboxCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureInboxCell:(InboxCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    EmbarkUser *user = self.embarkUsers[indexPath.row];
    
    if (!self.avatarInfo[indexPath]) {
        [cell.avatarActivityIndicator startAnimating];
        PFQuery *userQuery = [PFUser query];
        [userQuery whereKey:@"objectId" equalTo:user.userID];
        [userQuery findObjectsInBackgroundWithBlock:^(NSArray *users, NSError *error) {
            PFUser *user = [users firstObject];
            if (user) {
                self.userInfo[indexPath] = user;
            }
            PFFile *avatarFile = user[@"avatar"];
            [avatarFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                UIImage *avatar = [UIImage imageWithData:imageData];
                if (avatar) {
                    cell.avatarIV.image = avatar;
                    self.avatarInfo[indexPath] = avatar;
                    [cell.avatarActivityIndicator stopAnimating];
                }
            }];
        }];
    } else {
        cell.avatarIV.image = self.avatarInfo[indexPath];
    }
    cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2;
    
    cell.nameLabel.text = user.nickname;
    
    Message *message = [[user.messages.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]] lastObject];
    cell.messageLabel.font = message.isRead.boolValue ? self.largeRegularFont : self.largeBoldFont;
    cell.messageLabel.text = message.content;
    
    cell.unreadIV.hidden = message.isRead.boolValue ? YES : NO;
    
    cell.durationLabel.font = message.isRead.boolValue ? self.smallRegularFont : self.smallBoldFont;
    NSTimeInterval duration = [message.createdAt timeIntervalSinceNow] * -1;
    cell.durationLabel.text = [self formatDuration:duration];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0 * self.view.frame.size.height / 568.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    EmbarkUser *user = self.embarkUsers[indexPath.row];
    
    MessageViewController *messageVC = [self.storyboard instantiateViewControllerWithIdentifier:@"MessageViewController"];
    messageVC.fromUser = self.userInfo[indexPath];
    messageVC.fromUserID = user.userID;
    messageVC.fromUserAvatar = self.avatarInfo[indexPath];
    messageVC.messages = [user.messages.allObjects sortedArrayUsingDescriptors:@[[NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES]]];
    
    [self.navigationController pushViewController:messageVC animated:YES];
}

@end
