//
//  EventListViewController.h
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "HomeCategoryGridViewController.h"
#import <CoreLocation/CoreLocation.h>

@interface EventListViewController : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UICollectionView *collectionView;

@property (strong, nonatomic) NSArray *eventsByCategory;
@property (strong, nonatomic) NSDictionary *eventPhotoInfo;
@property (strong, nonatomic) NSArray *iconImageNames;
@property (assign, nonatomic) CategoryType categoryType;
@property (strong, nonatomic) NSArray *categoryColors;
@property (assign, nonatomic) BOOL isFromHomeCategoryGrid;

@end
