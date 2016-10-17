//
//  HomeCategoryGridCell.h
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface HomeCategoryGridCell : UICollectionViewCell

@property (strong, nonatomic) IBOutletCollection(UIView) NSArray *backgroundViews;
@property (weak, nonatomic) IBOutlet UIView *upperRadiusBackgroundView;
@property (weak, nonatomic) IBOutlet UIView *lowerRadiusBackgroundView;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIV;
@property (weak, nonatomic) IBOutlet UIImageView *categoryIconIV;
@property (weak, nonatomic) IBOutlet UILabel *categoryNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *categoryDescriptionLabel;

@end
