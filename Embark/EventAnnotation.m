//
//  EventAnnotation.m
//  Embark
//
//  Created by Irvin Liao on 5/5/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EventAnnotation.h"

@implementation EventAnnotation

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate category:(NSString *)category
{
    self = [super init];
    if (self) {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
        self.category = category;
    }
    return self;
}

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate event:(PFObject *)event
{
    self = [super init];
    if (self) {
        self.title = title;
        self.subtitle = subtitle;
        self.coordinate = coordinate;
        self.event = event;
    }
    return self;
}

@end
