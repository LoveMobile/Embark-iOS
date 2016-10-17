//
//  SettingsViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol SettingsViewControllerDelegate;

@interface SettingsViewController : UIViewController <UITableViewDataSource, UITableViewDelegate>

@property (assign, nonatomic) id <SettingsViewControllerDelegate> delegate;

@end

@protocol SettingsViewControllerDelegate <NSObject>

- (void)settingsViewControllerDidTapIndexPath:(NSIndexPath *)indexPath;

@end