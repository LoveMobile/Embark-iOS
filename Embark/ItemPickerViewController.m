//
//  ItemPickerViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/9/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "ItemPickerViewController.h"

@interface ItemPickerViewController ()

@property (weak, nonatomic) IBOutlet UIPickerView *picker;

@property (strong, nonatomic) NSArray *items;
@property (copy, nonatomic) NSString *selectedCategory;

@end

@implementation ItemPickerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = @[@"FOOD", @"DRINKS", @"SOCIAL", @"NIGHTLIFE", @"ADVENTURE", @"ATTRACTIONS"];
    self.selectedCategory = [self.items firstObject];
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

- (IBAction)toggleDone:(id)sender
{
    if ([self.delegate respondsToSelector:@selector(itemPickerViewController:didPickItem:)]) {
        [self.delegate itemPickerViewController:self didPickItem:self.selectedCategory];
    }
    
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - UIPickerViewDataSource

- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return [self.items count];
}

#pragma mark - UIPickerViewDelegate

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    return self.items[row];
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedCategory = self.items[row];
    if ([self.delegate respondsToSelector:@selector(itemPickerViewController:didPickItem:)]) {
        [self.delegate itemPickerViewController:self didPickItem:self.selectedCategory];
    }
}

@end
