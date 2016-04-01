//
//  ContactUsViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "ContactUsViewController.h"

@interface ContactUsViewController ()
{
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
}
@end

@implementation ContactUsViewController
@synthesize comment, subject;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    comment.layer.borderColor = [UIColor blackColor].CGColor;
    comment.layer.borderWidth = 1.0;
    
    comment.text = @"Enter your comments...";
    [comment setDelegate:self];
    comment.textColor = [UIColor lightGrayColor];
    
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]]];
}

- (IBAction)sendButton:(id)sender
{
    if ([self validateComments])
    {
        NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
        NSString *phNo = [defaults objectForKey:@"phonenumber"];
        //    NSString *phNo = [NSString stringWithFormat:@"91%@", [defaults objectForKey:@"phonenumber"]];
        
        NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", @"2", @"usertype", subject.text, @"subject", comment.text, @"description", nil];
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:&error];

        
        [[DataManager sharedInstance] contactKleanDeals:jsonData];
        [[DataManager sharedInstance] setDelegate:self];
    }
}

- (BOOL) validateComments
{
    NSString *comm = comment.text;
    NSString *description = [comm stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    NSString *sub = subject.text;
    NSString *subj = [sub stringByReplacingOccurrencesOfString:@" " withString:@""];
    
    if (([description length] == 0) || [description isEqualToString:@"Enter your comments..."]) {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Comment cannot be blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else if([subj length] == 0)
    {
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Error" message:@"Subject cannot be blank" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil, nil];
        [alert show];
        return NO;
    }
    else
    {
        return YES;
    }
}

#pragma mark - DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    NSLog(@"Items = %@", items);
    
    @try
    {
        NSLog(@"gotResponseData in ContactUsViewController and items = %@", items);
        NSString *status = [items valueForKey:@"status"];
        NSString *message = [items valueForKey:@"message"];
        
        if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"200"]]) // success
        {
            [self showAlertforTitle:@"Success" Messsage:@"Thanks for your valuable Comments."];
            
            subject.text = @"";
            comment.text = @"Enter your comments...";
            comment.textColor = [UIColor lightGrayColor];
            
        }
        else if([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"201"]]) // validation Error
        {
            [self showAlertforTitle:@"Validation Error" Messsage:message];
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
        NSLog(@"Exception Found in gotResponseData in ContactUsViewController: %@", [exception description]);
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

#pragma mark - TextView Delegate

- (void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter your comments..."]) {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    [textView becomeFirstResponder];
}

- (void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter your comments...";
        textView.textColor = [UIColor lightGrayColor];
    }
    [textView resignFirstResponder];
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}

#pragma mark - TextField Delegate

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
@end





















