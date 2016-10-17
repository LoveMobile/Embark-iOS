//
//  CategoryTransitionAnimator.h
//  Embark
//
//  Created by Irvin Liao on 5/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface CategoryTransitionAnimator : NSObject <UIViewControllerAnimatedTransitioning>

@property (assign, nonatomic) BOOL isPresenting;

@end
