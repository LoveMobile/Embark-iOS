//
//  EmbarkCalloutView.m
//  Embark
//
//  Created by Irvin Liao on 5/30/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkLeftCalloutView.h"

@implementation EmbarkLeftCalloutView

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame icon:(UIImage *)icon
{
    self = [self initWithFrame:frame];
    
    self.iconIV = [[UIImageView alloc] initWithImage:icon];
    self.iconIV.contentMode = UIViewContentModeScaleAspectFit;
    self.iconIV.center = CGPointMake(CGRectGetMidX(frame), CGRectGetMidY(frame));
    [self addSubview:self.iconIV];
    
    return self;
}

@end
