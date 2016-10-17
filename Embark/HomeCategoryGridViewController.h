//
//  HomeListViewController.h
//  Embark
//
//  Created by Irvin Liao on 4/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

typedef NS_ENUM(NSInteger, CategoryType)
{
    CategoryTypeFood,
    CategoryTypeDrinks,
    CategoryTypeSocial,
    CategoryTypeNightLife,
    CategoryTypeAdventure,
    CategoryTypeAttractions
};

@interface HomeCategoryGridViewController : EmbarkTemplateViewController <UICollectionViewDataSource, UICollectionViewDelegate, UICollectionViewDelegateFlowLayout, UINavigationControllerDelegate>

@end
