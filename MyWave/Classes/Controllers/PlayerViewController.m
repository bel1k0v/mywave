//
//  PlayerViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "PlayerViewController.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "Track.h"
#import "NSString+HTML.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;


@interface PlayerViewController () {
@private
    UILabel *_titleLabel;
    UILabel *_artistLabel;
    UILabel *_statusLabel;
    UILabel *_miscLabel;
    
    UIButton *_buttonPlayPause;
    UIButton *_buttonNext;
    UIButton *_buttonPrevious;
    
    UISlider *_progressSlider;
    
    UISlider *_volumeSlider;
    
    UIProgressView *_miscProgress;
    
    NSTimer *_timer;
    
    DOUAudioStreamer *_streamer;
}

@end

@implementation PlayerViewController

- (void)loadView {
    [self setTitle:@"♫"];
    
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
    [view setBackgroundColor:[UIColor whiteColor]];
    NSString *labelFontName = @"HelveticaNeue-CondensedBlack";
    
    CGFloat topPoint = 34.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        topPoint = 84.0;
    }

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, topPoint, CGRectGetWidth([view bounds]), 30.0)];
    [_titleLabel setFont:[UIFont fontWithName:labelFontName size:18.0]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //[_titleLabel setBackgroundColor:[UIColor redColor]];
    [view addSubview:_titleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_titleLabel frame]), CGRectGetWidth([view bounds]), 30.0)];
    [_artistLabel setFont:[UIFont fontWithName:labelFontName size:16.0]];
    [_artistLabel setTextColor:[UIColor blackColor]];
    [_artistLabel setTextAlignment:NSTextAlignmentCenter];
    [_artistLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //[_artistLabel setBackgroundColor:[UIColor greenColor]];
    [view addSubview:_artistLabel];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_artistLabel frame]), CGRectGetWidth([view bounds]), 30.0)];
    [_statusLabel setFont:[UIFont fontWithName:labelFontName size:14.0]];
    [_statusLabel setTextColor:[UIColor darkGrayColor]];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    //[_statusLabel setBackgroundColor:[UIColor blueColor]];
    [view addSubview:_statusLabel];
    /*
    _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(0.0, CGRectGetMaxY([_statusLabel frame]) + 10.0, CGRectGetWidth([view bounds]), 20.0)];
    [_miscLabel setFont:[UIFont fontWithName:labelFontName size:10.0]];
    [_miscLabel setTextColor:[UIColor greenColor]];
    [_miscLabel setTextAlignment:NSTextAlignmentCenter];
    [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_miscLabel];
    */
    _miscProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY([_statusLabel frame]) + 8.0, 280, 3)];
    _miscProgress.progress = 0.0f;
    [view addSubview:_miscProgress];
    
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPlayPause setFrame:CGRectMake((CGRectGetWidth([view bounds]) - 99.0) / 2 , CGRectGetMaxY([_miscProgress frame]) + 20.0, 99.0, 99.0)];
    [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPlayPause];
    
    _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 20.0 - 53.0, CGRectGetMinY([_buttonPlayPause frame]), 53.0, 53.0)];
    [_buttonNext setBackgroundImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonNext];
    
    _buttonPrevious = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPrevious setFrame:CGRectMake(20, CGRectGetMinY([_buttonPlayPause frame]), 53.0, 53.0)];
    [_buttonPrevious setBackgroundImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
    [_buttonPrevious addTarget:self action:@selector(_actionPrevious:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPrevious];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonPlayPause frame]) + 20.0, CGRectGetWidth([view bounds]) - 40.0, 40.0)];
    [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [_progressSlider setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    [view addSubview:_progressSlider];
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMinY([_progressSlider frame]) + 30.0, CGRectGetWidth([view bounds]) - 40.0, 40.0)];
    [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [_volumeSlider setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    [view addSubview:_volumeSlider];
    
    [self setView:view];
}

- (void)_cancelStreamer {
    if (_streamer != nil) {
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

- (void)_resetStreamer {
    [self _cancelStreamer];
    
    Track *track = [_tracks objectAtIndex:_currentTrackIndex];
    [_titleLabel setText:[NSString htmlEntityDecode:track.title]];
    [_artistLabel setText:[NSString htmlEntityDecode:track.artist]];
    
    _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    [_streamer play];
    
    [self _updateBufferingStatus];
    [self _setupHintForStreamer];
}

- (void)_setupHintForStreamer {
    NSUInteger nextIndex = _currentTrackIndex + 1;
    if (nextIndex >= [_tracks count]) {
        nextIndex = 0;
    }
    
    [DOUAudioStreamer setHintWithAudioFile:[_tracks objectAtIndex:nextIndex]];
}

- (void)_timerAction:(id)timer {
    if ([_streamer duration] == 0.0) {
        [_progressSlider setValue:0.0f animated:NO];
    }
    else {
        [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
    }
}

- (void)_updateStatus {
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"playing"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"paused"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"idle"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"finished"];
            [self _actionNext:nil];
            break;
            
        case DOUAudioStreamerBuffering:
            [_statusLabel setText:@"buffering"];
            break;
            
        case DOUAudioStreamerError:
            [_statusLabel setText:@"error"];
            break;
    }
}

- (void)_updateBufferingStatus {
    //[_miscLabel setText:[NSString stringWithFormat:@"Received %.2f/%.2f MB (%.2f %%), Speed %.2f MB/s", (double)[_streamer receivedLength] / 1024 / 1024, (double)[_streamer expectedLength] / 1024 / 1024, [_streamer bufferingRatio] * 100.0, (double)[_streamer downloadSpeed] / 1024 / 1024]];
    
    _miscProgress.progress = (float) [_streamer receivedLength] / [_streamer expectedLength];
    if ([_streamer bufferingRatio] >= 1.0) {
        NSLog(@"sha256: %@", [_streamer sha256]);
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    if (context == kStatusKVOKey) {
        [self performSelector:@selector(_updateStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kDurationKVOKey) {
        [self performSelector:@selector(_timerAction:)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else if (context == kBufferingRatioKVOKey) {
        [self performSelector:@selector(_updateBufferingStatus)
                     onThread:[NSThread mainThread]
                   withObject:nil
                waitUntilDone:NO];
    }
    else {
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self _resetStreamer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [_volumeSlider setValue:[DOUAudioStreamer volume]];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
}


- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    if (theEvent.type == UIEventTypeRemoteControl) {
        switch (theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self _actionPlayPause:self];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [self _actionPlayPause:self];
                break;
            case UIEventSubtypeRemoteControlPause:
                [self _actionPlayPause:self];
            case UIEventSubtypeRemoteControlStop:
                [self _actionStop:self];
                break;
            case UIEventSubtypeRemoteControlNextTrack:
                [self _actionNext:self];
                break;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self _actionPrevious:self];
                break;
            default:
                NSLog(@"Other");
                break;
        }
    }
}

 - (void)viewWillDisappear:(BOOL)animated {
     [_timer invalidate];
     [_streamer stop];
     [self _cancelStreamer];
     
     [super viewWillDisappear:animated];
 }


- (void)_actionPlayPause:(id)sender {
    if ([_streamer status] == DOUAudioStreamerPaused ||
        [_streamer status] == DOUAudioStreamerIdle) {
        [_streamer play];
    }
    else {
        [_streamer pause];
    }
}

- (void)_actionNext:(id)sender {
    if (++_currentTrackIndex >= [_tracks count]) {
        _currentTrackIndex = 0;
    }
    [self _resetStreamer];
}

- (void)_actionPrevious:(id)sender {
    if (_currentTrackIndex > 0) {
        --_currentTrackIndex;
        [self _resetStreamer];
    }
}

- (void)_actionStop:(id)sender {
    [_streamer stop];
}

- (void)_actionSliderProgress:(id)sender {
    [_streamer setCurrentTime:[_streamer duration] * [_progressSlider value]];
}

- (void)_actionSliderVolume:(id)sender {
    [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

@end
