//
//  RequestDetailViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "RequestDetailViewController.h"
#import "SharedDataClass.h"

#define kOriginXaxis 15
#define kOriginYaxis 10
#define kFrameWidth 285
#define kNumberOfTruncatedComments 2

static const CGFloat KEYBOARD_ANIMATION_DURATION = 0.3;
static const CGFloat MINIMUM_SCROLL_FRACTION = 0.2;
static const CGFloat MAXIMUM_SCROLL_FRACTION = 0.8;
static const CGFloat PORTRAIT_KEYBOARD_HEIGHT = 200;
static const CGFloat LANDSCAPE_KEYBOARD_HEIGHT = 162;

CGFloat animatedDistance;

@interface RequestDetailViewController () <UIActionSheetDelegate>
{
    NSString *requestId;
    NSMutableArray *requestData;
    BOOL isEmptyData;
    NSString *errorMessage; // If Collection data is nil or blank
    
    NSMutableParagraphStyle *style;
    
    UILabel *requestHeader;
    UITextView *requestDescription;
    UIBarButtonItem *currentRequestStatus;
    
    UIView *commentsSection;
    
    UIView *respondView;
    UITextView *commentTextView;
    NSString *whichAPICall; // changeRequestStatus OR replyTorequest
    
    NSArray *nextStatusArray;
    NSArray *commentsArray;
    
    UITableView *requestDescriptionTableView;
    float requestDescriptionTableHeight;
    BOOL isFilterData;
    
    UITableView *commentsTableView;
    float commentsTableHeight;
    int totalCommentTableRows;
    BOOL isComments;
    BOOL isTruncateComments;
    
    BOOL isCommentTableGenerated;
    
    // Bottom Buttons
    UIView *bottomButtonsView;
    UIButton *respondButton;
    UIButton *cancelCommentButton;
    UIButton *submitCommentButton;
    UIButton *rejectButton;
}
@end

@implementation RequestDetailViewController
@synthesize requestDetailDict, scroller;

- (void)viewDidLoad {
    [super viewDidLoad];
    
    isComments = NO;
    isFilterData = NO;
    isCommentTableGenerated = NO;
    isTruncateComments = YES;
    requestDescriptionTableHeight = 0.0;
    commentsTableHeight = 0.0;
    whichAPICall = @"";
    
    requestId = [requestDetailDict objectForKey:@"request_id"];
    commentsArray = [requestDetailDict objectForKey:@"comments"];
    nextStatusArray = [requestDetailDict objectForKey:@"next_status"];
    
    [scroller setScrollEnabled:YES];
    [scroller setContentSize:CGSizeMake(320, 800)];
    
    [self addStyle];
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    //    [self generateView];
//    [self generateRequestDetailsView];
//    [self generateRespondView];
//    [self generateCommentView];
}

- (void) viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
//    for (UIView* view in self.view.subviews)
//    {
//        [view removeFromSuperview];
//    }

    currentRequestStatus = [[UIBarButtonItem alloc] initWithTitle:[requestDetailDict objectForKey:@"current_req_status_title"] style:UIBarButtonItemStylePlain target:self action:@selector(changeStatus:)];

    self.navigationItem.rightBarButtonItem = currentRequestStatus;
    self.navigationItem.rightBarButtonItem.tintColor = [UIColor whiteColor];
    
    [self generateRequestHeaderView];
    [self generateRequestDetailsView];
    [self generateRespondView];
    [self generateCommentView];
}

- (void) generateView
{
    // Donot change the sequence of the function calls as labels etc are generated dynamically
    requestDescriptionTableHeight = 0;
    [self generateRequestHeaderView];
    [self generateRequestDetailsView];
    [self generateRespondView];
    [self generateCommentView];
    
    //    [self generateBottomView];
}

- (void) generateRequestHeaderView
{
    requestHeader = [[UILabel alloc] initWithFrame: CGRectMake(kOriginXaxis, kOriginYaxis, kFrameWidth, 80)];
    requestHeader.textColor = [UIColor whiteColor];
    
    requestHeader.numberOfLines = 0;
    requestHeader.lineBreakMode = NSLineBreakByWordWrapping;
    
    NSString *buyerName = [requestDetailDict objectForKey:@"buyer_name"];
    NSString *product = [requestDetailDict objectForKey:@"product_name"];
    
    NSString *text = [NSString stringWithFormat:@"%@ is looking for %@", buyerName, product];
    
    //    NSAttributedString *attrText = [[NSAttributedString alloc] initWithString:text attributes:@{ NSParagraphStyleAttributeName : style}];
    //    requestHeader.attributedText = attrText;
    
    requestHeader.text = text;
    [requestHeader setFont:[UIFont boldSystemFontOfSize:kMediumFont]];
    
    CGSize maximumLabelSize = CGSizeMake(kFrameWidth,CGFLOAT_MAX);
    CGSize requiredSize = [requestHeader sizeThatFits:maximumLabelSize];
    CGRect labelFrame = requestHeader.frame;
    labelFrame.size.height = requiredSize.height;
    requestHeader.frame = labelFrame;
    
    //    [self.view addSubview:requestHeader];
    [scroller addSubview:requestHeader];
}

