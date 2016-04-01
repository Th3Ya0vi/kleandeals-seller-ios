//
//  myOfferTableViewCell.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 30/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface myOfferTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIImageView *offerImage;
@property (weak, nonatomic) IBOutlet UILabel *offerDetail;
@property (weak, nonatomic) IBOutlet UILabel *offerValidDate;

@end
