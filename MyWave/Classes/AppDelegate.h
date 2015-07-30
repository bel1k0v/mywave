//
//  AppDelegate.h
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "Track.h"
#include "DOUAudioStreamer.h"
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>


@class SidePanelController;
@interface AppDelegate : UIResponder <UIApplicationDelegate>

@property (strong, readwrite) DOUAudioStreamer *streamer;
@property (strong, nonatomic) Track *currentTrack;
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) SidePanelController *viewController;

@end
