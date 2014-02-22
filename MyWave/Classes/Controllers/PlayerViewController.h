//
//  PlayerViewController.h
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController

@property (nonatomic, copy) NSArray *tracks;
@property (nonatomic, readwrite) NSUInteger currentTrackIndex;
@property (nonatomic, readwrite) BOOL tracksFromRemote;

@end
