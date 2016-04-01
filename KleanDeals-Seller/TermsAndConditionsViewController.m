//
//  TermsAndConditionsViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 08/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "TermsAndConditionsViewController.h"

@interface TermsAndConditionsViewController ()
{
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
}
@end

@implementation TermsAndConditionsViewController
@synthesize termAndConditionTextView;

- (void)viewDidLoad {
    [super viewDidLoad];

    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD show:YES];

    [[DataManager sharedInstance] termsAndCondition];
    [[DataManager sharedInstance] setDelegate:self];
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
                
                NSString *htmlString = [[data objectAtIndex:0] objectForKey:@"description"];
                NSAttributedString *attributedString = [[NSAttributedString alloc] initWithData:[htmlString dataUsingEncoding:NSUnicodeStringEncoding] options:@{ NSDocumentTypeDocumentAttribute: NSHTMLTextDocumentType } documentAttributes:nil error:nil];
                termAndConditionTextView.attributedText = attributedString;
                
                [HUD hide:YES];
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
@end
