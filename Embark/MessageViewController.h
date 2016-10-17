//
//  MessageViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/14/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface MessageViewController : EmbarkTemplateViewController <UITableViewDataSource, UITableViewDelegate, UITextViewDelegate>

@property (strong, nonatomic) PFObject *fromUser;
@property (copy, nonatomic) NSString *fromUserID;
@property (strong, nonatomic) UIImage *fromUserAvatar;
@property (strong, nonatomic) NSArray *messages;

@end
