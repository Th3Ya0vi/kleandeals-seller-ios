//
//  ProfileViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "ProfileViewController.h"
#import "SharedDataClass.h"

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 216;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;
CGFloat animatedDistance;

@interface ProfileViewController ()
{
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
    NSString *encodedimage; // Profile Image encoded in BASE64
    NSString *requestType; // getProfile OR updateProfile
    NSString *isPhotoRemoved; // "0" or "1"
    BOOL appearFromMedia; // YES if View Appears from Media Library
    NSString *isCOD;
}
@end

@implementation ProfileViewController
@synthesize name, emailId, profilePicture, address, city, state, pincode, scroller, codbtn, phone, isFirstTimeUser, updateBtn;

- (void)viewDidLoad {
    [super viewDidLoad];
    [name setDelegate:self];
    [emailId setDelegate:self];
    [address setDelegate:self];
    [city setDelegate:self];
    [state setDelegate:self];
    [pincode setDelegate:self];
    encodedimage = @"";
    isPhotoRemoved = @"0";
    appearFromMedia = NO;
    isCOD = @"0";
    
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *phNo = [[SharedDataClass sharedInstance] getMobileNumber];
    phone.text = phNo;
    
    if (![[SharedDataClass sharedInstance] isProfileUpdated])
    {
        UITabBar *tabBar = self.tabBarController.tabBar;
        [tabBar setHidden:YES];
    }
    
    if (!appearFromMedia)
        [self serviceCallToGetProfile];
}

- (void) viewDidAppear:(BOOL)animated
{
    [profilePicture.layer setBorderColor: [[UIColor blackColor] CGColor]];
    [profilePicture.layer setBorderWidth: 1.0];
    
    [scroller setScrollEnabled:YES];
    float tabBarHeight = self.tabBarController.tabBar.frame.size.height;
    float scrollerHeight = updateBtn.frame.size.height + updateBtn.frame.origin.y + tabBarHeight + 50;
    
    [scroller setContentSize:CGSizeMake(320, scrollerHeight)];
}

- (void) openImageLibrary
{
    UIImagePickerController *imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = self;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

- (IBAction)updateButton:(id)sender
{
    appearFromMedia = NO;
    [self serviceCallToUpdateProfile];
}

- (IBAction)cancelButton:(id)sender {
}

- (IBAction)editbutton:(id)sender
{
    appearFromMedia = YES;
    [self openImageLibrary];
}

- (IBAction)removeButton:(id)sender
{
    profilePicture.image = [UIImage imageNamed:@"profile-picture.png"];
    isPhotoRemoved = @"1";
}

- (IBAction)CODButton:(id)sender
{
    isCOD = [isCOD isEqualToString:@"0"] ? @"1" : @"0";
    [self setCODButtonImage];
}

- (void) setCODButtonImage
{
    if ([isCOD isEqualToString:@"1"])
    {
        UIImage *btnImage = [UIImage imageNamed:@"check.png"];
        [codbtn setImage:btnImage forState:UIControlStateNormal];
    }
    else
    {
        UIImage *btnImage = [UIImage imageNamed:@"uncheck.png"];
        [codbtn setImage:btnImage forState:UIControlStateNormal];
    }
}

#pragma mark - DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    NSLog(@"Items = %@", items);
    @try
    {
        NSLog(@"gotResponseData in ProfileViewController and items = %@", items);
        NSString *status = [items valueForKey:@"status"];
        NSString *message = [items valueForKey:@"message"];
        
        if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"200"]]) // success
        {
            NSArray *data = [items valueForKey:@"data"];
            if ([requestType isEqualToString:@"getProfile"])
            {
                if ([data isKindOfClass:[NSNull class]]) // Array is NULL
                {
                    isEmptyData = YES;
                    [HUD hide:YES];
                    errorMessage = @"Error while getting data. Please try again after sometime.";
                }
                else if(data.count == 0) // Array is Empty
                {
                    isEmptyData = YES;
                    errorMessage = @"No data found for your query. Try something else.";
                    [HUD hide:YES];
                }
                else
                {
                    errorMessage = @"";
                    isEmptyData = NO;
                    
                    NSDictionary *userDetails = [data objectAtIndex:0];
                    NSString *pictureStr = [userDetails objectForKey:@"profilepic"];
                    NSString *codStatus = [userDetails objectForKey:@"cod"];
                    if ([pictureStr length] == 0) {
                            profilePicture.image = [UIImage imageNamed:@"profile-picture.png"];
                    }
                    else {
                        NSURL *picURL = [NSURL URLWithString:pictureStr];
                        profilePicture.image = [UIImage imageWithData:[NSData dataWithContentsOfURL:picURL]];
                    }
                    
                    name.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"name"]];
                    emailId.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"emailid"]];
                    address.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"addressline1"]];
                    city.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"city"]];
                    state.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"state"]];
                    pincode.text = [[SharedDataClass sharedInstance] returnBlankIfNull:[userDetails objectForKey:@"zipcode"]];
                    
                    isCOD = [codStatus isEqualToString:@"0"] ? @"0" : @"1";
                    
                    [self setCODButtonImage];

                    [HUD hide:YES];
                }
            }
            else if ([requestType isEqualToString:@"updateProfile"])
            {
                [HUD hide:YES];
                NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
                NSString *firstTime = [defaults objectForKey:@"isFirstTimeUser"];
                
                if ([firstTime isEqualToString:@"YES"])
                {
                    NSUserDefaults *defaults1 = [NSUserDefaults standardUserDefaults];
                    [defaults1 setObject:@"NO" forKey:@"isFirstTimeUser"];
                    [defaults1 synchronize];
                    
                    UITabBar *tabBar = self.tabBarController.tabBar;
                    [tabBar setHidden:NO];
                    [self.tabBarController setSelectedIndex:0];
                }
                else
                    [self showAlertforTitle:@"Profile Updated" Messsage: @"Profile Photo Updated Successfully"];
            }
            
        }
        else if([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"201"]]) // validation Error
        {
            [self showAlertforTitle:@"Validation Error" Messsage:message];
            [HUD hide:YES];
        }
        else if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"202"]]) // Bad request type
        {
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = @"Error while getting data. Please try again after sometime.";
        }
        else if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"203"]]) //Server error and exception
        {
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = message;
        }
    }
    @catch (NSException *exception)
    {
        [self showAlertforTitle:@"Internal error" Messsage:@"Please try after some time"];
        NSLog(@"Exception Found in gotResponseData in ProfileViewController: %@", [exception description]);
    }
}

- (void) hideLoader
{
    [HUD hide:YES];
}

#pragma mark - Show Alert
- (void) showAlertforTitle:(NSString *)title Messsage:(NSString *) msg
{
    UIAlertView *errorAlert = [[UIAlertView alloc]
                               initWithTitle:title message:msg delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil];
    [errorAlert show];
    [HUD hide:YES];
}

#pragma mark - TextField Delegate

-(BOOL) textFieldShouldBeginEditing:(UITextField*)textField
{
    CGRect textFieldRect = [self.view.window convertRect:textField.bounds fromView:textField];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textFieldRect.origin.y + 0.5 * textFieldRect.size.height;
    CGFloat numerator =  midline - viewRect.origin.y  - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

- (BOOL) textFieldShouldEndEditing:(UITextField*)textField
{
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

#pragma mark - ImagePicker Delegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    [profilePicture setImage:pickedImage];
    
    NSData * data = [UIImagePNGRepresentation(pickedImage) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedimage = [NSString stringWithUTF8String:[data bytes]];
    encodedimage = [encodedimage stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    encodedimage = [encodedimage stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
@end





















