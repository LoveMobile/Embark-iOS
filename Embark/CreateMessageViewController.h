//
//  CreateMessageViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/14/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface CreateMessageViewController : EmbarkTemplateViewController <UITableViewDataSource, UITableViewDelegate, UITextFieldDelegate, UITextViewDelegate>

@property (strong, nonatomic) PFUser *organizer;
@property (assign, nonatomic) BOOL isToOrganizer;

@end
