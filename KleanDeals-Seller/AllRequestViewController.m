//
//  AllRequestViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "AllRequestViewController.h"

@interface AllRequestViewController ()
{
    NSMutableArray *allRequestData;
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
}
@end

@implementation AllRequestViewController
@synthesize allRequestCollection;

- (void)viewDidLoad
{
    [super viewDidLoad];
    isEmptyData = NO;
    allRequestData = [[NSMutableArray alloc] init];
    [allRequestCollection setDelegate:self];
    [allRequestCollection setDataSource:self];


- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = @"Loading...";
    HUD.dimBackground = YES;
    [HUD show:YES];

    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
//    NSString *phNo = [defaults objectForKey:@"phonenumber"];
    NSString *phNo = [NSString stringWithFormat:@"91%@", [defaults objectForKey:@"phonenumber"]];
    
    NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", @"2", @"usertype", @"all", @"request_status_code",nil];
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:&error];
    
    [[DataManager sharedInstance] getrequest:jsonData];
    [[DataManager sharedInstance] setDelegate:self];
}

#pragma mark - UICollectionViewDelegate

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (isEmptyData) {
        return 1;
    }
    else {
        return allRequestData.count;
    }
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *identifier = @"Cell";
    UICollectionViewCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:identifier forIndexPath:indexPath];
    
    NSMutableParagraphStyle *style =  [[NSParagraphStyle defaultParagraphStyle] mutableCopy];
    style.alignment = NSTextAlignmentJustified;
    style.firstLineHeadIndent = 10.0f;
    style.headIndent = 10.0f;
    style.tailIndent = -10.0f;
    
    UILabel *requestLabel = (UILabel *)[cell viewWithTag:100];
    UILabel *requestDescriptionLabel = (UILabel *)[cell viewWithTag:101];
    
    if (isEmptyData)
    {
        requestLabel.text = errorMessage;
    }
    else
    {
        NSDictionary *resultDict = [allRequestData objectAtIndex:indexPath.row];
        NSString *category = [resultDict objectForKey:@"category"];
        NSString *product = [resultDict objectForKey:@"product"];
        NSString *status = [resultDict objectForKey:@"status"];
        
        NSString *text = [NSString stringWithFormat:@"Request%d\n%@,\n%@", (indexPath.row)+1, category, product];
        NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:@{ NSParagraphStyleAttributeName : style}];
        requestLabel.attributedText = attrText;
        
        NSString *desc = [NSString stringWithFormat:@"Request%d Details:", (indexPath.row)+1];
        NSAttributedString *attrText2 = [[NSAttributedString alloc] initWithString:desc attributes:@{ NSParagraphStyleAttributeName : style}];
        requestDescriptionLabel.attributedText = attrText2;
        
        if ([status isEqualToString:@"complete"]) {
            requestLabel.layer.borderColor = [UIColor greenColor].CGColor;
            requestLabel.textColor = [UIColor greenColor];
            requestDescriptionLabel.layer.borderColor = [UIColor greenColor].CGColor;
            requestDescriptionLabel.textColor = [UIColor greenColor];
        }
        else if([status isEqualToString:@"rejected"]) {
            requestLabel.layer.borderColor = [UIColor redColor].CGColor;
            requestLabel.textColor = [UIColor redColor];
            requestDescriptionLabel.layer.borderColor = [UIColor redColor].CGColor;
            requestDescriptionLabel.textColor = [UIColor redColor];
        }
        else if([status isEqualToString:@"pending"]) {
            requestLabel.layer.borderColor = [UIColor blackColor].CGColor;
            requestLabel.textColor = [UIColor blackColor];
            requestDescriptionLabel.layer.borderColor = [UIColor blackColor].CGColor;
            requestDescriptionLabel.textColor = [UIColor blackColor];
        }
        
        requestLabel.layer.borderWidth = 2.0;
        requestDescriptionLabel.layer.borderWidth = 2.0;
        
//        cell.layer.borderWidth=1.0f;
//        cell.layer.borderColor=[[UIColor blackColor]CGColor];
//        requestLabel.text = [allRequestData objectAtIndex:indexPath.row];
    }
    return cell;
}

- (void) collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    if (!isEmptyData)
    {
    }
}

#pragma mark - DataManagerDelegate

- (void) gotResponseData:(NSDictionary *)items
{
    NSLog(@"Items = %@", items);
    
    @try
    {
        NSLog(@"gotResponseData in CategoryViewController and items = %@", items);
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
                [allRequestData removeAllObjects];
                allRequestData = [NSMutableArray arrayWithArray:data];
                [allRequestCollection reloadData];
                [HUD hide:YES];
            }
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
            [allRequestCollection reloadData];
        }
        else if ([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"203"]]) //Server error and exception
        {
            isEmptyData = YES;
            [HUD hide:YES];
            errorMessage = message;
            [allRequestCollection reloadData];
        }
    }
        @catch (NSException *exception)
    {
        NSLog(@"Exception Found in gotResponseData in RegisterViewController: %@", [exception description]);
    }
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





















