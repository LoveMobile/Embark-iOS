//
//  DatePickerViewController.h
//  Embark
//
//  Created by Irvin Liao on 6/9/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol DatePickerViewControllerDelegate;

@interface DatePickerViewController : UIViewController

@property (assign, nonatomic) BOOL isDateMode;
@property (assign, nonatomic) id <DatePickerViewControllerDelegate> delegate;

@end

@protocol DatePickerViewControllerDelegate <NSObject>

- (void)datePickerViewController:(DatePickerViewController *)datePickerViewController didPickDate:(NSDate *)date;
- (void)datePickerViewControllerDidFinish;

@end