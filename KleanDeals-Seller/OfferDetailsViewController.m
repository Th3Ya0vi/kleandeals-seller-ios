//
//  OfferDetailsViewController.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 30/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "OfferDetailsViewController.h"

#define kTextFieldPlaceholder "Offer Description"

@interface OfferDetailsViewController ()
{
    UIButton *deleteBtn;
    NSString *encodedimage; // Offer Image encoded in BASE64
    UIToolbar *toolBar;
}
@property (nonatomic) UIDatePicker *startDate;
@property (nonatomic) UIDatePicker *endDate;
@end

@implementation OfferDetailsViewController
@synthesize offerDescription, offerEndDate, offerPhoto, offerStartDate, submitOffer, startDate, endDate, offerDetails, viewOffer;

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self createDeleteBtn];
    
    if (viewOffer)
        [self offerEditView];
    else
        [self offerCreateView];
    
    [self.view setBackgroundColor: [UIColor colorWithPatternImage:[UIImage imageNamed:@"background.jpeg"]]];
}

- (void) viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    
    toolBar = [[UIToolbar alloc] initWithFrame:CGRectMake(0, 230, 320, 40)];
    
    [self createDoneButtonForTarget:@""];
    
    startDate = [self createDatePicker];
    endDate = [self createDatePicker];
    [self populateOfferDate];
    
    [offerStartDate setInputView:startDate];
    offerStartDate.inputAccessoryView = toolBar;
    
    [offerEndDate setInputView:endDate];
    offerEndDate.inputAccessoryView = toolBar;
    
    UIImageView *startCalView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIImageView *endCalView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 25, 25)];
    UIImage *calenderImage = [UIImage imageNamed:@"blue-dot.png"];
    startCalView.image = calenderImage;
    endCalView.image = calenderImage;
    
    offerStartDate.rightView = startCalView;
    offerStartDate.rightViewMode = UITextFieldViewModeAlways;

    offerEndDate.rightView = endCalView;
    offerEndDate.rightViewMode = UITextFieldViewModeAlways;
}

- (void) createDeleteBtn
{
    deleteBtn = [[UIButton alloc] init];
    deleteBtn.frame=CGRectMake(0,0,30,30);
    [deleteBtn setBackgroundImage:[UIImage imageNamed: @"delete.png"] forState:UIControlStateNormal];
    [deleteBtn addTarget:self action:@selector(deleteOffer) forControlEvents:UIControlEventTouchUpInside];
    [deleteBtn setHidden:YES];
    
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc]initWithCustomView:deleteBtn];
}

- (void) deleteOffer
{
    NSLog(@"Offer Deleted");
}

- (void) offerCreateView
{
    [deleteBtn setHidden:YES];
    [self setTitle:@"Create Offer"];
    
    [offerPhoto setTitle:@"Add Photo" forState:UIControlStateNormal];
    [submitOffer setTitle:@"Create Offer" forState:UIControlStateNormal];
}

- (void) offerEditView
{
    [deleteBtn setHidden:NO];
    [self setTitle:@"Edit Offer"];
    
    [offerPhoto setTitle:@"Change Photo" forState:UIControlStateNormal];
    [submitOffer setTitle:@"Update Offer" forState:UIControlStateNormal];
    [self populateOfferData];
}

- (void) populateOfferData
{
    if (viewOffer)
    {
        offerDescription.text = [offerDetails objectForKey:@"offerdescription"];
        offerStartDate.text = [offerDetails objectForKey:@"fromdate"];
        offerEndDate.text = [offerDetails objectForKey:@"todate"];
    }
}

- (void) populateOfferDate
{
    if (viewOffer)
    {
//        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//        [dateFormatter setDateFormat:@"yyyy-dd-MM HH:mm:ss"];
//        NSDate *fromDate = [dateFormatter dateFromString:[offerDetails objectForKey:@"fromdate"]];
//        NSDate *toDate = [dateFormatter dateFromString:[offerDetails objectForKey:@"todate"]];
//
//        
//        startDate.date = fromDate;
//        endDate.date = toDate;
    }
}

- (IBAction)submitOfferClicked:(id)sender
{
}

- (IBAction)offerPhotoClicked:(id)sender
{
    [self openImageLibrary];
}

- (UIDatePicker *) createDatePicker
{
    UIDatePicker *picker = [[UIDatePicker alloc] init];
    [picker setMinimumDate:[NSDate date]];
    NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
    [dateFormat setDateFormat:@"dd/MM/yyyy HH:mm:ss"];
    
    UIDatePicker *datePicker = [[UIDatePicker alloc]init];
    [datePicker setDate:[NSDate date]];
    [datePicker addTarget:self action:@selector(updateTextField:) forControlEvents:UIControlEventValueChanged];
 
    return picker;
}

-(void)updateTextField:(id)sender
{
    NSLog(@"%s", __PRETTY_FUNCTION__);
    if ([sender isEqual:startDate])
    {
        NSLog(@"Start Date");
        UIDatePicker *picker = (UIDatePicker*)offerStartDate.inputView;
        offerStartDate.text = [NSString stringWithFormat:@"%@", picker.date];
    }
    else if ([sender isEqual:endDate])
    {
        NSLog(@"End Date");
        UIDatePicker *picker = (UIDatePicker*)offerEndDate.inputView;
        offerStartDate.text = [NSString stringWithFormat:@"%@", picker.date];
    }
    else
    {
        NSLog(@"None");
    }
}

- (void) createDoneButtonForTarget:(NSString *) target
{
    [toolBar setBarStyle:UIBarStyleDefault];
    
    UIBarButtonItem *flexButton = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace target:self action:nil];
    
    UIBarButtonItem *doneButton =[[UIBarButtonItem alloc] initWithTitle:@"Done" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerDoneBtn)];
    
    UIBarButtonItem *cancelButton =[[UIBarButtonItem alloc] initWithTitle:@"Cancel" style:UIBarButtonItemStyleBordered target:self action:@selector(pickerCancelBtn)];
    
    NSArray *itemsArray = [NSArray arrayWithObjects: cancelButton,flexButton,  doneButton, nil];
    
    [toolBar setItems:itemsArray];
}

- (void) pickerCancelBtn
{
    [self hidePicker];
}

- (void) pickerDoneBtn
{
    [self hidePicker];
}

- (void) hidePicker
{
    [offerStartDate resignFirstResponder];
    [offerEndDate resignFirstResponder];
}

- (void) pickerEndBtn
{
    
}

// No field should be blank
- (void) validateOffer
{
    
}

- (void) openImageLibrary
{
    UIImagePickerController *imagePickerViewController = [[UIImagePickerController alloc] init];
    imagePickerViewController.delegate = self;
    imagePickerViewController.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    [self presentViewController:imagePickerViewController animated:YES completion:nil];
}

#pragma mark - ImagePicker Delegate

-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"Image picked");
    [picker dismissViewControllerAnimated:YES completion:nil];
    UIImage * pickedImage = [info objectForKey:UIImagePickerControllerOriginalImage];
    
    NSData * data = [UIImagePNGRepresentation(pickedImage) base64EncodedDataWithOptions:NSDataBase64Encoding64CharacterLineLength];
    encodedimage = [NSString stringWithUTF8String:[data bytes]];
    encodedimage = [encodedimage stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    encodedimage = [encodedimage stringByReplacingOccurrencesOfString:@"\r" withString:@""];
}
@end












