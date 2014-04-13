//
//  AppDelegate.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AppDelegate.h"
#import "MainViewController.h"
#import "MyMusicViewController.h"
#import "SidePanelController.h"
#import "AppHelper.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController *mainViewController = [[MainViewController alloc] init];
    MyMusicViewController *musicViewController = [[MyMusicViewController alloc]initWithNibName:@"MyMusicViewController" bundle:nil];
    
    UINavigationController *navigationController = [UINavigationController new];
    [navigationController setViewControllers:@[musicViewController] animated:YES];
    [navigationController.navigationBar setTintColor:[UIColor whiteColor]];

    NSDictionary *barButtorTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                             [UIColor whiteColor], NSForegroundColorAttributeName,
                                             [UIFont fontWithName:BaseFont size:14.0], NSFontAttributeName, nil];
    
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                        [UIColor whiteColor], NSForegroundColorAttributeName,
                                        [UIFont fontWithName:BaseFont size:BaseFontSizeHeader], NSFontAttributeName, nil];
        [[UINavigationBar appearance] setTitleTextAttributes: textAttributes];
        [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x18AAD6)];
    } else { // Less than 6.1
        navigationController.navigationBar.tintColor = UIColorFromRGB(0x18AAD6);
        // Customize the title text for *all* UINavigationBars
        [[UINavigationBar appearance] setTitleTextAttributes:
         [NSDictionary dictionaryWithObjectsAndKeys:
          [UIColor colorWithRed:255.0/255.0 green:255.0/255.0 blue:255.0/255.0 alpha:1.0],
          UITextAttributeTextColor,
          [UIFont fontWithName:BaseFont size:BaseFontSizeHeader],
          UITextAttributeFont,
          nil]];
    }

    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtorTextAttributes forState:UIControlStateNormal];
    
    self.viewController = [[SidePanelController alloc]init];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    self.viewController.leftPanel = mainViewController;
    self.viewController.centerPanel = navigationController;
    
    self.window.rootViewController = self.viewController;
    [self.window makeKeyAndVisible];
    return YES;
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
