//
//  SettingsItemViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "EmbarkTemplateViewController.h"

@protocol SettingsItemViewControllerDelegate;

@interface SettingsItemViewController : EmbarkTemplateViewController

@property (assign, nonatomic) id <SettingsItemViewControllerDelegate> delegate;

@end

@protocol SettingsItemViewControllerDelegate <NSObject>

- (void)settingsItemViewControllerDidClose;

@end