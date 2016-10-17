//
//  CreateEventStepThreeViewController.h
//  Embark
//
//  Created by Irvin Liao on 5/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@interface CreateEventStepThreeViewController : EmbarkTemplateViewController

@property (strong, nonatomic) NSMutableDictionary *eventInfo;
@property (strong, nonatomic) PFObject *event;
@property (assign, nonatomic) BOOL isEditing;

@end
