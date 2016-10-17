//
//  EmbarkTemplateViewController.h
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Parse/Parse.h>

@interface EmbarkTemplateViewController : UIViewController

@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *verticalSpaceProportionalConstraints;
@property (strong, nonatomic) IBOutletCollection(NSLayoutConstraint) NSArray *proportionalWidthConstraints;

- (void)presentEmbarkAlertWithTitle:(NSString *)alertTitle message:(NSString *)alertMessage actionText:(NSString *)alertActionText;
- (void)dismissEmbarkAlertViewController;
- (void)presentEmbarkHUDWithMessage:(NSString *)message;
- (void)dismissEmbarkHUDViewController;
- (void)embarkAlertViewControllerDidDismiss;

@end
