//
//  AppDelegate.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "DeviceMusicViewController.h"
#import "AppHelper.h"
#import "VKSdk.h"

@implementation AppDelegate


-(BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation
{
    [VKSdk processOpenURL:url fromApplication:sourceApplication];
    return YES;
}

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    
    MainViewController *mainViewController = [MainViewController new];
    DeviceMusicViewController *musicViewController = [DeviceMusicViewController new];
    UINavigationController *navigationController = [UINavigationController new];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    [navigationController setViewControllers:@[musicViewController] animated:YES];
    
    self.viewController = [SidePanelController new];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    self.viewController.leftPanel = mainViewController;
    self.viewController.centerPanel = navigationController;
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(receiveTestNotification:)
                                                 name:@"TestNotification"
                                               object:nil];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor colorWithRed:245.0/255.0 green:245.0/255.0 blue:245.0/255.0 alpha:1.0],
                                        NSForegroundColorAttributeName,
                                        [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
                                        NSFontAttributeName, nil];
        
        [[UINavigationBar appearance] setTitleTextAttributes: textAttributes];
        [[UINavigationBar appearance] setBarTintColor:[UIColor colorWithRed:0.0033f green:0.0033f blue:0.0033f alpha:1.0f]];
    }
    else
    { // 6.1, 6.0
//        self.navigationBar.tintColor = [UIColor colorWithRed:0.0902f green:0.6941f blue:0.9647f alpha:1.0f];
        // Customize the title text for *all* UINavigationBars
//        [[UINavigationBar appearance] setTitleTextAttributes:
//         [NSDictionary dictionaryWithObjectsAndKeys:
//          [UIColor whiteColor],
//          UITextAttributeTextColor,
//          [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
//          UITextAttributeFont,
//          nil]];
    }
    
    
    NSDictionary *barButtorTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor whiteColor],
                                             NSForegroundColorAttributeName,
                                             [UIFont fontWithName:BaseFont size:BaseFontSizeDefault],
                                             NSFontAttributeName, nil];
    
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtorTextAttributes
                                                forState:UIControlStateNormal];
    
    
    return YES;
}

- (void) receiveTestNotification:(NSNotification *) notification
{
    if ([[notification name] isEqualToString:@"TestNotification"]) {
        NSLog (@"Successfully received the test notification! %@", notification.object);
        self.currentTrack = notification.object;
    }
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)applicationWillResignActive:(UIApplication *)application
{
}

- (void)applicationDidEnterBackground:(UIApplication *)application
{
}

- (void)applicationWillEnterForeground:(UIApplication *)application
{
}

- (void)applicationDidBecomeActive:(UIApplication *)application
{
}

- (void)applicationWillTerminate:(UIApplication *)application
{
}

@end
