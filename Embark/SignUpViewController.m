//
//  SignUpViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/25/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SignUpViewController.h"
#import "SignUpPasswordViewController.h"
#import "SignInTransitionAnimator.h"
#import <PFFacebookUtils.h>
#import <FBSDKCoreKit.h>

@interface SignUpViewController ()

@property (weak, nonatomic) IBOutlet UIButton *closeButton;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;

@end

@implementation SignUpViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // test
//    self.emailTextField.text = @"irvin.embark@gmail.com";
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isLogOut) {
        [UIView animateWithDuration:0.8 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            self.view.alpha = 1.0;
        } completion:^(BOOL finished) {
            
        }];
    }
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
    
    if ([[segue identifier] isEqualToString:@"pushSignUpPasswordViewController"]) {
        NSMutableDictionary *signUpUserInfo = [NSMutableDictionary dictionary];
        signUpUserInfo[@"email"] = [[self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] lowercaseString];
        SignUpPasswordViewController *signUpPasswordVC = [segue destinationViewController];
        signUpPasswordVC.signUpUserInfo = signUpUserInfo;
    }
}

- (IBAction)unwindToSignUpViewController:(UIStoryboardSegue *)unwindSegue
{
    if ([[unwindSegue identifier] isEqualToString:@"unwindToSignUpViewControllerFromSignUpProfilePhotoViewController"]) {
        self.emailTextField.text = @"";
    }
}

#pragma mark - Button Actions

- (IBAction)toggleClose:(id)sender
{
    [self.emailTextField resignFirstResponder];
}

- (IBAction)toggleFacebook:(id)sender
{
    [self presentEmbarkHUDWithMessage:@"Sign In Facebook"];
    
    [PFFacebookUtils logInInBackgroundWithReadPermissions:@[@"public_profile", @"email"] block:^(PFUser *user, NSError *error) {
        [self dismissEmbarkHUDViewController];
        if (error) {
            [self presentEmbarkAlertWithTitle:nil message:[error userInfo][@"error"] actionText:nil];
        } else {
            if (!user) {
                [self presentEmbarkAlertWithTitle:nil message:@"Permission Denied" actionText:nil];
            } else {
                if (user.isNew) {
                    [self presentEmbarkHUDWithMessage:@"Loading"];
                    // add facebook user name
                    [[[FBSDKGraphRequest alloc] initWithGraphPath:@"me" parameters:nil] startWithCompletionHandler:^(FBSDKGraphRequestConnection *connection, id result, NSError *error) {
                        if (error) {
                            [self dismissEmbarkHUDViewController];
                            [self presentEmbarkAlertWithTitle:nil message:[error userInfo][@"error"] actionText:nil];
                        } else {
                            NSLog(@"fb request result: %@", result);
                            if (result[@"name"]) {
                                user[@"nickName"] = result[@"name"];
                            }
                            
                            // add facebook user avatar
                            NSURL *avatarURL = [NSURL URLWithString:[NSString stringWithFormat:@"http://graph.facebook.com/%@/picture?width=390&height=390", result[@"id"]]];
                            dispatch_async(dispatch_queue_create("DownloadAvatar", NULL), ^{
                                NSData *avatarData = [NSData dataWithContentsOfURL:avatarURL];
                                dispatch_async(dispatch_get_main_queue(), ^{
                                    UIImage *avatar = [UIImage imageWithData:avatarData];
                                    if (avatar) {
                                        user[@"avatar"] = [PFFile fileWithName:@"avatar.png" data:UIImagePNGRepresentation(avatar)];
                                    }
                                    [user saveInBackground];
                                    [self dismissEmbarkHUDViewController];
                                    [self presentEmbarkAlertWithTitle:@"Success!" message:@"Facebook Signed In" actionText:nil];
                                });
                            });
                        }
                    }];
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
        }
    }];
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
        message = @"Please enter a valid email address for registration.";
    }
    else if (![self validateEmailFormat:self.emailTextField.text]) {
        message = @"Please enter a valid email address for registration.";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
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

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    self.closeButton.hidden = NO;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    if ([self validateInputData]) {
        [self performSegueWithIdentifier:@"pushSignUpPasswordViewController" sender:nil];
    }
    
    return YES;
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    self.closeButton.hidden = YES;
}

@end
