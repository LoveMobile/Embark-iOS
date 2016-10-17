//
//  CreateEventStepTwoViewController.m
//  Embark
//
//  Created by Irvin Liao on 5/28/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "CreateEventStepTwoViewController.h"
#import "CreateEventStepThreeViewController.h"

@interface CreateEventStepTwoViewController ()

@property (weak, nonatomic) IBOutlet UITextField *locationNameTextField;
@property (weak, nonatomic) IBOutlet UITextField *addressTextField;
@property (weak, nonatomic) IBOutlet UIButton *addPhotoButton;
@property (weak, nonatomic) IBOutlet UIImageView *photoIV;

@property (strong, nonatomic) CLLocation *geocodeAddressLocation;
@property (strong, nonatomic) UIImage *selectedImage;

@end

@implementation CreateEventStepTwoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    [self.locationNameTextField becomeFirstResponder];
    
    UIEdgeInsets edgeInsets = UIEdgeInsetsMake(0, 52.0 * self.view.frame.size.width / 320.0, 0, 0);
    [self.addPhotoButton setContentEdgeInsets:edgeInsets];
    
    if (self.isEditing) {
        self.locationNameTextField.text = self.eventInfo[@"locationName"];
        self.addressTextField.text = self.eventInfo[@"locationAddress"];
        PFGeoPoint *geoPoint = self.eventInfo[@"location"];
        self.geocodeAddressLocation = [[CLLocation alloc] initWithLatitude:geoPoint.latitude longitude:geoPoint.longitude];
        PFFile *photoFile = self.eventInfo[@"photo"];
        [photoFile getDataInBackgroundWithBlock:^(NSData *data, NSError *error) {
            if (error) {
                [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
            } else {
                UIImage *photo = [UIImage imageWithData:data];
                if (photo) {
                    self.selectedImage = photo;
                    self.photoIV.image = photo;
                }
            }
        }];
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
    
    if ([[segue identifier] isEqualToString:@"pushCreateEventStepThreeViewController"]) {
        self.eventInfo[@"locationName"] = [self.locationNameTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.eventInfo[@"locationAddress"] = [self.addressTextField.text stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        self.eventInfo[@"location"] = self.geocodeAddressLocation;
        self.eventInfo[@"photo"] = self.selectedImage;
        
        CreateEventStepThreeViewController *createEventStepThreeVC = [segue destinationViewController];
        createEventStepThreeVC.eventInfo = self.eventInfo;
        createEventStepThreeVC.event = self.event;
        createEventStepThreeVC.isEditing = self.isEditing;
    }
}

#pragma mark - Button Actions

- (IBAction)toggleAddPhoto:(id)sender
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
    [alert addAction:[UIAlertAction actionWithTitle:@"Choose from library" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self toggleChooseFromPhotoLibrary];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Take photograph" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        [self toggleTakePhotograph];
    }]];
    [alert addAction:[UIAlertAction actionWithTitle:@"Cancel" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
    }]];
    
    [self presentViewController:alert animated:YES completion:nil];
}

- (IBAction)toggleProceed:(id)sender
{
    if ([self validateInputData]) {
        [self performSegueWithIdentifier:@"pushCreateEventStepThreeViewController" sender:nil];
    }
}

#pragma mark - Custom Actions

- (void)toggleChooseFromPhotoLibrary
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypePhotoLibrary]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (void)toggleTakePhotograph
{
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIImagePickerController *imagePicker = [[UIImagePickerController alloc] init];
        imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        imagePicker.allowsEditing = YES;
        imagePicker.delegate = self;
        
        [self presentViewController:imagePicker animated:YES completion:nil];
    }
}

- (UIImage *)resizeImage:(UIImage *)image toSize:(CGSize)toSize
{
    // max 414:414 @3x
    CGSize maxSize = CGSizeMake(1242, 1242);
    UIGraphicsBeginImageContext(maxSize);
    [image drawInRect:CGRectMake(0, 0, maxSize.width, maxSize.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizeImage;
}

- (BOOL)validateInputData
{
    NSString *message = @"";
    if ([[self.locationNameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Input Location Name";
    }
    else if ([[self.addressTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        message = @"Please Enter The Address";
    }
    else if (!self.geocodeAddressLocation) {
        message = @"The address is not valid.";
    }
    
    if (![message isEqualToString:@""]) {
        [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        
        return NO;
    }
    
    return YES;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"image picker info: %@", info);
    
    if (info[@"UIImagePickerControllerEditedImage"]) {
        self.selectedImage = [self resizeImage:info[@"UIImagePickerControllerEditedImage"] toSize:CGSizeMake(1242.0, 1242.0)];
        self.photoIV.image = self.selectedImage;
    }
    /*
     if (info[@"UIImagePickerControllerOriginalImage"]) {
     
     }
     */
    [picker dismissViewControllerAnimated:YES completion:nil];
}

- (void)imagePickerControllerDidCancel:(UIImagePickerController *)picker
{
    [picker dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - UITextFieldDelegate

- (void)textFieldDidEndEditing:(UITextField *)textField
{
    if ([textField isEqual:self.addressTextField]) {
        if (![[self.addressTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
            CLGeocoder *geocoder = [[CLGeocoder alloc] init];
            [geocoder geocodeAddressString:self.addressTextField.text completionHandler:^(NSArray *placemarks, NSError *error) {
                if (!error) {
                    CLPlacemark *placeMark = [placemarks firstObject];
                    NSLog(@"placemark name: %@", placeMark.name);
                    NSLog(@"placemark location: %@", placeMark.location);
                    self.geocodeAddressLocation = placeMark.location;
                } else {
                    NSLog(@"geocode address error: %@", [error localizedDescription]);
                }
            }];
        }
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    return YES;
}

@end
