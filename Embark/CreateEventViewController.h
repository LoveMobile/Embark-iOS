//
//  CreateEventViewController.h
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface CreateEventViewController : EmbarkTemplateViewController <UITextFieldDelegate>

@property (strong, nonatomic) PFObject *event;
@property (assign, nonatomic) BOOL isEditing;

@end
