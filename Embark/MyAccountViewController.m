//
//  MyAccountViewController.m
//  Embark
//
//  Created by Irvin Liao on 6/21/15.
//  Copyright (c) 2015 L.S. Rothenrod, LC. All rights reserved.
//

#import "MyAccountViewController.h"

@interface MyAccountViewController ()

@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIImageView *avatarIV;
@property (weak, nonatomic) IBOutlet UITextField *emailTextField;
@property (weak, nonatomic) IBOutlet UITextField *passwordTextField;
@property (weak, nonatomic) IBOutlet UITextField *usernameTextField;

@property (strong, nonatomic) UIImage *editedAvatar;

@end

@implementation MyAccountViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    NSURL *myAvatarURL = [[[[NSFileManager defaultManager] URLsForDirectory:NSLibraryDirectory inDomains:NSUserDomainMask] lastObject] URLByAppendingPathComponent:@"myAvatar.data"];
    self.avatarIV.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:myAvatarURL]];
    
    self.emailTextField.text = [PFUser currentUser][@"emailAddress"];
    self.usernameTextField.text = [PFUser currentUser][@"nickName"];
    
    [self registerKeyboardNotifications];
}

- (void)viewDidLayoutSubviews
{
    [super viewDidLayoutSubviews];
    
    self.avatarIV.layer.borderColor = [[UIColor whiteColor] CGColor];
    self.avatarIV.layer.borderWidth = 4.0;
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
        contentInset.bottom = keyboardRect.size.height - 0;
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

#pragma mark - Button Actions

- (IBAction)toggleEditProfilePhoto:(id)sender
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

- (IBAction)toggleSave:(id)sender
{
    BOOL isEdited = NO;
    if (![[self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:[PFUser currentUser][@"emailAddress"]]) {
        [PFUser currentUser][@"emailAddress"] = [self.emailTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        isEdited = YES;
    }
    if (![[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:@""]) {
        [[PFUser currentUser] setPassword:[self.passwordTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""]];
        isEdited = YES;
    }
    if (![[self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""] isEqualToString:[PFUser currentUser][@"nickName"]]) {
        [PFUser currentUser][@"nickName"] = [self.usernameTextField.text stringByReplacingOccurrencesOfString:@" " withString:@""];
        isEdited = YES;
    }
    if (self.editedAvatar) {
        PFFile *editedAvatar = [PFFile fileWithName:@"avatar.png" data:UIImagePNGRepresentation(self.editedAvatar)];
        [PFUser currentUser][@"avatar"] = editedAvatar;
        isEdited = YES;
    }
    
    if (isEdited) {
        [self presentEmbarkHUDWithMessage:@"Updating"];
        [[PFUser currentUser] saveInBackgroundWithBlock:^(BOOL succeeded, NSError *error) {
            [self dismissEmbarkHUDViewController];
            if (error) {
                [self presentEmbarkAlertWithTitle:nil message:error.localizedDescription actionText:nil];
            }
            if (succeeded) {
                [self presentEmbarkAlertWithTitle:@"Success!" message:@"Updated" actionText:nil];
            }
        }];
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
    NSLog(@"image picker info: %@", info);
    
    if (info[@"UIImagePickerControllerEditedImage"]) {
        self.editedAvatar = [self resizeImage:info[@"UIImagePickerControllerEditedImage"] toSize:CGSizeMake(130, 130)];
        self.avatarIV.image = self.editedAvatar;
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

@end
