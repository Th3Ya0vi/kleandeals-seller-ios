//
//  RespondToRequestViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "RespondToRequestViewController.h"

@interface RespondToRequestViewController ()

@end

@implementation RespondToRequestViewController
@synthesize requestDetail, responseMessage;

- (void)viewDidLoad {
    [super viewDidLoad];
    
}

- (IBAction)submitButton:(id)sender {
}

- (IBAction)resetbutton:(id)sender {
}

- (IBAction)submit:(id)sender {
}

- (void) gotResponseData:(NSDictionary *)items
{
    
}

- (void) hideLoader
{
    [HUD hide:YES];
}
@end
