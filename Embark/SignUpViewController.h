//
//  SignUpViewController.h
//  Embark
//
//  Created by Irvin Liao on 4/25/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface SignUpViewController : EmbarkTemplateViewController <UIViewControllerTransitioningDelegate, UITextFieldDelegate>

@property (assign, nonatomic) BOOL isLogOut;

@end
