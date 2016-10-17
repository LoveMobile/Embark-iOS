//
//  CategoryTransitionAnimator.m
//  Embark
//
//  Created by Irvin Liao on 5/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "CategoryTransitionAnimator.h"
#import "EventListViewController.h"

@implementation CategoryTransitionAnimator

#pragma mark - UIViewControllerAnimatedTransitioning

- (NSTimeInterval)transitionDuration:(id<UIViewControllerContextTransitioning>)transitionContext
{
    return 0.3;
}

- (void)animateTransition:(id<UIViewControllerContextTransitioning>)transitionContext
{
    UIViewController *fromViewController = [transitionContext viewControllerForKey:UITransitionContextFromViewControllerKey];
    UIViewController *toViewController = [transitionContext viewControllerForKey:UITransitionContextToViewControllerKey];
    
    [[transitionContext containerView] addSubview:toViewController.view];
    [[transitionContext containerView] addSubview:fromViewController.view];
    
    if (self.isPresenting) {
        UICollectionView *eventListCollectionView = [(EventListViewController *)toViewController collectionView];
        eventListCollectionView.transform = CGAffineTransformMakeTranslation(0, -CGRectGetHeight([[transitionContext containerView] frame]));
        
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseIn animations:^{
            fromViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
                eventListCollectionView.transform = CGAffineTransformIdentity;
            } completion:^(BOOL finished) {
                fromViewController.view.alpha = 1.0;
                [transitionContext completeTransition:YES];
            }];
        }];
    } else {
        [UIView animateWithDuration:0.3 delay:0 options:UIViewAnimationOptionCurveEaseOut animations:^{
            fromViewController.view.alpha = 0;
        } completion:^(BOOL finished) {
            [transitionContext completeTransition:YES];
        }];
    }
}

- (void)animationEnded:(BOOL)transitionCompleted
{
    
}

@end
