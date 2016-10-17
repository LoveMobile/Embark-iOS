//
//  EmbarkAlertViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkAlertViewController.h"

@interface EmbarkAlertViewController ()

@property (weak, nonatomic) IBOutlet UILabel *alertTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *alertMessageLabel;
@property (weak, nonatomic) IBOutlet UIButton *alertActionButton;

@end

@implementation EmbarkAlertViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
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
    
    if (!self.alertTitle) {
        self.alertTitle = @"Error";
    }
    self.alertTitleLabel.font = [UIFont fontWithName:@"OpenSans" size:titleFontSize];
    self.alertTitleLabel.text = self.alertTitle;
    
    self.alertMessageLabel.font = [UIFont fontWithName:@"OpenSans" size:messageFontSize];
    self.alertMessageLabel.text = self.alertMessage;
    
    if (!self.alertActionText) {
        self.alertActionText = @"Ok, Got it";
    }
    [self.alertActionButton setTitle:self.alertActionText forState:UIControlStateNormal];
    [self.alertActionButton setTitle:self.alertActionText forState:UIControlStateHighlighted];
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

- (IBAction)toggleOK:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(embarkAlertViewControllerDidDismiss)]) {
        [self.delegate embarkAlertViewControllerDidDismiss];
    }
}

@end
