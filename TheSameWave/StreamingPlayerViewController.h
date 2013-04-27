//
//  StreamingPlayerViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 27.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface StreamingPlayerViewController : UIViewController

@property (nonatomic, strong) NSString *songUrl;
@property (nonatomic, strong) AudioStreamer *streamer;

@end
