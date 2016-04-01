//
//  AppDelegate.m
//  KleanDeals-Seller
//
//  Created by Ksolves on 04/07/15.
//  Copyright (c) 2015 KSolves India. All rights reserved.
//

#import "AppDelegate.h"
#import "WelcomeViewController.h"
#import "SharedDataClass.h"
#import "SharedViewClass.h"

@interface AppDelegate ()

@property (strong, nonatomic) SharedDataClass *sharedManager;
@end

@implementation AppDelegate
@synthesize sharedManager;

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    // Let the device know we want to receive push notifications
    if ([[[UIDevice currentDevice] systemVersion] floatValue] >= 8.0)
    {
        [[UIApplication sharedApplication] registerUserNotificationSettings:[UIUserNotificationSettings settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge) categories:nil]];
        [[UIApplication sharedApplication] registerForRemoteNotifications];
    }
    else
    {
        [[UIApplication sharedApplication] registerForRemoteNotificationTypes:
         (UIUserNotificationTypeBadge | UIUserNotificationTypeSound | UIUserNotificationTypeAlert)];
    }

//    [UIApplication sharedApplication].applicationIconBadgeNumber=0;
    
    sharedManager = [[SharedDataClass alloc] init];
    
    if ([sharedManager checkInternetConnection])
    {
        [[UINavigationBar appearance] setTintColor:[UIColor whiteColor]];
        
//        if (false) // Only for testing Purpose
        if (![self checkForLogin])
        {
            WelcomeViewController *rootController=[[UIStoryboard storyboardWithName:@"Main" bundle:nil] instantiateViewControllerWithIdentifier:@"welcomeView"];
            UINavigationController *navController=[[UINavigationController alloc]initWithRootViewController:rootController];
            self.window.rootViewController=navController;
        }
        else
        {
            [self updateNotificationCount];
            [self setTabBarIcon];
            
            UITabBarController *tabBarController = (UITabBarController *)self.window.rootViewController;
            tabBarController.delegate = self;
            if (![[SharedDataClass sharedInstance] isProfileUpdated])
            {   
                UITabBarController *tabBar = (UITabBarController *)self.window.rootViewController;
                tabBar.selectedIndex = 3;
                
//                UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
//                
//                UITabBarController *tbc = [self.storyboard instantiateViewControllerWithIdentifier:@"tabBarView"];
//                tbc.selectedIndex=3;
//                [self presentViewController:tbc animated:YES completion:nil];
            }
        }
    }
    else
    {
        self.window.rootViewController = [self.window.rootViewController.storyboard instantiateViewControllerWithIdentifier:@"noInternetView"];
    }
    return YES;
}

- (void)tabBarController:(UITabBarController *)tabBarController didSelectViewController:(UIViewController *)viewController {
    if ([viewController isKindOfClass:[UINavigationController class]])
    {
        [(UINavigationController *)viewController popToRootViewControllerAnimated:NO];
    }
}

//- (BOOL)tabBarController:(UITabBarController *)tabBarController shouldSelectViewController:(UIViewController *)viewController
//{
//    NSLog(@"qwertyu");
//    return YES;
//}

- (void) disableSwipeToBack
{
    UINavigationController *navigationController = [[UINavigationController alloc] init];
    if ([navigationController respondsToSelector:@selector(interactivePopGestureRecognizer)]) {
        navigationController.interactivePopGestureRecognizer.enabled = NO;
    }
}

- (void) updateNotificationCount
{
    NSString *count = [[SharedDataClass sharedInstance] getNotificationCount];
    UITabBarController *tabController = (UITabBarController *)self.window.rootViewController;
    [[tabController.viewControllers objectAtIndex:1] tabBarItem].badgeValue = count;
}


- (void)application:(UIApplication *)application didReceiveRemoteNotification:(NSDictionary *)notification
{
    NSLog(@"Received push notification: %@", notification); // iOS 7 and earlier
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"You have received a notification." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)application:(UIApplication *)application handleActionWithIdentifier:(NSString *)identifier forRemoteNotification:(NSDictionary *)notification completionHandler:(void(^)())completionHandler
{
    NSLog(@"Received push notification: %@, identifier: %@", notification, identifier); // iOS 8
    completionHandler();
    
    UIAlertView *alert;
    alert = [[UIAlertView alloc] initWithTitle:@"Notification" message:@"You have received a notification." delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)application:(UIApplication*)application didFailToRegisterForRemoteNotificationsWithError:(NSError*)error
{
    NSLog(@"Failed to get token, error: %@", error);
}

- (BOOL) checkForLogin
{
    NSUserDefaults *defaults = [NSUserDefaults standardUserDefaults];
    
    // check if user is Logged In
    if([defaults objectForKey:@"phonenumber"] == nil && [defaults objectForKey:@"userid"] == nil)
    {
        return NO;
    }
    else
    {
        return YES;
    }
    
    return YES;
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
