//
//  CategoryViewController.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MBProgressHUD.h"
#import "DataManager.h"

@class MBProgressHUD;

@interface CategoryViewController : UIViewController <UICollectionViewDelegate, UICollectionViewDataSource, DataManagerDelegate>
{
    MBProgressHUD *HUD;
}

@property (weak, nonatomic) IBOutlet UICollectionView *categoryCollection;

@end
