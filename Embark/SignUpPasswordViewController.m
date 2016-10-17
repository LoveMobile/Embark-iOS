//
//  SignUpPasswordViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/25/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SignUpPasswordViewController.h"
#import "SignUpUsernameViewController.h"

@interface SignUpPasswordViewController ()

@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SignUpPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.passwordTextField becomeFirstResponder];
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
    
    if ([[segue identifier] isEqualToString:@"pushSignUpUsernameViewController"]) {
        self.signUpUserInfo[@"password"] = [self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        SignUpUsernameViewController *signUpUsernameVC = [segue destinationViewController];
        signUpUsernameVC.signUpUserInfo = self.signUpUserInfo;
    }
}

#pragma mark - Custom Actions

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please create a password that is longer than 6 characters.";
    }
    else if ([[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] length] < 6) {
        message = @"Please create a password that is longer than 6 characters.";
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
        [self performSegueWithIdentifier:@"pushSignUpUsernameViewController" sender:nil];
    }
    
    return YES;
}

@end
