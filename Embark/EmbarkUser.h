//
//  EmbarkUser.h
//  Embark
//
//  Created by Irvin Liao on 6/19/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreData/CoreData.h>

@class Message;

@interface EmbarkUser : NSManagedObject

@property (nonatomic, retain) NSString * userID;
@property (nonatomic, retain) NSString * nickname;
@property (nonatomic, retain) NSDate * updatedAt;
@property (nonatomic, retain) NSSet *messages;
@end

@interface EmbarkUser (CoreDataGeneratedAccessors)

- (void)addMessagesObject:(Message *)value;
- (void)removeMessagesObject:(Message *)value;
- (void)addMessages:(NSSet *)values;
- (void)removeMessages:(NSSet *)values;

@end
