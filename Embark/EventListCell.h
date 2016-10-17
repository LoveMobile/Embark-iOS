//
//  EventListCell.h
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EventListCell : UICollectionViewCell

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *backgroundViews;
@property (weak, nonatomic) IBOutlet UIView *upperRadiusBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *lowerRadiusBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *eventIV;
@property (weak, nonatomic) IBOutlet UILabel *eventTitleLabel;
@property (weak, nonatomic) IBOutlet UILabel *eventDescriptionLabel;
@property (weak, nonatomic) IBOutlet UIImageView *eventCategoryIV;
@property (weak, nonatomic) IBOutlet UILabel *eventDistanceLabel;

@end
