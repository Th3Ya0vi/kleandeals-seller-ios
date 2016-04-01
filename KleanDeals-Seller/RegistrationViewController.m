//
//  RegistrationViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "RegistrationViewController.h"
#import "VerificationViewController.h"
#import "MBProgressHUD.h"
#import "ProfileViewController.h"

@interface RegistrationViewController ()

@end

@implementation RegistrationViewController
@synthesize mobileNumber, name;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.mobileNumber.delegate = self;
    name.delegate = self;
    [self.navigationItem setHidesBackButton:YES animated:YES];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
}

- (IBAction)submitClicked:(id)sender
{
        UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarView"];
        tbc.selectedIndex=3;
        [self presentViewController:tbc animated:YES completion:nil];
}

- (BOOL) checkMobileNumber
{
    NSString *number = [mobileNumber text];
    
    NSString *numberRegEx = @"[0-9]{10}";
    NSPredicate *numberTest = [NSPredicate predicateWithFormat:@"SELF MATCHES %@", numberRegEx];
    
    if ([numberTest evaluateWithObject:number] == YES)
        return YES;
    else
    {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Invalid Phone Number" message:@"Please provide a phone number of 10 digits" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
}

- (BOOL) checkUserName
{
    if ([name text].length == 0)
    {
        UIAlertView *alert;
        alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Please provide your Name" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return  NO;
    }
    else
    {
        return  YES;
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"verificationSegue"])
    {
        VerificationViewController *controller = (VerificationViewController *)segue.destinationViewController;
        controller.mobileNumberStr = mobileNumber.text;
    }
}

#pragma mark - TextField Delegate
- (BOOL)textFieldShouldReturn:(UITextField *)theTextField {
    NSLog(@"textfied = %@", theTextField);
    [theTextField resignFirstResponder];
    return YES;
}

#pragma mark - DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    NSLog(@"%@",items);
    @try {
        NSLog(@"IN gotResponseData in RegisterViewController");
        
        NSString *status = [items valueForKey:@"status"];
        NSString *message = [items valueForKey:@"message"];
        
        if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"200"]])
        {
            // success
            NSArray *data = [items valueForKey:@"data"];
            if ([data isKindOfClass:[NSNull class]]) // Array is NULL
            {
                [self showAlertforTitle:@"Server Error" Messsage:@"Error while getting data. Please try again after sometime."];
            }
         
    {
        NSLog(@"Exception Found in gotResponseData in RegisterViewController: %@", [exception description]);
        [HUD hide:YES];
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
@end





















