//
//  ContactUsViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"
@class MBProgressHUD;

@interface ContactUsViewController : UIViewController <DataManagerDelegate, UITextViewDelegate>
{
    MBProgressHUD *HUD;
}
@property (weak, nonatomic) IBOutlet UITextField *subject;
@property (weak, nonatomic) IBOutlet UITextView *comment;
- (IBAction)sendButton:(id)sender;


@end
