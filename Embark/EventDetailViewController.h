//
//  EventDetailViewController.h
//  Embark
//
//  Created by Irvin Liao on 5/5/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>
#import "EventListViewController.h"

@interface EventDetailViewController : EmbarkTemplateViewController <CLLocationManagerDelegate, MKMapViewDelegate>

@property (strong, nonatomic) PFObject *event;
@property (assign, nonatomic) CategoryType categoryType;
@property (strong, nonatomic) UIColor *categoryColor;

@end
