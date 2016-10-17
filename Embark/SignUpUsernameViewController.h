//
//  SignUpUsernameViewController.h
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface SignUpUsernameViewController : EmbarkTemplateViewController <UITextFieldDelegate>

@property (strong, nonatomic) NSMutableDictionary *signUpUserInfo;

@end
