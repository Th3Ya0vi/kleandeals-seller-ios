//
//  NotificationViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 06/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "NotificationViewController.h"
#import "SharedDataClass.h"
#import "RequestDetailViewController.h"

@interface NotificationViewController ()
{
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
    NSArray *notificationData;
    NSDictionary *requestData;
    NSString *whichAPICall; //  getNotificationList OR setNotificationStatus OR getrequest
    NSString *selectedNotificationId;
}
@end

@implementation NotificationViewController
@synthesize notificationList;

- (void)viewDidLoad {
    [super viewDidLoad];
    notificationList.dataSource = self;
    notificationList.delegate = self;
    notificationList.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [notificationList setSeparatorColor:[UIColor whiteColor]];

    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]]];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    NSString *phNo = [[SharedDataClass sharedInstance] getMobileNumber];
    
    NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", kSellerID, @"usertype", nil];
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:nil];
    
    whichAPICall = @"getNotificationList";
    [[DataManager sharedInstance] getNotificationList:jsonData];
    [[DataManager sharedInstance] setDelegate:self];
    
    [self showLoaderWithText:@"Loading..."];
}

- (void) showLoaderWithText: (NSString *)text
{
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = text;
    HUD.dimBackground = YES;
    [HUD show:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if([segue.identifier isEqualToString:@"notificationToRequestDetail"])
    {
        RequestDetailViewController *requestDetailVC = (RequestDetailViewController *)segue.destinationViewController;
        NSDictionary *resultDict = requestData;
        requestDetailVC.requestDetailDict = [resultDict mutableCopy];
    }
}

- (void) updateNotificationCount
{
    NSString *count = [[SharedDataClass sharedInstance] getNotificationCount];
    [[[[[self tabBarController] tabBar] items] objectAtIndex:1] setBadgeValue:count];
}

#pragma mark - UITableView Delegate

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (notificationData.count == 0)
    {
        isEmptyData = YES;
        return 1;
    }
    else
    {
        isEmptyData = NO;
        return notificationData.count;
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *cellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:cellIdentifier];
    }
    
    cell.textLabel.font = [UIFont systemFontOfSize:kSmallFont];
    cell.textLabel.textColor = [UIColor whiteColor];
    cell.backgroundColor = [UIColor clearColor];
    
    @try
    {
        if (isEmptyData)
            cell.textLabel.text = @"No new notification";
        else
        {
            NSDictionary *notyDict = [notificationData objectAtIndex:indexPath.row];
            cell.textLabel.text = [notyDict objectForKey:@"notificationtext"];
        }
    }
    @catch (NSException *exception)
    {
        cell.textLabel.text = @"Server Error. Please try again.";
        NSLog(@"Exception found in %s: %@", __PRETTY_FUNCTION__, [exception description]);
    }
    return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [self showLoaderWithText:@"Loading..."];
    whichAPICall = @"getrequest";
    NSString *phNo = [[SharedDataClass sharedInstance] getMobileNumber];
    NSDictionary *notyDict = [notificationData objectAtIndex:indexPath.row];
    NSString *requestid = [notyDict objectForKey:@"requestid"];
    selectedNotificationId = [notyDict objectForKey:@"id"];

//    NSString *requestid = @"2";
    
    NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", requestid, @"requestid", nil];
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:&error];
    
    [[DataManager sharedInstance] getrequest:jsonData];
    [[DataManager sharedInstance] setDelegate:self];
}


#pragma mark - DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    [self hideLoader];
    @try
    {
        NSLog(@"%s and items = %@", __PRETTY_FUNCTION__, items);
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
                if ([whichAPICall isEqualToString:@"getNotificationList"])
                {
                    notificationData = data;
                    NSString *notyCount = [NSString stringWithFormat:@"%lu", (unsigned long)[notificationData count]];
                    [[SharedDataClass sharedInstance] updateNotyCountToValue: notyCount];
                    [self updateNotificationCount];
//                    [notificationList reloadData];
                }
                else if ([whichAPICall isEqualToString:@"getrequest"])
                {
                    // Change Read Status to 1
                    NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: selectedNotificationId, @"notification_id", nil];
                    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:nil];
                }
            }
        }
        else if([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"201"]]) // validation Error
        {
            isEmptyData = YES;
            errorMessage = message;
            [self showAlertforTitle:@"Validation Error" Messsage:message];
        }
        else if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"202"]]) // Bad request type
        {
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = message;
        }
        else if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"203"]]) //Server error and exception
        {
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = message;
        }
        else
        {
            [self showAlertforTitle:@"Server Error" Messsage:@"Error while getting data. Please try again after sometime."];
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = @"Error while getting data. Please try again after sometime.";
        }
    }
    @catch (NSException *exception)
    {
        [HUD hide:YES];
        [self showAlertforTitle:@"Internal error" Messsage:@"Please try after some time"];
        NSLog(@"Exception Found in %s %@", __PRETTY_FUNCTION__, [exception description]);
    }
    @finally
    {
        if ([whichAPICall isEqualToString:@"getNotificationList"])
            [notificationList reloadData];
        if ([whichAPICall isEqualToString:@"getrequest"] && isEmptyData)
            [self showAlertforTitle:@"Error" Messsage:errorMessage];
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
