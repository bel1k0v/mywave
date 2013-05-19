//
//  StreamingPlayerViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 27.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@class MPVolumeView;
@class AudioStreamer;

@interface StreamingPlayerViewController : UIViewController

@property (nonatomic, strong) NSString *songUrl;
@property (nonatomic, strong) NSString *songName;
@property (nonatomic, strong) NSTimer *progressUpdateTimer;
@property (nonatomic, strong) AudioStreamer *streamer;
@property (weak, nonatomic) IBOutlet UILabel *songNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *playingTimeLabel;
@property (weak, nonatomic) IBOutlet UISlider *progressSlider;
@property (weak, nonatomic) IBOutlet UISlider *volumeSlider;
@property (weak, nonatomic) IBOutlet UIButton *playButton;
@property (nonatomic, strong) NSString *playerState;
@property (nonatomic, strong) MPVolumeView *volumeView;

- (IBAction)sliderMoved:(UISlider *)aSlider;
-(void) updateProgress:(NSTimer *)aNotification;

@end
