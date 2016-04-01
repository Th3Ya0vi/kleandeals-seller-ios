//
//  ProfileViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@class MBProgressHUD;

@interface ProfileViewController : UIViewController <DataManagerDelegate, UITextFieldDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate>
{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UIImageView *profilePicture;
@property (weak, nonatomic) IBOutlet UITextField *phone;
@property (weak, nonatomic) IBOutlet UITextField *name;
@property (weak, nonatomic) IBOutlet UITextField *emailId;
@property (weak, nonatomic) IBOutlet UITextField *address;
@property (weak, nonatomic) IBOutlet UITextField *city;
@property (weak, nonatomic) IBOutlet UITextField *state;
@property (weak, nonatomic) IBOutlet UITextField *pincode;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;
@property (weak, nonatomic) IBOutlet UIButton *codbtn;
@property (weak, nonatomic) IBOutlet UIButton *updateBtn;
@property (nonatomic) BOOL isFirstTimeUser;
@property (strong, nonatomic) NSString *firstTime;

- (IBAction)updateButton:(id)sender;
- (IBAction)cancelButton:(id)sender;
- (IBAction)editbutton:(id)sender;
- (IBAction)removeButton:(id)sender;
- (IBAction)CODButton:(id)sender;


@end
