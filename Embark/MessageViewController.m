//
//  MessageViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/14/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "MessageViewController.h"
#import "Message.h"
#import "MessageCell.h"
#import "MyMessageCell.h"
#import "AppDelegate.h"

@interface MessageViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *textViewPlaceholderContainer;

@property (strong, nonatomic) UIImage *myAvatar;
@property (strong, nonatomic) UIFont *userNameFont;
@property (strong, nonatomic) UIFont *messageFont;
@property (strong, nonatomic) UIFont *durationFont;
@property (strong, nonatomic) NSManagedObjectContext *managedObjectContext;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewContainerToBottomSpaceConstraint;

@end

@implementation MessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.tableView.estimatedRowHeight = 128.0;
    self.tableView.rowHeight = UITableViewAutomaticDimension;
    
    [self registerKeyboardNotifications];
    
    NSURL *myAvatarURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"myAvatar.data"];
    self.myAvatar = [UIImage imageWithData:[NSData dataWithContentsOfURL:myAvatarURL]];
    
    self.userNameFont = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    self.messageFont = [UIFont fontWithName:@"OpenSans" size:14.0];
    self.durationFont = [UIFont fontWithName:@"OpenSans" size:10.0];
    
    AppDelegate *appDelegate = [[UIApplication sharedApplication] delegate];
    self.managedObjectContext = appDelegate.managedObjectContext;
    
    [self.messageTextView becomeFirstResponder];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    [self registerMessageNotifications];
    
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

- (void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:animated];
    
    if (![self.managedObjectContext save:NULL]) {
        NSLog(@"save read state error");
    }
    [[NSNotificationCenter defaultCenter] postNotificationName:@"InboxViewControllerShouldUpdateReadStateNotification" object:nil];
    
    [self unregisterMessageNotifications];
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
    
    self.messageTextViewContainerToBottomSpaceConstraint.constant = keyboardRect.size.height;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    self.messageTextViewContainerToBottomSpaceConstraint.constant = 0;
    
    [UIView animateWithDuration:duration animations:^{
        [self.view layoutIfNeeded];
    }];
}

#pragma mark - Message Notifications

- (void)registerMessageNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMessagesFromUserID:) name:@"InboxViewControllerDidRetrieveMessageFromUserIDNotification" object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(fetchMessagesToUserID:) name:@"InboxViewControllerDidRetrieveMessageToUserIDNotification" object:nil];
}

- (void)unregisterMessageNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InboxViewControllerDidRetrieveMessageFromUserIDNotification" object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:@"InboxViewControllerDidRetrieveMessageToUserIDNotification" object:nil];
}

- (void)fetchMessagesFromUserID:(NSNotification *)notification
{
    NSString *fromUserID = [notification userInfo][@"fromUserID"];
    [self fetchMessagesWithUserID:fromUserID];
}

- (void)fetchMessagesToUserID:(NSNotification *)notification
{
    NSString *toUserID = [notification userInfo][@"toUserID"];
    [self fetchMessagesWithUserID:toUserID];
}

#pragma mark - Gesture Actions

- (IBAction)tapTextViewPlaceholder:(UITapGestureRecognizer *)sender
{
    [self.messageTextView becomeFirstResponder];
}

- (IBAction)tapDismissKeyboardContainer:(UITapGestureRecognizer *)sender
{
    [self.messageTextView resignFirstResponder];
}

#pragma mark - Custom Actions

- (void)sendMessage
{
    if ([self validateInputData]) {
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"content"] = [self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        message[@"fromUserID"] = [[PFUser currentUser] objectId];
        message[@"toUserID"] = self.fromUserID;
        message[@"fromUserNickname"] = [PFUser currentUser][@"nickName"];
        message[@"toUserNickname"] = self.fromUser[@"nickName"];
        message[@"isRead"] = @NO;
        
        self.messageTextView.text = @"";
        
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            if (error) {
                [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
            } else {
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagesSentByMeDidSucceedNotification" object:nil userInfo:@{@"toUserID" : self.fromUserID}];
            }
        }];
    }
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

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.messageTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Enter Message";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

- (void)fetchMessagesWithUserID:(NSString *)userID
{
    NSFetchRequest *fetchRequest = [[NSFetchRequest alloc] init];
    NSEntityDescription *entity = [NSEntityDescription entityForName:@"Message" inManagedObjectContext:self.managedObjectContext];
    [fetchRequest setEntity:entity];
    
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"fromUserID MATCHES %@ OR toUserID MATCHES %@", userID, userID];
    [fetchRequest setPredicate:predicate];
    
    NSSortDescriptor *sortDescriptor = [NSSortDescriptor sortDescriptorWithKey:@"createdAt" ascending:YES];
    [fetchRequest setSortDescriptors:@[sortDescriptor]];
    
    NSError *error = nil;
    self.messages = [self.managedObjectContext executeFetchRequest:fetchRequest error:&error];
    if (error) {
        NSLog(@"fetch messages error: %@", [error localizedDescription]);
    }
    [self.tableView reloadData];
    [self.tableView scrollToRowAtIndexPath:[NSIndexPath indexPathForRow:([self.messages count] - 1) inSection:0] atScrollPosition:UITableViewScrollPositionBottom animated:NO];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    Message *message = self.messages[indexPath.row];
    
    if ([message.toUserID isEqualToString:[[PFUser currentUser] objectId]]) {
        MessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MessageCell"];
        
        [self configureMessageCell:cell atIndexPath:indexPath];
        
        return cell;
    } else {
        MyMessageCell *cell = [tableView dequeueReusableCellWithIdentifier:@"MyMessageCell"];
        
        [self configureMyMessageCell:cell atIndexPath:indexPath];
        
        return cell;
    }
}

- (void)configureMessageCell:(MessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = self.messages[indexPath.row];
    message.isRead = @YES;
    
    cell.avatarIV.image = self.fromUserAvatar;
    cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2;
    
    cell.nameLabel.font = self.userNameFont;
    cell.nameLabel.text = self.fromUser[@"nickName"];
    
    cell.contentLabel.font = self.messageFont;
    cell.contentLabel.text = message.content;
    
    cell.durationLabel.font = self.durationFont;
    NSTimeInterval duration = [message.createdAt timeIntervalSinceNow] * -1;
    cell.durationLabel.text = [self formatDuration:duration];
}

- (void)configureMyMessageCell:(MyMessageCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    Message *message = self.messages[indexPath.row];
    message.isRead = @YES;
    
    cell.avatarIV.image = self.myAvatar;
    cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2;
    
    cell.nameLabel.font = self.userNameFont;
    cell.nameLabel.text = [PFUser currentUser][@"nickName"];
    
    cell.contentLabel.font = self.messageFont;
    cell.contentLabel.text = message.content;
    
    cell.durationLabel.font = self.durationFont;
    NSTimeInterval duration = [message.createdAt timeIntervalSinceNow] * -1;
    cell.durationLabel.text = [self formatDuration:duration];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 128.0;
}
/*
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 44.0;
}
*/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self.messageTextView resignFirstResponder];
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textViewPlaceholderContainer.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
//        [textView resignFirstResponder];
        [self sendMessage];
        
        return NO;
    }
    
    return YES;
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([[textView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        self.textViewPlaceholderContainer.hidden = NO;
    }
}

@end
