//
//  EmbarkHUDViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkHUDViewController.h"

@interface EmbarkHUDViewController ()

@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *activityIndicator;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;

@end

@implementation EmbarkHUDViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    CGFloat messageFontSize = 18.0;
    if (self.view.frame.size.width == 375.0) {
        messageFontSize = 20.0;
    }
    else if (self.view.frame.size.width == 414.0) {
        messageFontSize = 22.0;
    }
    
    self.messageLabel.font = [UIFont fontWithName:@"OpenSans" size:messageFontSize];
    self.messageLabel.text = self.message;
    
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

@end
