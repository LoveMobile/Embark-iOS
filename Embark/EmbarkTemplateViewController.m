//
//  EmbarkTemplateViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"
#import "EmbarkAlertViewController.h"
#import "RecoverPasswordViewController.h"
#import "EmbarkHUDViewController.h"

@interface EmbarkTemplateViewController () <EmbarkAlertViewControllerDelegate>

@property (strong, nonatomic) EmbarkAlertViewController *embarkAlertViewController;
@property (strong, nonatomic) EmbarkHUDViewController *embarkHUDViewController;

@end

@implementation EmbarkTemplateViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if ([self isMemberOfClass:[EmbarkAlertViewController class]] || [self isMemberOfClass:[RecoverPasswordViewController class]] || [self isMemberOfClass:[EmbarkHUDViewController class]]) {
        for (NSLayoutConstraint *constraint in self.verticalSpaceProportionalConstraints) {
            constraint.constant = constraint.constant / 568 * self.view.frame.size.height;
        }
    } else {
        for (NSLayoutConstraint *constraint in self.verticalSpaceProportionalConstraints) {
            constraint.constant = constraint.constant / (568 - 64) * (self.view.frame.size.height - 64);
        }
    }
    for (NSLayoutConstraint *constraint in self.proportionalWidthConstraints) {
        constraint.constant = constraint.constant / 320 * self.view.frame.size.width;
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

#pragma mark - Embark Alert

- (void)presentEmbarkAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage actionText:(NSString *)alertActionText
{
    if (!self.embarkAlertViewController) {
        self.embarkAlertViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EmbarkAlertViewController"];
        self.embarkAlertViewController.alertTitle = alertTitle;
        self.embarkAlertViewController.alertMessage = alertMessage;
        self.embarkAlertViewController.alertActionText = alertActionText;
        self.embarkAlertViewController.delegate = self;
        
        if (self.navigationController) {
            [self.navigationController addChildViewController:self.embarkAlertViewController];
            self.embarkAlertViewController.view.frame = self.navigationController.view.frame;
            [self.navigationController.view addSubview:self.embarkAlertViewController.view];
            [self.embarkAlertViewController didMoveToParentViewController:self.navigationController];
        } else {
            [self addChildViewController:self.embarkAlertViewController];
            self.embarkAlertViewController.view.frame = self.view.frame;
            [self.view addSubview:self.embarkAlertViewController.view];
            [self.embarkAlertViewController didMoveToParentViewController:self];
        }
    }
}

- (void)dismissEmbarkAlertViewController
{
    [self.embarkAlertViewController willMoveToParentViewController:nil];
    [self.embarkAlertViewController.view removeFromSuperview];
    [self.embarkAlertViewController removeFromParentViewController];
    
    self.embarkAlertViewController = nil;
}

#pragma mark - EmbarkAlertViewControllerDelegate

- (void)embarkAlertViewControllerDidDismiss
{
    [self dismissEmbarkAlertViewController];
}

#pragma mark - Embark HUD

- (void)presentEmbarkHUDWithMessage:(NSString *)message
{
    if (!self.embarkHUDViewController) {
        self.embarkHUDViewController = [self.storyboard instantiateViewControllerWithIdentifier:@"EmbarkHUDViewController"];
        self.embarkHUDViewController.message = message;
        
        if (self.navigationController) {
            [self.navigationController addChildViewController:self.embarkHUDViewController];
            self.embarkHUDViewController.view.frame = self.navigationController.view.frame;
            [self.navigationController.view addSubview:self.embarkHUDViewController.view];
            [self.embarkHUDViewController didMoveToParentViewController:self.navigationController];
        } else {
            [self addChildViewController:self.embarkHUDViewController];
            self.embarkHUDViewController.view.frame = self.view.frame;
            [self.view addSubview:self.embarkHUDViewController.view];
            [self.embarkHUDViewController didMoveToParentViewController:self];
        }
    }
}

- (void)dismissEmbarkHUDViewController
{
    [self.embarkHUDViewController willMoveToParentViewController:nil];
    [self.embarkHUDViewController.view removeFromSuperview];
    [self.embarkHUDViewController removeFromParentViewController];
    
    self.embarkHUDViewController = nil;
}

@end
