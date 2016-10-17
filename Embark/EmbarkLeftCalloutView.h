//
//  EmbarkCalloutView.h
//  Embark
//
//  Created by Irvin Liao on 5/30/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EmbarkLeftCalloutView : UIView

@property (strong, nonatomic) UIImageView *iconIV;

- (instancetype)initWithFrame:(CGRect)frame icon:(UIImage *)icon;

@end
