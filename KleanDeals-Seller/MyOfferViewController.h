//
//  MyOfferViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 30/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DataManager.h"

@class MBProgressHUD;

@interface MyOfferViewController : UIViewController <UITableViewDataSource, UITableViewDelegate, DataManagerDelegate>
{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UITableView *myOfferTableView;

@end