- (void) generateRequestDetailsView
{
    float yAxisMargin = kOriginYaxis + requestHeader.frame.size.height + 5;
    
    //    requestDescription = [[UITextView alloc] initWithFrame:CGRectMake(kOriginXaxis, yAxisMargin, kFrameWidth, 80)];
    //    requestDescription.layer.borderColor = [UIColor blackColor].CGColor;
    //    requestDescription.layer.borderWidth = 1.0;
    //    [requestDescription setEditable:NO];
    //
    //    NSString *buyerName = [requestDetailDict objectForKey:@"buyer_name"];
    //    NSString *product = [requestDetailDict objectForKey:@"product_name"];
    //    NSString *category = [requestDetailDict objectForKey:@"category_name"];
    //
    //    NSString *text = [NSString stringWithFormat:@"Buyer Name: %@\nProduct: %@\nCategory: %@", buyerName, product, category];
    //    requestDescription.text = text;
    //
    //    CGSize maximumLabelSize = CGSizeMake(kFrameWidth,CGFLOAT_MAX);
    //    CGSize requiredSize = [requestDescription sizeThatFits:maximumLabelSize];
    //    CGRect labelFrame = requestDescription.frame;
    //    labelFrame.size.height = requiredSize.height;
    //    requestDescription.frame = labelFrame;
    //    [self.view addSubview:requestDescription];
    
    requestDescriptionTableView = [[UITableView alloc] initWithFrame:CGRectMake(kOriginXaxis-5, yAxisMargin, kFrameWidth+10, 100)];
    requestDescriptionTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    [requestDescriptionTableView setDelegate:self];
    [requestDescriptionTableView setDataSource:self];
    requestDescriptionTableView.layer.borderColor = [UIColor blackColor].CGColor;
    requestDescriptionTableView.layer.borderWidth = 1.0;
    //    requestDescriptionTableView.separatorStyle = UITableViewCellSeparatorStyleNone;
    requestDescriptionTableView.backgroundColor = [UIColor clearColor];
    
    [scroller addSubview:requestDescriptionTableView];
    //    [self.view addSubview:requestDescriptionTableView];
}

