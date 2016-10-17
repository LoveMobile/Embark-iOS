//
//  EventAnnotation.h
//  Embark
//
//  Created by Irvin Liao on 5/5/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MapKit/MapKit.h>
#import <Parse/Parse.h>

@interface EventAnnotation : NSObject <MKAnnotation>

@property (copy, nonatomic) NSString *title;
@property (copy, nonatomic) NSString *subtitle;
@property (assign, nonatomic) CLLocationCoordinate2D coordinate;

@property (copy, nonatomic) NSString *category;
@property (strong, nonatomic) PFObject *event;

- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate category:(NSString *)category;
- (instancetype)initWithTitle:(NSString *)title subtitle:(NSString *)subtitle coordinate:(CLLocationCoordinate2D)coordinate event:(PFObject *)event;

@end
