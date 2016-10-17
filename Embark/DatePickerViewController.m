//
//  DatePickerViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/9/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "DatePickerViewController.h"

@interface DatePickerViewController ()

@property (weak, nonatomic) IBOutlet UIDatePicker *datePicker;

@end

@implementation DatePickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.datePicker.datePickerMode = self.isDateMode ? UIDatePickerModeDate : UIDatePickerModeTime;
    self.datePicker.minuteInterval = 15;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - Button Actions

- (IBAction)pickDate:(UIDatePicker *)datePicker
{
    if ([self.delegate respondsToSelector:@selector(datePickerViewController:didPickDate:)]) {
        [self.delegate datePickerViewController:self didPickDate:datePicker.date];
    }
}

- (IBAction)toggleDone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(datePickerViewControllerDidFinish)]) {
        [self.delegate datePickerViewControllerDidFinish];
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

@end