- (void) generateRespondView
{
    float yAxisMargin = requestDescriptionTableView.frame.origin.y + requestDescriptionTableView.frame.size.height + 5;
    
    respondView = [[UIView alloc] initWithFrame:CGRectMake(kOriginXaxis-5, yAxisMargin, kFrameWidth+10, 60)];
    
    commentTextView = [[UITextView alloc] initWithFrame:CGRectMake(0, 0, kFrameWidth-50, 60)];
    commentTextView.layer.borderColor = [UIColor blackColor].CGColor;
    commentTextView.layer.borderWidth = 1.0;
    commentTextView.font = [UIFont systemFontOfSize:13];
    commentTextView.returnKeyType = UIReturnKeyDone;
    [commentTextView setDelegate:self];
    [self initializeRespondViewText];
    
    // Create Submit Comment Button
    float Xoffset = 5;
    float buttonXorigin = commentTextView.frame.size.width+Xoffset;
    float buttonHeight = 25;
    float buttonWidth = respondView.frame.size.width - commentTextView.frame.size.width - Xoffset;
    
    submitCommentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitCommentButton.frame = CGRectMake(buttonXorigin, respondView.frame.size.height-buttonHeight, buttonWidth, buttonHeight);
    submitCommentButton.backgroundColor = [UIColor colorWithRed:(241/255.0) green:(92/255.0) blue:(36/255.0) alpha:1] ;
    [submitCommentButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [submitCommentButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitCommentButton addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create Reject Button
    rejectButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    rejectButton.frame = CGRectMake(buttonXorigin, 5, buttonWidth, buttonHeight);
    rejectButton.backgroundColor = [UIColor grayColor];
    [rejectButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [rejectButton setTitle:@"Reject" forState:UIControlStateNormal];
    [rejectButton addTarget:self action:@selector(rejectRequest:) forControlEvents:UIControlEventTouchUpInside];
    
    [respondView addSubview:submitCommentButton];
    [respondView addSubview:rejectButton];
    [respondView addSubview:commentTextView];
    [scroller addSubview:respondView];

    if ([[requestDetailDict objectForKey:@"current_req_status_id"] isEqualToString:kRejectRequestId])
    {
        respondView.hidden = YES;
    }
}

- (void) generateBottomView
{
    float btnWidth = 150, btnHeight = 30;
    float yAxisMargin = self.view.bounds.size.height - 90;
    bottomButtonsView = [[UIView alloc] initWithFrame:CGRectMake(20, yAxisMargin, 250, 100)];
    
    // Create Respond Button
    respondButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    respondButton.frame = CGRectMake(65, 0, btnWidth, btnHeight);
    respondButton.backgroundColor = [UIColor blueColor];
    [respondButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [respondButton setTitle:@"Respond" forState:UIControlStateNormal];
    [respondButton addTarget:self action:@selector(respondButton:) forControlEvents:UIControlEventTouchUpInside];
    
    // Create Cancel Comment Button
    cancelCommentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    cancelCommentButton.frame = CGRectMake(40, 0, 100, btnHeight);
    cancelCommentButton.backgroundColor = [UIColor blueColor];
    [cancelCommentButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [cancelCommentButton setTitle:@"Cancel" forState:UIControlStateNormal];
    [cancelCommentButton addTarget:self action:@selector(cancelComment:) forControlEvents:UIControlEventTouchUpInside];
    cancelCommentButton.hidden = YES;
    
    // Create Submit Comment Button
    submitCommentButton = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    submitCommentButton.frame = CGRectMake(150, 0, 100, btnHeight);
    submitCommentButton.backgroundColor = [UIColor blueColor];
    [submitCommentButton setTitleColor:[UIColor whiteColor] forState: UIControlStateNormal];
    [submitCommentButton setTitle:@"Submit" forState:UIControlStateNormal];
    [submitCommentButton addTarget:self action:@selector(submitComment:) forControlEvents:UIControlEventTouchUpInside];
    submitCommentButton.hidden = YES;
    
    [bottomButtonsView addSubview:cancelCommentButton];
    [bottomButtonsView addSubview:submitCommentButton];
    [bottomButtonsView addSubview:respondButton];
    
    //    [self.view addSubview:bottomButtonsView];
    [scroller addSubview:bottomButtonsView];
    
    bottomButtonsView.hidden = YES;
    
    [self showOrHideBottomButtonViewForStatusId:[requestDetailDict objectForKey:@"current_req_status_id"]];
}

- (void) generateCommentView
{
    float yAxisMargin = respondView.frame.origin.y + respondView.frame.size.height + 5;
    float commentsHeight = self.view.frame.origin.y - yAxisMargin + 15;
    
    //    commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(kOriginXaxis-5, yAxisMargin, kFrameWidth+5, commentsHeight) style: UITableViewStyleGrouped];
    
    commentsTableView = [[UITableView alloc] initWithFrame:CGRectMake(kOriginXaxis-5, yAxisMargin, kFrameWidth+5, commentsHeight)];
//    commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];
    UIView *headerTitle = [[UIView alloc] initWithFrame:CGRectMake(kOriginXaxis, yAxisMargin, kFrameWidth, 30)];
    UILabel *titlelabel = [[UILabel alloc] initWithFrame:CGRectMake(10, 0, 100, 30)];
    titlelabel.text = @"Comments:";
    [titlelabel setFont:[UIFont boldSystemFontOfSize:kSmallFont]];
    headerTitle.backgroundColor = [UIColor whiteColor];
    [headerTitle addSubview:titlelabel];

    [self addFooterForTitle:@"View more Comments..."];
    commentsTableView.layer.borderColor = [UIColor blackColor].CGColor;
    commentsTableView.layer.borderWidth = 1.0;
    commentsTableView.tableHeaderView = headerTitle;
    [commentsTableView setDelegate:self];
    [commentsTableView setDataSource:self];
    commentsTableView.backgroundColor = [UIColor clearColor];
    
    [scroller addSubview:commentsTableView];
    //    [self.view addSubview:commentsTableView];
}

- (IBAction) handleSingleTapOnFooter: (UIGestureRecognizer *) sender
{
    isTruncateComments = !isTruncateComments;
    
    if (isTruncateComments)
        [self addFooterForTitle:@"View more Comments..."];
    else
    {
        [self addFooterForTitle:@"View less Comments..."];
//        totalCommentTableRows = (int) [commentsArray count];
        CGRect tableFrame = commentsTableView.frame;
        tableFrame.size.height = 100000;
        commentsTableView.frame = tableFrame;
    }
    [self reloadCommentsTable];
}

- (void) addFooterForTitle:(NSString *) text
{
    commentsTableView.tableFooterView = [[UIView alloc] initWithFrame:CGRectZero];

    UIView *footerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kFrameWidth, 30)];
    UILabel *titlelabel1 = [[UILabel alloc] initWithFrame:CGRectMake(5, 0, 200, 30)];
    titlelabel1.text = text;
    [titlelabel1 setFont:[UIFont systemFontOfSize:kSmallFont]];
    titlelabel1.textColor = [UIColor blueColor];
    footerView.backgroundColor = [UIColor whiteColor];
    
    UITapGestureRecognizer *singleTap = [[UITapGestureRecognizer alloc]
                                         initWithTarget:self action:@selector(handleSingleTapOnFooter:)];
    singleTap.numberOfTapsRequired = 1;
    [footerView addGestureRecognizer:singleTap];
    [footerView addSubview:titlelabel1];
    
    commentsTableView.tableFooterView = footerView;
}

- (void) showOrHideBottomButtonViewForStatusId:(NSString *)statusId
{
    // Hide Reject/Respond button if Status is either Rejected OR Purchased
    if (!([[NSString stringWithFormat:@"%@", statusId] isEqualToString:@"6"] || [[NSString stringWithFormat:@"%@", statusId] isEqualToString:@"4"]))
        bottomButtonsView.hidden = NO;
    else
        bottomButtonsView.hidden = YES;
}

- (void) initializeRespondViewText
{
    commentTextView.text = @"Enter your comments...";
    commentTextView.textColor = [UIColor lightGrayColor];
}

- (IBAction) cancelComment:(id)sender
{
    [self hideCommentButtons:YES];
}

- (IBAction) submitComment:(id)sender
{
    NSString *comment = [commentTextView text];
    
    if ((comment.length == 0) || ![comment isEqualToString:@"Enter your comments..."])
    {
        [commentTextView resignFirstResponder];
        whichAPICall = @"replyTorequest";
        [self showLoaderWithText:@"loading..."];
        
        NSString *phNo = [[SharedDataClass sharedInstance] getMobileNumber];
        
        NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", @"2", @"usertype", comment, @"new_reply", requestId, @"requestid", nil];
        NSError *error;
        NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:&error];
        
        [[DataManager sharedInstance] replyTorequest:jsonData];
        [[DataManager sharedInstance] setDelegate:self];
    }
    else
    {
        [self showAlertforTitle:@"Unable to respond" Messsage:@"Comment cannot be blank"];
    }
}

- (IBAction)respondButton:(id)sender
{
    [self initializeRespondViewText];
    //    [commentTextView becomeFirstResponder];
    [self hideCommentButtons:NO];
}


- (IBAction) rejectRequest:(id)sender
{
    [self callChangeStatusServiceforStatus:kRejectRequestId];
}

- (void) hideCommentButtons:(BOOL) val
{
    commentsTableView.hidden = !val;
    respondButton.hidden = !val;
    submitCommentButton.hidden = val;
    cancelCommentButton.hidden = val;
    commentTextView.hidden = val;
}

- (void) callChangeStatusServiceforStatus: (NSString *) newStatus
{
    [self showLoaderWithText:@"Changing Status..."];
    NSString *phNo = [[SharedDataClass sharedInstance] getMobileNumber];
    
    NSDictionary* dictData = [NSDictionary dictionaryWithObjectsAndKeys: phNo, @"phone", requestId, @"requestid", newStatus, @"status", nil];
    NSError *error;
    NSData* jsonData = [NSJSONSerialization dataWithJSONObject:dictData options:kNilOptions error:&error];
    
    whichAPICall = @"changeRequestStatus";
    [[DataManager sharedInstance] changeRequestStatus:jsonData];
    [[DataManager sharedInstance] setDelegate:self];
}

- (void) showLoaderWithText: (NSString *)text
{
    HUD = [[MBProgressHUD alloc]initWithView:self.view];
    [self.view addSubview:HUD];
    HUD.labelText = text;
    HUD.dimBackground = YES;
    [HUD show:YES];
}

#pragma mark Adjust View Height and Location

- (void) adjustScrollerHeight
{
//    float height1 = commentsTableView.frame.origin.y + commentsTableView.frame.size.height + 10;
    
    float height = commentsTableView.frame.origin.y + commentsTableHeight + commentsTableView.tableHeaderView.frame.size.height+ commentsTableView.tableFooterView.frame.size.height + 10;
    [scroller setContentSize:CGSizeMake(320, height)];
}

- (void) changeCommentsTableHeight
{
    CGRect tableFrame = commentsTableView.frame;
    tableFrame.size.height = commentsTableHeight + commentsTableView.tableHeaderView.frame.size.height+ commentsTableView.tableFooterView.frame.size.height;
    commentsTableView.frame = tableFrame;
//    [self adjustScrollerHeight];
}

-(void) changeRequestDetailsTableHeight
{
    CGRect tableFrame = requestDescriptionTableView.frame;
    tableFrame.size.height = requestDescriptionTableHeight;
    requestDescriptionTableView.frame = tableFrame;
    [self changeRespondViewLocation];
}

- (void) changeRespondViewLocation
{
    CGRect viewFrame = respondView.frame;
    viewFrame.origin.y = requestDescriptionTableView.frame.origin.y + requestDescriptionTableView.frame.size.height + 10;
    respondView.frame = viewFrame;
    [self changeCommentsTableLocation];
}

- (void) changeCommentsTableLocation
{
    float yAxisMargin;
    
    if ([[requestDetailDict objectForKey:@"current_req_status_id"] isEqualToString:kRejectRequestId])
    {
        yAxisMargin = respondView.frame.origin.y;
    }
    else
    {
        yAxisMargin = respondView.frame.origin.y + respondView.frame.size.height + 10;
    }
    CGRect tableFrame = commentsTableView.frame;
    tableFrame.origin.y = yAxisMargin;
    commentsTableView.frame = tableFrame;
    [self adjustScrollerHeight];
}

#pragma mark - Action Sheet Delegate

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    if (buttonIndex < [nextStatusArray count])
    {
        NSString *nextStatusID = [[nextStatusArray objectAtIndex:buttonIndex] objectForKey:@"id"];
        [self callChangeStatusServiceforStatus:nextStatusID];
    }
}

#pragma mark - UITableView Delegate

- (NSInteger) tableView:(UITableView *)tableView sectionForSectionIndexTitle:(NSString *)title atIndex:(NSInteger)index
{
    return 1;
}

- (NSInteger) tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if ([tableView isEqual:commentsTableView])
    {
        if ([commentsArray count] == 0)
        {
            isComments = NO;
            return 1;
        }
        else
        {
            isComments = YES;
            if (isTruncateComments)
            {
                if ([commentsArray count] < kNumberOfTruncatedComments+1)
                    totalCommentTableRows = (int) [commentsArray count];
                else
                    totalCommentTableRows = kNumberOfTruncatedComments+1;
            }
            else
                totalCommentTableRows = (int) [commentsArray count];
            return totalCommentTableRows;
        }
    }
    else
    {
        if ([[requestDetailDict objectForKey:@"request_filter"] count] == 0)
        {
            isFilterData = NO;
            return 1;
        }
        else
        {
            isFilterData = YES;
            return [[requestDetailDict objectForKey:@"request_filter"] count];
        }
    }
}

