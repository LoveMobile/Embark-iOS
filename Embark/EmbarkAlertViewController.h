//
//  EmbarkAlertViewController.h
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@protocol EmbarkAlertViewControllerDelegate;

@interface EmbarkAlertViewController : EmbarkTemplateViewController

@property (copy, nonatomic) NSString *alertTitle;
@property (copy, nonatomic) NSString *alertMessage;
@property (copy, nonatomic) NSString *alertActionText;
@property (assign, nonatomic) id <EmbarkAlertViewControllerDelegate> delegate;

@end

@protocol EmbarkAlertViewControllerDelegate <NSObject>

- (void)embarkAlertViewControllerDidDismiss;

@end