//
//  ItemPickerViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/9/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ItemPickerViewControllerDelegate;

@interface ItemPickerViewController : UIViewController <UIPickerViewDataSource, UIPickerViewDelegate>

@property (assign, nonatomic) id <ItemPickerViewControllerDelegate> delegate;

@end

@protocol ItemPickerViewControllerDelegate <NSObject>

- (void)itemPickerViewController:(ItemPickerViewController *)itemPickerViewController didPickItem:(NSString *)item;
- (void)itemPickerViewControllerDidFinish;

@end