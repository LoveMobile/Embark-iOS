//
//  SignInViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SignInViewController.h"
#import "RecoverPasswordViewController.h"
#import "SignInTransitionAnimator.h"

@interface SignInViewController ()

@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;

@end

@implementation SignInViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // test
//    self.emailTextField.text = @"irvin.embark@gmail.com";
//    self.passwordTextField.text = @"irvin0204";
    
    [self.emailTextField becomeFirstResponder];
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

- (IBAction)toggleForgotPassword:(id)sender
{
    RecoverPasswordViewController *recoverPasswordVC = [self.storyboard instantiateViewControllerWithIdentifier:@"RecoverPasswordViewController"];
    
    [self.navigationController addChildViewController:recoverPasswordVC];
    recoverPasswordVC.view.frame = self.navigationController.view.frame;
    [self.navigationController.view addSubview:recoverPasswordVC.view];
    [recoverPasswordVC didMoveToParentViewController:self.navigationController];
}

#pragma mark - Custom Actions

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
    else if ([[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please enter password.";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

- (void)performSignIn
{
    if ([self validateInputData]) {
        [self presentEmbarkHUDWithMessage:@"Sign In"];
        
        [PFUser logInWithUsernameInBackground:[[self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString] password:[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] block:^(PFUser *user, NSError *error) {
            [self dismissEmbarkHUDViewController];
            if (error) {
                [self presentEmbarkAlertWithTitle:nil message:[error userInfo][@"error"] actionText:nil];
            } else {
                if (![user[@"emailVerified"] boolValue]) {
                    [self presentEmbarkAlertWithTitle:nil message:@"Please verify your email address." actionText:nil];
                } else {
                    
                    [PFInstallation currentInstallation][@"user"] = user;
                    [[PFInstallation currentInstallation] saveInBackground];
                    
                    PFFile *avatarFile = user[@"avatar"];
                    [avatarFile getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
                        NSURL *myAvatarURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"myAvatar.data"];
                        [imageData writeToURL:myAvatarURL atomically:YES];
                    }];
                    
                    [[NSUserDefaults standardUserDefaults] setBool:YES forKey:@"isLogin"];
                    [[NSUserDefaults standardUserDefaults] synchronize];
                    
                    UITabBarController *tabBarController = [self.storyboard instantiateViewControllerWithIdentifier:@"TabBarController"];
                    tabBarController.transitioningDelegate = self;
                    tabBarController.modalPresentationStyle = UIModalPresentationCustom;
                    
                    [self presentViewController:tabBarController animated:YES completion:nil];
                }
            }
        }];
    }
}

#pragma mark - UIViewControllerTransitioningDelegate

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForPresentedController:(UIViewController *)presented presentingController:(UIViewController *)presenting sourceController:(UIViewController *)source
{
    return [[SignInTransitionAnimator alloc] init];
}

- (id<UIViewControllerAnimatedTransitioning>)animationControllerForDismissedController:(UIViewController *)dismissed
{
    return nil;
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([textField isEqual:self.emailTextField]) {
        [self.passwordTextField becomeFirstResponder];
    }
    if ([textField isEqual:self.passwordTextField]) {
        [self performSignIn];
    }
    return YES;
}

@end
