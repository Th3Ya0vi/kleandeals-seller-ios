//
//  OfferDetailsViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 30/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OfferDetailsViewController : UIViewController <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (weak, nonatomic) IBOutlet UITextView *offerDescription;
@property (weak, nonatomic) IBOutlet UIButton *offerPhoto;
@property (weak, nonatomic) IBOutlet UITextField *offerStartDate;
@property (weak, nonatomic) IBOutlet UITextField *offerEndDate;
@property (weak, nonatomic) IBOutlet UIButton *submitOffer;
@property (nonatomic) NSDictionary *offerDetails;
@property (nonatomic) BOOL viewOffer;

- (IBAction)submitOfferClicked:(id)sender;
- (IBAction)offerPhotoClicked:(id)sender;

@end
