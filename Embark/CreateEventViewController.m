//
//  CreateEventViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/4/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "CreateEventViewController.h"
#import "CreateEventStepTwoViewController.h"
#import "DatePickerViewController.h"
#import "ItemPickerViewController.h"

@interface CreateEventViewController () <DatePickerViewControllerDelegate, ItemPickerViewControllerDelegate>

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UITextField *titleTextField;
@property (weak, nonatomic) IBOutlet UITextField *guestAmountTextField;
@property (weak, nonatomic) IBOutlet UIButton *dateButton;
@property (weak, nonatomic) IBOutlet UIButton *timeButton;
@property (weak, nonatomic) IBOutlet UIButton *categoryButton;
@property (weak, nonatomic) IBOutlet UIView *tapGestureContainer;

@property (strong, nonatomic) NSDateFormatter *dateFormatter;
@property (strong, nonatomic) NSDateFormatter *timeFormatter;
@property (assign, nonatomic) BOOL isPickingDate;
@property (strong, nonatomic) NSMutableDictionary *eventInfo;
@property (strong, nonatomic) NSDate *selectedDate;
@property (strong, nonatomic) NSDate *selectedTime;
@property (copy, nonatomic) NSString *selectedCategory;

@end

@implementation CreateEventViewController

- (id)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self) {
        [self.tabBarItem setImage:[[UIImage imageNamed:@"tab_create"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setSelectedImage:[[UIImage imageNamed:@"tab_create_selected"] imageWithRenderingMode:UIImageRenderingModeAlwaysOriginal]];
        [self.tabBarItem setImageInsets:UIEdgeInsetsMake(-4, 0, 4, 0)];
    }
    return self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self registerKeyboardNotifications];
    
    if (!self.isEditing) {
        [self.titleTextField becomeFirstResponder];
    }
    
    self.dateFormatter = [[NSDateFormatter alloc] init];
    self.dateFormatter.dateStyle = NSDateFormatterShortStyle;
    
    self.timeFormatter = [[NSDateFormatter alloc] init];
    self.timeFormatter.timeStyle = NSDateFormatterShortStyle;
    
    self.eventInfo = [NSMutableDictionary dictionary];
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 46.0 * self.view.frame.size.width / 320.0, 0, 0);
    [self.dateButton setContentEdgeInsets:edgeInsets];
    [self.timeButton setContentEdgeInsets:edgeInsets];
    [self.categoryButton setContentEdgeInsets:edgeInsets];
    
    if (self.isEditing) {
        self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemCancel target:self action:@selector(toggleCancel)];
        self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemEdit target:self action:@selector(toggleEdit)];
        
        NSArray *allEventKeys = self.event.allKeys;
        [allEventKeys enumerateObjectsUsingBlock:^(NSString *key, NSUInteger idx, BOOL *stop) {
            self.eventInfo[key] = self.event[key];
        }];
        
        self.titleTextField.text = self.eventInfo[@"title"];
        [self.dateButton setTitle:[self.dateFormatter stringFromDate:self.eventInfo[@"eventDate"]] forState:UIControlStateNormal];
        [self.timeButton setTitle:[self.timeFormatter stringFromDate:self.eventInfo[@"eventDate"]] forState:UIControlStateNormal];
        self.guestAmountTextField.text = [self.eventInfo[@"guestLimit"] integerValue] == 0 ? @"" : [self.eventInfo[@"guestLimit"] stringValue];
        [self.categoryButton setTitle:self.eventInfo[@"category"] forState:UIControlStateNormal];
        
        self.selectedDate = self.eventInfo[@"eventDate"];
        self.selectedTime = self.eventInfo[@"eventDate"];
        self.selectedCategory = self.eventInfo[@"category"];
    }
    
    CGFloat textFieldFontSize = 14.0;
    if (self.view.frame.size.width == 375.0) {
        textFieldFontSize = 16.0;
    }
    else if (self.view.frame.size.width == 414.0) {
        textFieldFontSize = 18.0;
    }
    [self.guestAmountTextField setFont:[UIFont fontWithName:@"OpenSans" size:textFieldFontSize]];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    if (self.isEditing) {
        [self.titleTextField becomeFirstResponder];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
    
    if ([[segue identifier] isEqualToString:@"pushCreateEventStepTwoViewController"]) {
        self.eventInfo[@"title"] = [self.titleTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.eventInfo[@"eventDate"] = [self combineEventDateAndTime];
        self.eventInfo[@"guestLimit"] = @(self.guestAmountTextField.text.integerValue);
        self.eventInfo[@"category"] = self.selectedCategory;
        
        CreateEventStepTwoViewController *createEventStepTwoVC = [segue destinationViewController];
        createEventStepTwoVC.eventInfo = self.eventInfo;
        createEventStepTwoVC.event = self.event;
        createEventStepTwoVC.isEditing = self.isEditing;
    }
}

- (IBAction)unwindToCreateEventViewController:(UIStoryboardSegue *)unwindSegue
{
    if ([[unwindSegue identifier] isEqualToString:@"unwindToCreateEventViewControllerFromCreateEventStepThreeViewController"]) {
        // reset
        self.titleTextField.text = nil;
        [self.dateButton setTitle:@"Enter Event Date" forState:UIControlStateNormal];
        [self.timeButton setTitle:@"Start Time" forState:UIControlStateNormal];
        self.guestAmountTextField.text = nil;
        [self.categoryButton setTitle:@"Choose a Category" forState:UIControlStateNormal];
        
        if (self.isEditing) {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

#pragma mark - Keyboard Notifications

- (void)registerKeyboardNotifications
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillShow:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWillHide:) name:UIKeyboardWillHideNotification object:nil];
}

- (void)keyboardWillShow:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    CGRect keyboardRect = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        // container bottom distance is ?
        if (self.isEditing) {
            contentInset.bottom = keyboardRect.size.height;
        } else {
            contentInset.bottom = keyboardRect.size.height - 49;
        }
        self.scrollView.contentInset = contentInset;
    }];
}

