//
//  DataManager.h
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import <Foundation/Foundation.h>

@protocol DataManagerDelegate <NSObject>

- (void) gotResponseData:(NSDictionary *) items;
- (void) hideLoader;
@end

@interface DataManager : NSObject <NSURLConnectionDelegate>

@property (nonatomic,assign)id <DataManagerDelegate>delegate;

+ (DataManager *) sharedInstance;

- (void) registerUser:(NSData *) param;
- (void) verifyUser:(NSData *)items;
- (void) getrequest:(NSData *) items;
- (void) changeRequestStatus:(NSData *) items;
//- (void) getRequestDetail:(NSData *) items;
- (void) getProfile:(NSData *) items;
- (void) updateProfile:(NSData *) items;
- (void) getRatingAndFeedback:(NSData *) items;
- (void) contactKleanDeals:(NSData *) items;
- (void) getAllStatus;
- (void) about_us;
- (void) termsAndCondition;
- (void) replyTorequest:(NSData *) items;
- (void) requestForFeedback:(NSData *) items;
- (void) getNotificationList:(NSData *) items;
- (void) setNotificationStatus:(NSData *) items;
- (void) getSellerProfile:(NSData *) items;
- (void) getMyOffers:(NSData *) items;
@end