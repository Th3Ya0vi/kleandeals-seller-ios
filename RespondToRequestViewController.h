//
//  RespondToRequestViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@class MBProgressHUD;

@interface RespondToRequestViewController : UIViewController <DataManagerDelegate>
{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UILabel *requestDetail;
@property (weak, nonatomic) IBOutlet UITextView *responseMessage;

- (IBAction)submitButton:(id)sender;
- (IBAction)resetbutton:(id)sender;

@end
