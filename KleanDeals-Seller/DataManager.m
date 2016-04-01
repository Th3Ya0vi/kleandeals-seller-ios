//
//  DataManager.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 05/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#define BASE_URL @"http://xxxxxxxxxxxxxxxxx"

#import "DataManager.h"
#import "SharedViewClass.h"

@interface DataManager()
{
    NSMutableData *responseData;
    NSDictionary *responseDict;
}
@property (nonatomic, strong) SharedViewClass *sharedView;
@end

@implementation DataManager
@synthesize delegate, sharedView;

static DataManager *sharedInstance = nil;

+ (DataManager *) sharedInstance
{
    if (sharedInstance == nil) {
        sharedInstance = [[DataManager alloc] init];
    }
    return sharedInstance;
}

- (void) callServiceToMethod:(NSString *) method withParameter:(NSData *) param andRequestType:(NSString *) type
{
    sharedView = [[SharedViewClass alloc] init];
    @try
    {
        NSString *urlString;
        responseData = [NSMutableData data];
        urlString = [NSString stringWithFormat:@"%@%@", BASE_URL, method];
        
        NSURL *url = [NSURL URLWithString:urlString];
        
        NSLog(@"URL = %@", url);
        NSString* paramStr = [[NSString alloc] initWithData:param encoding:NSUTF8StringEncoding];
        NSLog(@"Request Parameter = %@", paramStr);
        
        NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url];
        //    NSMutableURLRequest *request = [NSMutableURLRequest requestWithURL:url cachePolicy: NSURLRequestUseProtocolCachePolicy timeoutInterval:20.0];
        [request addValue: @"application/x-www-form-urlencoded; charset=utf-8" forHTTPHeaderField:@"Content-Type"];
        [request setHTTPMethod:@"POST"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
        [request setValue:@"application/json" forHTTPHeaderField:@"Accept"];
        
        [request setHTTPBody:param];
        
        //    [request setValue:parameterLength forHTTPHeaderField:@"Content-Length"];
        //    [request setValue:@"application/x-www-form-urlencoded" forHTTPHeaderField:@"Current-Type"];
        
        NSURLConnection *connection = [[NSURLConnection alloc]initWithRequest:request delegate:self];
        if(connection)
        {
            NSLog(@"Connection Successful with connection");
        }
        else
        {
            NSLog(@"Connection could not be made");
        }
        
    }
    @catch (NSException *exception) {
        [sharedView showAlertforTitle:@"Internal Error" Messsage:@"Please try after some time"];
        [delegate hideLoader];
        NSLog(@"Exception found in callServiceToMethod in DataManager: %@", [exception description]);
    }
}

- (void) setNotificationStatus:(NSData *)items
{
    [self callServiceToMethod:@"set_notification_status" withParameter:items andRequestType:@"POST"];
}

- (void) getMyOffers:(NSData *) items
{
    [self callServiceToMethod:@"get_my_offers" withParameter:items andRequestType:@"POST"];
}

#pragma mark - NSURLConnectionDelegate

- (void)connection:(NSURLConnection *)connection didReceiveResponse:(NSURLResponse *)response {
    // A response has been received, this is where we initialize the instance var you created
    // so that we can append data to it in the didReceiveData method
    // Furthermore, this method is called each time there is a redirect so reinitializing it
    // also serves to clear it
    [responseData setLength:0];
}

-(void)connection:(NSURLConnection *)connection didReceiveData:(NSData*)data
{
    [responseData appendData:data];
}

-(void)connection:(NSURLConnection *)connection didFailWithError:(NSError *)error
{
    sharedView =[[SharedViewClass alloc] init];
    NSDictionary *userInfo = [error userInfo];
    NSString *errorString = [[userInfo objectForKey:NSUnderlyingErrorKey] localizedDescription];
    
    [sharedView showAlertforTitle:@"Error" Messsage:errorString];
    [delegate hideLoader];
    NSLog(@"didFailWithError = %@", [error description]);
}

-(void)connectionDidFinishLoading:(NSURLConnection *)connection
{
    @try
    {
        NSLog(@"connection = %@", connection);
        NSString *responseString = [[NSString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
        responseData = nil;
        
        NSError *jsonParsingError = nil;
        NSData *data = [responseString  dataUsingEncoding:NSUTF8StringEncoding];
        NSArray *jsonArray = [NSJSONSerialization JSONObjectWithData: data options: NSJSONReadingMutableContainers error: &jsonParsingError];
        NSDictionary *dict = [jsonArray mutableCopy];
        responseDict = dict;
        
        if (responseDict) {
            if ([delegate respondsToSelector:@selector(gotResponseData:)]) {
                [delegate gotResponseData:responseDict];
            }
        }
    }
    @catch (NSException *exception)
    {
        NSLog(@"Exception in connectionDidFinishLoading: %@", [exception description]);
    }
}
@end