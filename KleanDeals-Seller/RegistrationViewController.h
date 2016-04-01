//
//  RegistrationViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <CoreLocation/CoreLocation.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@class MBProgressHUD;

@interface RegistrationViewController : UIViewController <UITextFieldDelegate, CLLocationManagerDelegate, DataManagerDelegate>
{
    MBProgressHUD *HUD;
}


@property (weak, nonatomic) IBOutlet UITextField *mobileNumber;
@property (weak, nonatomic) IBOutlet UITextField *name;
- (IBAction)submitClicked:(id)sender;

@end
