//
//  RequestDetailViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <QuartzCore/QuartzCore.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@interface RequestDetailViewController : UIViewController <DataManagerDelegate, UITableViewDelegate, UITableViewDataSource, UITextViewDelegate>
{
    MBProgressHUD *HUD;
}

@property (strong, nonatomic) NSMutableDictionary *requestDetailDict;
@property (weak, nonatomic) IBOutlet UIScrollView *scroller;

@end
