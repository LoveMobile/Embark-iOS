//
//  Message.h
//  Embark
//
//  Created by Irvin Liao on 6/19/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class EmbarkUser;

@interface Message : NSManagedObject

@property (nonatomic, retain) NSString * content;
@property (nonatomic, retain) NSDate * createdAt;
@property (nonatomic, retain) NSString * fromUserID;
@property (nonatomic, retain) NSNumber * isRead;
@property (nonatomic, retain) NSString * messageID;
@property (nonatomic, retain) NSString * toUserID;
@property (nonatomic, retain) EmbarkUser *embarkUser;

@end
