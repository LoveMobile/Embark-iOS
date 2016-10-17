//
//  CreateMessageViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/14/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "CreateMessageViewController.h"
#import "RecipientCell.h"
#import <Parse/Parse.h>

@interface CreateMessageViewController ()

@property (weak, nonatomic) IBOutlet UITextField *recipientTextField;
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (weak, nonatomic) IBOutlet UITextView *messageTextView;
@property (weak, nonatomic) IBOutlet UIView *textViewPlaceholderContainer;

@property (strong, nonatomic) NSArray *recipients;
@property (strong, nonatomic) PFQuery *userQuery;
@property (strong, nonatomic) UIFont *boldFont;
@property (strong, nonatomic) PFUser *selectedRecipient;
@property (assign, nonatomic) BOOL isEmptyMessage;
@property (assign, nonatomic) BOOL isMessageSent;

@property (weak, nonatomic) IBOutlet NSLayoutConstraint *messageTextViewContainerToBottomSpaceConstraint;

@end

@implementation CreateMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerKeyboardNotifications];
    
    if (self.isToOrganizer) {
        [self.recipientTextField setEnabled:NO];
        self.recipientTextField.text = self.organizer[@"nickName"];
        self.selectedRecipient = self.organizer;
        [self.messageTextView becomeFirstResponder];
    } else {
        [self.recipientTextField becomeFirstResponder];
    }
    
    self.boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    if (self.view.frame.size.width == 375.0) {
        self.boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:16.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        self.boldFont = [UIFont fontWithName:@"OpenSans-Bold" size:18.0];
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

#pragma mark - Custom Actions

- (void)sendMessage
{
    if ([self validateInputData]) {
        PFObject *message = [PFObject objectWithClassName:@"Message"];
        message[@"content"] = [self.messageTextView.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        message[@"fromUserID"] = [[PFUser currentUser] objectId];
        message[@"toUserID"] = self.selectedRecipient.objectId;
        message[@"fromUserNickname"] = [PFUser currentUser][@"nickName"];
        message[@"toUserNickname"] = self.selectedRecipient[@"nickName"];
        message[@"isRead"] = @NO;
        
        [self presentEmbarkHUDWithMessage:@"Sending Message"];
        [message saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissEmbarkHUDViewController];
            if (error) {
                [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
            } else {
                self.isMessageSent = YES;
                [[NSNotificationCenter defaultCenter] postNotificationName:@"MessagesSentByMeDidSucceedNotification" object:nil userInfo:@{@"toUserID" : self.selectedRecipient.objectId}];
                [self presentEmbarkAlertWithTitle:@"Success!" message:@"Message Sent!" actionText:nil];
            }
        }];
    }
}

- (BOOL)validateInputData
{
    NSString *message = @"";
    if (!self.selectedRecipient) {
        message = @"No Recipient";
    }
    else if ([[self.messageTextView.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Enter Message";
        self.isEmptyMessage = YES;
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextField Notifications

- (void)registerTextFieldNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange:) name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)unregisterTextFieldNotifications
{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UITextFieldTextDidChangeNotification object:nil];
}

- (void)textFieldTextDidChange:(NSNotification *)notification
{
    NSString *text = [[(UITextField *)[notification object] text] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([text isEqualToString:@""]) {
        self.tableView.hidden = YES;
    } else {
        if (self.userQuery) {
            [self.userQuery cancel];
        }
        self.userQuery = [PFUser query];
        [self.userQuery whereKey:@"nickName" matchesRegex:[NSString stringWithFormat:@"^%@", text] modifiers:@"i"];
        [self.userQuery whereKey:@"objectId" notEqualTo:[[PFUser currentUser] objectId]];
        
        [self.userQuery findObjectsInBackgroundWithBlock:^(NSArray *objects, NSError *error) {
            if (!error) {
                self.recipients = objects;
                NSLog(@"candidate recipients: %@", objects);
                
                if ([objects count] > 0) {
                    self.tableView.hidden = NO;
                    [self.tableView reloadData];
                } else {
                    self.tableView.hidden = YES;
                }
            }
        }];
    }
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.recipients count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    RecipientCell *cell = [tableView dequeueReusableCellWithIdentifier:@"RecipientCell"];
    cell.avatarIV.image = nil;
    [cell.avatarActivityIndicator startAnimating];
    cell.nameLabel.font = self.boldFont;
    
    [self configureRecipientCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureRecipientCell:(RecipientCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    PFUser *recipient = self.recipients[indexPath.row];
    cell.avatarIV.layer.cornerRadius = cell.avatarIV.frame.size.width / 2;
    PFFile *avatar = recipient[@"avatar"];
    [avatar getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        cell.avatarIV.image = [UIImage imageWithData:imageData];
        [cell.avatarActivityIndicator stopAnimating];
    }];
    
    cell.nameLabel.text = recipient[@"nickName"];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 72.0 * self.view.frame.size.height / 568.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    self.selectedRecipient = self.recipients[indexPath.row];
    [self.messageTextView becomeFirstResponder];
    self.tableView.hidden = YES;
    
    self.recipientTextField.text = self.selectedRecipient[@"nickName"];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self registerTextFieldNotifications];
    
    return YES;
}

- (BOOL)textFieldShouldEndEditing:(UITextField *)textField
{
    [self unregisterTextFieldNotifications];
    
    return YES;
}

#pragma mark - UITextViewDelegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    self.textViewPlaceholderContainer.hidden = YES;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text
{
    if ([text isEqualToString:@"\n"]) {
        [textView resignFirstResponder];
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

#pragma mark - EmbarkAlertViewControllerDelegate

- (void)embarkAlertViewControllerDidDismiss
{
    [super embarkAlertViewControllerDidDismiss];
    
    if (self.isEmptyMessage) {
        self.isEmptyMessage = NO;
        [self.messageTextView becomeFirstResponder];
    }
    if (self.isMessageSent) {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
