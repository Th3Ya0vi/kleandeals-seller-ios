//
//  AboutUsViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "AboutUsViewController.h"

@interface AboutUsViewController ()
{
    BOOL isEmptyData;
    NSString *errorMessage;
}
@end

@implementation AboutUsViewController
@synthesize aboutUs, aboutUsTitle;

- (void)viewDidLoad {
    [super viewDidLoad];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    [[DataManager sharedInstance] about_us];
    [[DataManager sharedInstance] setDelegate:self];
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD show:YES];
}

#pragma -mark DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    NSLog(@"Items = %@", items);
    @try
    {
        NSLog(@"gotResponseData in AboutUsViewController and items = %@", items);
        NSString *status = [items valueForKey:@"status"];
        NSString *message = [items valueForKey:@"message"];
        
        if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"200"]]) // success
        {
            NSArray *data = [items valueForKey:@"data"];
            NSString *details = [[data objectAtIndex:0] objectForKey:@"details"];
            NSString *titleText = [[data objectAtIndex:0] objectForKey:@"title"];
            
            NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[details dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            aboutUs.attributedText = attributedString;
            
            NSAttributedString *attributedString1 = [[NSAttributedString alloc] initWithData:[titleText dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
            aboutUsTitle.attributedText = attributedString1;
            [HUD hide:YES];
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
        NSLog(@"Exception Found in gotResponseData in AboutUsViewController: %@", [exception description]);
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