- (void)keyboardWillHide:(NSNotification *)notification
{
    NSDictionary *userInfo = [notification userInfo];
    NSTimeInterval duration = [[userInfo objectForKey:UIKeyboardAnimationDurationUserInfoKey] doubleValue];
    
    [UIView animateWithDuration:duration animations:^{
        UIEdgeInsets contentInset = self.scrollView.contentInset;
        contentInset.bottom = 0;
        self.scrollView.contentInset = contentInset;
    }];
}

#pragma mark - Gesture Actions

- (IBAction)tapAction:(UITapGestureRecognizer *)tapGR
{
    [self.guestAmountTextField resignFirstResponder];
}

#pragma mark - Button Actions

- (IBAction)togglePickDate:(id)sender
{
    [self.titleTextField resignFirstResponder];
    [self.guestAmountTextField resignFirstResponder];
    
    self.isPickingDate = YES;
    
    DatePickerViewController *datePickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    datePickerVC.isDateMode = YES;
    datePickerVC.delegate = self;
    
    [self.tabBarController.tabBar setHidden:YES];
    
    [self addChildViewController:datePickerVC];
    [self.view addSubview:datePickerVC.view];
    [datePickerVC didMoveToParentViewController:self];
}

- (IBAction)togglePickTime:(id)sender
{
    [self.titleTextField resignFirstResponder];
    [self.guestAmountTextField resignFirstResponder];
    
    self.isPickingDate = NO;
    
    DatePickerViewController *datePickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"DatePickerViewController"];
    datePickerVC.isDateMode = NO;
    datePickerVC.delegate = self;
    
    [self addChildViewController:datePickerVC];
    [self.view addSubview:datePickerVC.view];
    [datePickerVC didMoveToParentViewController:self];
}

- (IBAction)toggleChooseCategory:(id)sender
{
    [self.titleTextField resignFirstResponder];
    [self.guestAmountTextField resignFirstResponder];
    
    ItemPickerViewController *itemPickerVC = [self.storyboard instantiateViewControllerWithIdentifier:@"ItemPickerViewController"];
    itemPickerVC.delegate = self;
    
    [self addChildViewController:itemPickerVC];
    [self.view addSubview:itemPickerVC.view];
    [itemPickerVC didMoveToParentViewController:self];
}

- (IBAction)toggleGoToStepTwo:(id)sender
{
    if ([self validateInputData]) {
        [self performSegueWithIdentifier:@"pushCreateEventStepTwoViewController" sender:nil];
    }
}

- (void)toggleCancel
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)toggleEdit
{
    [self.titleTextField becomeFirstResponder];
}

#pragma mark - Custom Actions

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.titleTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Input Title";
    }
    else if (!self.selectedDate) {
        message = @"Please Enter Event Date";
    }
    else if (!self.selectedTime) {
        message = @"Please Enter Start Time";
    }
    else if (![self.guestAmountTextField.text isEqualToString:@""] && self.guestAmountTextField.text.integerValue == 0) {
        message = @"Guest Number is Invalid";
    }
    else if (!self.selectedCategory) {
        message = @"Please Choose a Category";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

- (NSDate *)combineEventDateAndTime
{
    NSCalendar *calendar = [NSCalendar currentCalendar];
    NSDateComponents *dateComponents = [calendar components:NSCalendarUnitMonth | NSCalendarUnitDay | NSCalendarUnitYear fromDate:self.selectedDate];
    NSDateComponents *timeComponents = [calendar components:NSCalendarUnitHour | NSCalendarUnitMinute fromDate:self.selectedTime];
    
    NSDateComponents *combineDateTimeComponents = [[NSDateComponents alloc] init];
    [combineDateTimeComponents setMonth:dateComponents.month];
    [combineDateTimeComponents setDay:dateComponents.day];
    [combineDateTimeComponents setYear:dateComponents.year];
    [combineDateTimeComponents setHour:timeComponents.hour];
    [combineDateTimeComponents setMinute:timeComponents.minute];
    
    return [calendar dateFromComponents:combineDateTimeComponents];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidBeginEditing:(UITextField *)textField
{
    if ([textField isEqual:self.guestAmountTextField]) {
        self.tapGestureContainer.hidden = NO;
    }
}

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.guestAmountTextField]) {
        self.tapGestureContainer.hidden = YES;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

#pragma mark - DatePickerViewControllerDelegate

- (void)datePickerViewController:(DatePickerViewController *)datePickerViewController didPickDate:(NSDate *)date
{
    if (self.isPickingDate) {
        self.selectedDate = date;
        [self.dateButton setTitle:[self.dateFormatter stringFromDate:date] forState:UIControlStateNormal];
    } else {
        self.selectedTime = date;
        [self.timeButton setTitle:[self.timeFormatter stringFromDate:date] forState:UIControlStateNormal];
    }
}

- (void)datePickerViewControllerDidFinish
{
    [self.tabBarController.tabBar setHidden:NO];
}

#pragma mark - ItemPickerViewControllerDelegate

- (void)itemPickerViewController:(ItemPickerViewController *)itemPickerViewController didPickItem:(NSString *)item
{
    self.selectedCategory = item;
    [self.categoryButton setTitle:item forState:UIControlStateNormal];
}

- (void)itemPickerViewControllerDidFinish
{
    [self.tabBarController.tabBar setHidden:NO];
}

@end
