//
//  SettingsViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SettingsViewController.h"
#import "SettingsCell.h"

@interface SettingsViewController ()

@property (weak, nonatomic) IBOutlet UITableView *tableView;

@property (strong, nonatomic) NSArray *items;
@property (strong, nonatomic) UIFont *settingsFont;

@end

@implementation SettingsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.items = @[@"My Account", @"My Events", @"My Settings", @"Privacy Policy", @"Log Out"];
    
    self.settingsFont = [UIFont fontWithName:@"OpenSans" size:16.0];
    if (self.view.frame.size.width == 375.0) {
        self.settingsFont = [UIFont fontWithName:@"OpenSans" size:17.0];
    }
    else if (self.view.frame.size.width == 414.0) {
        self.settingsFont = [UIFont fontWithName:@"OpenSans" size:18.0];
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

#pragma mark - Button Actions

- (IBAction)toggleClose:(id)sender
{
    [self willMoveToParentViewController:nil];
    [self.view removeFromSuperview];
    [self removeFromParentViewController];
}

#pragma mark - UITableViewDataSource

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.items count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    SettingsCell *cell = [tableView dequeueReusableCellWithIdentifier:@"SettingsCell"];
    
    [self configureSettingsCell:cell atIndexPath:indexPath];
    
    return cell;
}

- (void)configureSettingsCell:(SettingsCell *)cell atIndexPath:(NSIndexPath *)indexPath
{
    cell.settingsLabel.font = self.settingsFont;
    cell.settingsLabel.text = self.items[indexPath.row];
}

#pragma mark - UITableViewDelegate

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 60.0 * tableView.frame.size.width / 320.0;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.delegate respondsToSelector:@selector(settingsViewControllerDidTapIndexPath:)]) {
        [self.delegate settingsViewControllerDidTapIndexPath:indexPath];
    }
}

@end
