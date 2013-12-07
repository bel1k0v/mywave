//
//  AppDelegate.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "AppDelegate.h"
#import "VkMusicViewController.h"
#import "MyMusicViewController.h"
#import "MainViewController.h"
#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]


@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window = [[UIWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    if (_player == nil) _player = [[AVQueuePlayer alloc]init];
    if (_currentSong == nil) _currentSong = [[NSDictionary alloc]init];
    if (_cache == nil) _cache = [[NSCache alloc]init];//Что это вообще за кэш такой, без таймаута? :-)
  
    MainViewController *mainViewController = [[MainViewController alloc] initWithNibName:@"MainViewController" bundle:nil];
    self.navigationController = [[UINavigationController alloc] initWithRootViewController:mainViewController];
    [self.navigationController.navigationBar setTintColor:[UIColor whiteColor]];
    CGSize shadowOffset = CGSizeMake(0, 2);
    NSShadow *shadow = [[NSShadow alloc] init];
    shadow.shadowColor = [UIColor colorWithRed:0.0 green:0.0 blue:0.0 alpha:0.8];
    shadow.shadowOffset = shadowOffset;
    NSDictionary *textAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                               [UIColor whiteColor], NSForegroundColorAttributeName,
                               shadow, NSShadowAttributeName,
                               [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:21.0], NSFontAttributeName, nil];
    NSDictionary *barButtorTextAttributes = [NSDictionary dictionaryWithObjectsAndKeys:
                                            [UIColor whiteColor], NSForegroundColorAttributeName,
                                            shadow, NSShadowAttributeName,
                                            [UIFont fontWithName:@"HelveticaNeue-CondensedBlack" size:14.0], NSFontAttributeName, nil];
    
    [[UINavigationBar appearance] setTitleTextAttributes: textAttributes];
    [[UINavigationBar appearance] setBarTintColor:UIColorFromRGB(0x18AAD6)];
    [[UIBarButtonItem appearance] setTitleTextAttributes:barButtorTextAttributes forState:UIControlStateNormal];

    self.window.rootViewController = self.navigationController;
    [self.window makeKeyAndVisible];
    return YES;
}

- (void) setTimer
{

        if(_timeObserver)
        {
            _timeObserver = nil;
        }
        
        void (^observerBlock)(CMTime time) = ^(CMTime time) {
            double progress = (double)time.value / (double)time.timescale;
            double duration = [[_currentSong objectForKey:@"duration"] doubleValue];
            double secondsLeft = duration - progress;
            
            int leftMinutes = (int) floor(secondsLeft / 60);
            int leftMinuteSeconds = (int) secondsLeft - leftMinutes * 60;
            
            int progressMinutes = (int) floor(progress / 60);
            int progressMinuteSeconds = (int) progress - progressMinutes * 60;
            
            NSString *timeString = [NSString stringWithFormat:@"%d:%02d - %d:%02d",
                                    progressMinutes,
                                    progressMinuteSeconds,
                                    leftMinutes,
                                    leftMinuteSeconds];
            
            if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
                _delegate.lblMusicTime.text = timeString;
            } else {
                //NSLog(@"App is backgrounded. Time is: %@", timeString);
            }
        };
        
        _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                              queue:dispatch_get_main_queue()
                                                         usingBlock:observerBlock];
    
}

- (void) removeTimer
{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (NSUInteger)application:(UIApplication *)application supportedInterfaceOrientationsForWindow:(UIWindow *)window
{
    return UIInterfaceOrientationMaskPortrait;
}

- (NSDictionary *)playingSong
{
    if (_player.rate != 0.f && _currentSong != nil)
        return _currentSong;
    
    return nil;
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
