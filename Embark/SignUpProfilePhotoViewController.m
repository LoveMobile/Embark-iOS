//
//  SignUpProfilePhotoViewController.m
//  Embark
//
//  Created by Irvin Liao on 4/27/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "SignUpProfilePhotoViewController.h"

@interface SignUpProfilePhotoViewController ()

@property (weak, nonatomic) IBOutlet UILabel *createProfilePictureLabel;
@property (weak, nonatomic) IBOutlet UIButton *addProfilePhotoButton;
@property (weak, nonatomic) IBOutlet UIView *profileContainer;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;

@property (strong, nonatomic) UIImage *avatarImage;

@end

@implementation SignUpProfilePhotoViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSLog(@"signup userinfo: %@", self.signUpUserInfo);
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    self.avatarIV.layer.borderWidth = 4.0;
    self.avatarIV.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.avatarIV.layer.cornerRadius = self.avatarIV.frame.size.width / 2;
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

- (IBAction)toggleAddProfilePhoto:(id)sender
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

- (IBAction)toggleChangeMyProfilePhoto:(id)sender
{
    [self toggleAddProfilePhoto:sender];
}

- (IBAction)toggleCompleteRegistration:(id)sender
{
    [self presentEmbarkHUDWithMessage:@"Complete Registration"];
    
    [self performSignUp];
}

#pragma mark - Custom Actions

- (void)performSignUp
{
    PFUser *user = [PFUser user];
    user.username = self.signUpUserInfo[@"email"];
    user.password = self.signUpUserInfo[@"password"];
    user.email = self.signUpUserInfo[@"email"];
    
    user[@"emailAddress"] = self.signUpUserInfo[@"email"];
    
    user[@"nickName"] = self.signUpUserInfo[@"username"];
    
    PFFile *avatar = [PFFile fileWithName:@"avatar.png" data:UIImagePNGRepresentation(self.avatarImage)];
    user[@"avatar"] = avatar;
    
    [user signUpInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
        [self dismissEmbarkHUDViewController];
        if (error) {
            NSString *message;
            if ([[error userInfo][@"code"] integerValue] == 202) {
                message = @"Email address is already taken.";
            } else {
                message = [error userInfo][@"error"];
            }
            [self presentEmbarkAlertWithTitle:nil message:message actionText:nil];
        } else {
            [self presentEmbarkAlertWithTitle:@"Success!" message:@"Signed Up" actionText:nil];
        }
    }];
}

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
    // 130:130
//    UIGraphicsBeginImageContextWithOptions(toSize, NO, 0);
//    [image drawInRect:CGRectMake(0, 0, toSize.width, toSize.height)];
    
    // max 130:130 @3x
    CGSize maxSize = CGSizeMake(390.0, 390.0);
    UIGraphicsBeginImageContext(maxSize);
    [image drawInRect:CGRectMake(0, 0, maxSize.width, maxSize.height)];
    UIImage *resizeImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resizeImage;
}

#pragma mark - UIImagePickerControllerDelegate

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    self.createProfilePictureLabel.hidden = YES;
    self.addProfilePhotoButton.hidden = YES;
    self.profileContainer.hidden = NO;
    
    NSLog(@"image picker info: %@", info);
    
    if (info[@"UIImagePickerControllerEditedImage"]) {
        self.avatarImage = [self resizeImage:info[@"UIImagePickerControllerEditedImage"] toSize:CGSizeMake(130, 130)];
        self.avatarIV.image = self.avatarImage;
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

#pragma mark - EmbarkAlertViewControllerDelegate

- (void)embarkAlertViewControllerDidDismiss
{
    [super embarkAlertViewControllerDidDismiss];
    
    [self performSegueWithIdentifier:@"unwindToSignUpViewControllerFromSignUpProfilePhotoViewController" sender:nil];
}

@end