- (UITableViewCell *) tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
       return cell;
}

- (void) tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:commentsTableView])
    {
        if (true)//(indexPath.row == totalCommentTableRows-1)
        {
//            isTruncateComments = !isTruncateComments;
//            
//            if (isTruncateComments)
//                if ([commentsArray count] < kNumberOfTruncatedComments+1)
//                    totalCommentTableRows = (int) [commentsArray count];
//                else
//                    totalCommentTableRows = kNumberOfTruncatedComments+1;
//                else
//                {
//                    totalCommentTableRows = (int) [commentsArray count];
//                    CGRect tableFrame = commentsTableView.frame;
//                    tableFrame.size.height = 500;
//                    commentsTableView.frame = tableFrame;
//                }
//            [self reloadCommentsTable];
        }
    }
}

- (void) reloadCommentsTable
{
    commentsTableHeight = 0.0;
    [commentsTableView reloadData];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float height;
    
    if ([tableView isEqual:commentsTableView])
    {
        if ([commentsArray count] == 0)
        {
            height = 30;
            commentsTableHeight += height;
        }
        else
        {
            UIView *commentsView = [[UIView alloc] init];
            commentsView.tag = 110;
            
            UILabel *commentLabel = [[UILabel alloc] init];
            commentLabel.numberOfLines = 0;
            commentLabel.lineBreakMode = NSLineBreakByWordWrapping;
            commentLabel.font = [UIFont systemFontOfSize:kSmallFont];
            
            UILabel *commentDate = [[UILabel alloc] init];
            commentDate.font = [UIFont systemFontOfSize:kVerySmallFont];

            NSDictionary *commentsDict = [commentsArray objectAtIndex:indexPath.row];
            
            commentDate.text = [commentsDict objectForKey:@"date"];
            commentLabel.text = [commentsDict objectForKey:@"comment"];
            
            // Generate dynamic label height
            CGSize maximumLabelSize = CGSizeMake(200,CGFLOAT_MAX);
            CGSize requiredSize = [commentLabel sizeThatFits:maximumLabelSize];
            commentLabel.frame = CGRectMake(5, 0, kFrameWidth-5, requiredSize.height);
            commentLabel.backgroundColor = [UIColor yellowColor];

            commentDate.frame = CGRectMake(5, commentLabel.frame.size.height, kFrameWidth-5, 20);
            
            commentsView.frame = CGRectMake(0, 0, kFrameWidth+5, commentLabel.frame.size.height+commentDate.frame.size.height+5);
            
            height = commentsView.frame.size.height;
            
            commentsTableHeight += height;
        }
//        [self adjustScrollerHeight];
    }
    else // requestDescriptionTableView
    {
        UITableViewCell *cell = [self tableView:tableView cellForRowAtIndexPath:indexPath];
        UIView *descView = (UIView *)[cell viewWithTag:111];
        height = descView.frame.size.height+5;
        requestDescriptionTableHeight += height;
    }
    return height;
}

