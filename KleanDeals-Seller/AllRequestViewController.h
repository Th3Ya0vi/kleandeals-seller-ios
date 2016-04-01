//
//  AllRequestViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DataManager.h"
#import "MBProgressHUD.h"

@class MBProgressHUD;

@interface AllRequestViewController : UIViewController<DataManagerDelegate, UICollectionViewDelegate, UICollectionViewDataSource>
{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UICollectionView *allRequestCollection;

@end
