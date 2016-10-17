//
//  EmbarkButton.m
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkButton.h"

@implementation EmbarkButton

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

- (void)setTitleFont:(UIFont *)titleFont
{
    if (_titleFont != titleFont) {
        _titleFont = titleFont;
        [self.titleLabel setFont:_titleFont];
    }
}

@end
