//
//  MySettingsViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "MySettingsViewController.h"

@interface MySettingsViewController ()

@property (weak, nonatomic) IBOutlet UISlider *radiusSlider;
@property (weak, nonatomic) IBOutlet UISwitch *alertSwitch;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *settingsItemLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *radiusDigitLabels;
@property (strong, nonatomic) IBOutletCollection(UILabel) NSArray *radiusUnitLabels;

@property (strong, nonatomic) UIFont *settingsItemFont;

@end

@implementation MySettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.settingsItemFont = [UIFont fontWithName:@"OpenSans" size:16.0];
    
    for (UILabel *settingsItemLabel in self.settingsItemLabels) {
        settingsItemLabel.font = self.settingsItemFont;
    }
    for (UILabel *radiusDigitLabel in self.radiusDigitLabels) {
        radiusDigitLabel.font = [UIFont fontWithName:@"OpenSans-Bold" size:14.0];
    }
    for (UILabel *radiusUnitLabel in self.radiusUnitLabels) {
        radiusUnitLabel.font = [UIFont fontWithName:@"OpenSans" size:14.0];
    }
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

#pragma mark - Slider Actions

- (IBAction)toggleRadiusSlider:(UISlider *)sender
{
    
}

#pragma mark - Switch Actions

- (IBAction)toggleAlertSwitch:(UISwitch *)sender
{
    
}

#pragma mark - Button Actions

- (IBAction)toggleSave:(id)sender
{
    
}

@end