// Calls when Rows are loaded in table(s) NOTE: This method is always called whenever UITableView is scrolled
-(void) tableView:(UITableView *)tableView willDisplayCell:(UITableViewCell *)cell forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([tableView isEqual:commentsTableView])
    {
        [self adjustScrollerHeight];
        [self changeCommentsTableHeight];
    }
    else
        [self changeRequestDetailsTableHeight];
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
            
        }
        else if([[NSString stringWithFormat:@"%@",status] isEqualToString: [NSString stringWithFormat:@"201"]]) // validation Error
        {
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

- (BOOL) textViewShouldBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"Enter your comments..."])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
    
    CGRect textViewRect = [self.view.window convertRect:textView.bounds fromView:textView];
    CGRect viewRect = [self.view.window convertRect:self.view.bounds fromView:self.view];
    CGFloat midline = textViewRect.origin.y + 0.5 * textViewRect.size.height;
    CGFloat numerator =  midline - viewRect.origin.y  - MINIMUM_SCROLL_FRACTION * viewRect.size.height;
    CGFloat denominator = (MAXIMUM_SCROLL_FRACTION - MINIMUM_SCROLL_FRACTION)
    * viewRect.size.height;
    CGFloat heightFraction = numerator / denominator;
    if (heightFraction < 0.0)
    {
        heightFraction = 0.0;
    }
    else if (heightFraction > 1.0)
    {
        heightFraction = 1.0;
    }
    UIInterfaceOrientation orientation = [[UIApplication sharedApplication] statusBarOrientation];
    if (orientation == UIInterfaceOrientationPortrait ||
        orientation == UIInterfaceOrientationPortraitUpsideDown)
    {
        animatedDistance = floor(PORTRAIT_KEYBOARD_HEIGHT * heightFraction);
    }
    else
    {
        animatedDistance = floor(LANDSCAPE_KEYBOARD_HEIGHT * heightFraction);
    }
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y -= animatedDistance;
    
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

- (BOOL) textViewShouldEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""]) {
        textView.text = @"Enter your comments...";
        textView.textColor = [UIColor lightGrayColor];
    }
    
    CGRect viewFrame = self.view.frame;
    viewFrame.origin.y += animatedDistance;
    [UIView beginAnimations:nil context:NULL];
    [UIView setAnimationBeginsFromCurrentState:YES];
    [UIView setAnimationDuration:KEYBOARD_ANIMATION_DURATION];
    [self.view setFrame:viewFrame];
    [UIView commitAnimations];
    return YES;
}

- (BOOL) textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range replacementText:(NSString *)text {
    if([text isEqualToString:@"\n"]){
        [textView resignFirstResponder];
        return NO;
    }else{
        return YES;
    }
}
@end





















