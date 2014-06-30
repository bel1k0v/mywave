//
//  AppDelegate.m
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AppDelegate.h"
#import "NavigationController.h"
#import "MainViewController.h"
#import "DeviceMusicViewController.h"
#import "SidePanelController.h"
#import "AppHelper.h"
#import "Track+Provider.h"

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{    
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    MainViewController *mainViewController = [MainViewController new];
    DeviceMusicViewController *musicViewController = [[DeviceMusicViewController alloc]initWithNibName:@"MyMusicViewController"
                                                                                        bundle:nil];
    musicViewController->tracks = [[NSMutableArray alloc]initWithArray:[Track deviceTracks]];
    
    NavigationController *navigationController = [NavigationController new];
    [navigationController setViewControllers:@[musicViewController] animated:YES];
    
    self.viewController = [SidePanelController new];
    self.viewController.shouldDelegateAutorotateToVisiblePanel = NO;
    self.viewController.leftPanel = mainViewController;
    self.viewController.centerPanel = navigationController;
    
    [application setStatusBarHidden:NO];
    [application setStatusBarStyle:UIStatusBarStyleLightContent];

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
