//
//  SignUpUsernameViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SignUpUsernameViewController.h"
#import "SignUpProfilePhotoViewController.h"

@interface SignUpUsernameViewController ()

@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@end

@implementation SignUpUsernameViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.usernameTextField becomeFirstResponder];
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
    
    if ([[segue identifier] isEqualToString:@"pushSignUpProfilePhotoViewController"]) {
        self.signUpUserInfo[@"username"] = [self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        SignUpProfilePhotoViewController *signUpProfilePhotoVC = [segue destinationViewController];
        signUpProfilePhotoVC.signUpUserInfo = self.signUpUserInfo;
    }
}

#pragma mark - Custom Actions

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please create a user name that is longer than 5 characters.";
    }
    else if ([[self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] < 5) {
        message = @"Please create a user name that is longer than 5 characters.";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self validateInputData]) {
        [self performSegueWithIdentifier:@"pushSignUpProfilePhotoViewController" sender:nil];
    }
    
    return YES;
}

@end
