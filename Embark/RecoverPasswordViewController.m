//
//  RecoverPasswordViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "RecoverPasswordViewController.h"

@interface RecoverPasswordViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet UIView *messageContainer;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (weak, nonatomic) IBOutlet UIView *emailContainer;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UIButton *actionButton;

@property (copy, nonatomic) NSString *initialTitle;
@property (copy, nonatomic) NSString *initialActionText;
@property (copy, nonatomic) NSString *successTitle;
@property (copy, nonatomic) NSString *successMessage;
@property (copy, nonatomic) NSString *successActionText;
@property (copy, nonatomic) NSString *errorTitle;
@property (copy, nonatomic) NSString *errorMessage;
@property (copy, nonatomic) NSString *errorActionText;

@end

@implementation RecoverPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // test
//    self.emailTextField.text = @"irvin.embark@gmail.com";
    
    [self.emailTextField becomeFirstResponder];
    
    self.initialTitle = @"Recover Password";
    self.initialActionText = @"Send me my password";
    
    self.successTitle = @"Success!";
    self.successMessage = @"We have sent you instructions on how to log back in at the email address you entered!";
    self.successActionText = @"Ok, Got it";
    
    self.errorTitle = @"Error";
    self.errorMessage = @"Sorry, we couldn't find your email in our database. Please check your spelling or try new email.";
    self.errorActionText = @"Try different email";
    
    CGFloat titleFontSize = 18.0;
    CGFloat messageFontSize = 14.0;
    if (self.view.frame.size.width == 375.0) {
        titleFontSize = 20.0;
        messageFontSize = 16.0;
    }
    else if (self.view.frame.size.width == 414.0) {
        titleFontSize = 22.0;
        messageFontSize = 18.0;
    }
    
    self.alertTitleLabel.font = [UIFont fontWithName:@"OpenSans" size:titleFontSize];
    
    self.alertMessageLabel.font = [UIFont fontWithName:@"OpenSans" size:messageFontSize];
    
    [self.actionButton addTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
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

#pragma mark - Button Actions

- (void)toggleSendPassword:(UIButton *)sender
{
    if ([self validateInputData]) {
        [self performResetPassword];
    }
}

- (void)toggleOK:(UIButton *)sender
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

- (void)toggleInvalidEmailOK:(UIButton *)sender
{
    self.emailContainer.hidden = NO;
    self.messageContainer.hidden = YES;
    
    self.alertTitleLabel.text = self.initialTitle;
    [sender removeTarget:self action:@selector(toggleInvalidEmailOK:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
    [sender setTitle:self.initialActionText forState:UIControlStateNormal];
    [sender setTitle:self.initialActionText forState:UIControlStateHighlighted];
}

- (void)toggleTryDifferentEmail:(UIButton *)sender
{
    self.emailContainer.hidden = NO;
    self.messageContainer.hidden = YES;
    
    self.alertTitleLabel.text = self.initialTitle;
    [sender removeTarget:self action:@selector(toggleTryDifferentEmail:) forControlEvents:UIControlEventTouchUpInside];
    [sender addTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
    [sender setTitle:self.initialActionText forState:UIControlStateNormal];
    [sender setTitle:self.initialActionText forState:UIControlStateHighlighted];
}

#pragma mark - Custom Actions

- (void)performResetPassword
{
    [self presentEmbarkHUDWithMessage:@"Reset Password"];
    
    [PFUser requestPasswordResetForEmailInBackground:[self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] block:^(BOOL succeeded, NSError *error) {
        [self dismissEmbarkHUDViewController];
        if (error) {
            self.emailContainer.hidden = YES;
            self.messageContainer.hidden = NO;
            
            self.alertTitleLabel.text = self.errorTitle;
            self.alertMessageLabel.text = self.errorMessage;
            [self.actionButton removeTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
            [self.actionButton addTarget:self action:@selector(toggleTryDifferentEmail:) forControlEvents:UIControlEventTouchUpInside];
            [self.actionButton setTitle:self.errorActionText forState:UIControlStateNormal];
            [self.actionButton setTitle:self.errorActionText forState:UIControlStateHighlighted];
        } else {
            self.emailContainer.hidden = YES;
            self.messageContainer.hidden = NO;
            
            self.alertTitleLabel.text = self.successTitle;
            self.alertMessageLabel.text = self.successMessage;
            [self.actionButton removeTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
            [self.actionButton addTarget:self action:@selector(toggleOK:) forControlEvents:UIControlEventTouchUpInside];
            [self.actionButton setTitle:self.successActionText forState:UIControlStateNormal];
            [self.actionButton setTitle:self.successActionText forState:UIControlStateHighlighted];
        }
    }];
}

- (BOOL)validateEmailFormat:(NSString *)emailText
{
    NSString *emailRegEx = @"[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,4}";
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", emailRegEx];
    
    return [predicate evaluateWithObject:emailText];
}

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please enter email address.";
    }
    else if (![self validateEmailFormat:self.emailTextField.text]) {
        message = @"Please enter a valid email address.";
    }
    
    if (![message isEqualToString:@""]) {
        self.emailContainer.hidden = YES;
        self.messageContainer.hidden = NO;
        
        self.alertTitleLabel.text = self.errorTitle;
        self.alertMessageLabel.text = message;
        [self.actionButton removeTarget:self action:@selector(toggleSendPassword:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton addTarget:self action:@selector(toggleInvalidEmailOK:) forControlEvents:UIControlEventTouchUpInside];
        [self.actionButton setTitle:@"Ok, Got it" forState:UIControlStateNormal];
        [self.actionButton setTitle:@"Ok, Got it" forState:UIControlStateHighlighted];
        
        return NO;
    }
    
    return YES;
}

@end
