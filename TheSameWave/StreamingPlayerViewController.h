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
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSTimer *progressUpdateTimer;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSString *playerState;

- (IBAction)sliderMoved:(UISlider *)aSlider;
-(void) updateProgress:(NSTimer *)aNotification;
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;

@end
