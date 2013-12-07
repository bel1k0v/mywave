//
//  AppDelegate.h
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
#import "PlayerViewController.h"

@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) UINavigationController *navigationController;
@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSDictionary *currentSong;
@property (nonatomic, strong) id timeObserver;

@property (nonatomic, strong) PlayerViewController *delegate;

@property (strong, nonatomic) NSCache *cache;

- (void) setTimer;
- (void) removeTimer;
- (NSDictionary *)playingSong;
@end
