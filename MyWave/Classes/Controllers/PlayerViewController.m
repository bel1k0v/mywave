//
//  PlayerViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//
#import <MediaPlayer/MediaPlayer.h>

#import "AppDelegate.h"
#import "AppHelper.h"
#import "Track+Db.h"
#import "PlayerViewController.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "DOUAudioEventLoop.h"
#import "DOUAudioVisualizer.h"
#import "UIImageView+AFNetworking.h"

#import "NSString+HTML.h"

static void *kStatusKVOKey = &kStatusKVOKey;
static void *kDurationKVOKey = &kDurationKVOKey;
static void *kBufferingRatioKVOKey = &kBufferingRatioKVOKey;


@interface PlayerViewController () {
@private
    UILabel *_titleLabel;
    UILabel *_artistLabel;
    UILabel *_statusLabel;
    UILabel *_currentTimeLabel;
    UILabel *_elapsedTimeLabel;
    
    UIButton *_buttonPlayPause;
    UIButton *_buttonNext;
    UIButton *_buttonPrevious;
    UIButton *_buttonDownload;
    UIButton *_buttonRepeat;
    UIButton *_buttonShuffle;
    
    UISlider *_progressSlider;
    
    UISlider *_volumeSlider;
    UIImageView *_imageVolumeLow;
    UIImageView *_imageVolumeHigh;
    UIImageView *_cover;
    
    NSTimer *_timer;
    
    DOUAudioStreamer *_streamer;
    DOUAudioVisualizer *_audioVisualizer;
}

@end

@implementation PlayerViewController

- (void)loadView {
    UIView *view = [[UIView alloc] initWithFrame:[[UIScreen mainScreen] bounds]];

    view.backgroundColor = UIColorFromRGB(0xE5E5E5);
    CGFloat topPoint = 74.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
        topPoint = 24.0;
    }
    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, topPoint, CGRectGetWidth([view bounds]) - 40, 20.0)];
    [_titleLabel setFont:[UIFont fontWithName:BaseFont size:BaseFontSizeLead]];
    [_titleLabel setTextColor:UIColorFromRGB(0x333333)];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_titleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_titleLabel frame]) + 4.0, CGRectGetWidth([view bounds]) - 40, 20.0)];
    [_artistLabel setFont:[UIFont fontWithName:BaseFont size:BaseFontSizeDefault]];
    [_artistLabel setTextColor:UIColorFromRGB(0x666666)];
    [_artistLabel setTextAlignment:NSTextAlignmentCenter];
    [_artistLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_artistLabel];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(50.0, CGRectGetMaxY([_artistLabel frame]) + 8.0, CGRectGetWidth([view bounds]) - 100.0, 20.0)];
    [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_progressSlider];
     
    _cover = [[UIImageView alloc]initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame])+10.0, CGRectGetWidth([view bounds]) - 40.0, CGRectGetWidth([view bounds]) - 40.0)];
    [view addSubview:_cover];
    
    _currentTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMinY([_progressSlider frame]), 30.0, 20.0)];
    [_currentTimeLabel setFont:[UIFont fontWithName:BaseFont size:BaseFontSizeExtraSmall]];
    [_currentTimeLabel setTextColor:UIColorFromRGB(0xA5A5A5)];
    [_currentTimeLabel setTextAlignment:NSTextAlignmentLeft];
    [_currentTimeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_currentTimeLabel];
    
    _elapsedTimeLabel = [[UILabel alloc] initWithFrame:CGRectMake(CGRectGetWidth([view bounds]) - 50.0, CGRectGetMinY([_progressSlider frame]), 30.0, 20.0)];
    [_elapsedTimeLabel setFont:[UIFont fontWithName:BaseFont size:BaseFontSizeExtraSmall]];
    [_elapsedTimeLabel setTextColor:UIColorFromRGB(0xA5A5A5)];
    [_elapsedTimeLabel setTextAlignment:NSTextAlignmentRight];
    [_elapsedTimeLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_elapsedTimeLabel];
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(50.0f, CGRectGetMaxY([view bounds]) - 120.0f, CGRectGetWidth([view bounds]) - 100.0, 20.0)];
    [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_volumeSlider];
    
    _imageVolumeLow = [[UIImageView alloc]initWithFrame:CGRectMake(20.0, CGRectGetMinY([_volumeSlider frame]), 18.0, 22.0)];
    [_imageVolumeLow setImage:[UIImage imageNamed:@"mw_speakers_4"]];
    [view addSubview:_imageVolumeLow];
    
    _imageVolumeHigh = [[UIImageView alloc]initWithFrame:CGRectMake(CGRectGetWidth([view bounds]) - 38.0, CGRectGetMinY([_volumeSlider frame]), 18.0, 22.0)];
    [_imageVolumeHigh setImage:[UIImage imageNamed:@"mw_speakers_5"]];
    [view addSubview:_imageVolumeHigh];
    
    CGFloat visStart = CGRectGetMaxY([_volumeSlider frame]) + 10.0f;
    CGFloat visHeight = CGRectGetHeight([view bounds]) - visStart;

    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
        visHeight = visHeight - 66.0;
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_artistLabel setBackgroundColor:[UIColor clearColor]];
        [_statusLabel setBackgroundColor:[UIColor clearColor]];
        [_currentTimeLabel setBackgroundColor:[UIColor clearColor]];
        [_elapsedTimeLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPlayPause setFrame:CGRectMake(CGRectGetWidth([view bounds]) / 2 - 20.0f, CGRectGetHeight([view bounds]) - 90.0f, 40.0f, 40.0f)];
    [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"mw_play_5"] forState:UIControlStateNormal];
    [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPlayPause];
    
    _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 80.0, CGRectGetMinY([_buttonPlayPause frame]), 40.0, 40.0)];
    [_buttonNext setBackgroundImage:[UIImage imageNamed:@"mw_forward_4"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonNext];
    
    _buttonPrevious = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPrevious setFrame:CGRectMake(30, CGRectGetMinY([_buttonPlayPause frame]), 40.0, 40.0)];
    [_buttonPrevious setBackgroundImage:[UIImage imageNamed:@"mw_rewind_4"] forState:UIControlStateNormal];
    [_buttonPrevious addTarget:self action:@selector(_actionPrevious:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPrevious];
    
    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonNext frame]) + 8.0, CGRectGetWidth([view bounds]) - 40, 20.0)];
    [_statusLabel setFont:[UIFont fontWithName:BaseFont size:BaseFontSizeSmall]];
    [_statusLabel setTextColor:UIColorFromRGB(0x333333)];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_statusLabel];
    
    _buttonRepeat = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonRepeat setFrame:CGRectMake(20, CGRectGetMinY([_statusLabel frame]), 20.0, 20.0)];
    [_buttonRepeat setBackgroundImage:[UIImage imageNamed:@"mw_repeat_on_4"] forState:UIControlStateNormal];
    [_buttonRepeat setBackgroundImage:[UIImage imageNamed:@"mw_repeat_on_4"] forState:UIControlStateSelected];
    [_buttonRepeat addTarget:self action:@selector(_actionToggle:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonRepeat];
    
    _buttonShuffle = [UIButton buttonWithType:UIButtonTypeCustom];
    [_buttonShuffle setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 45.0, CGRectGetMinY([_statusLabel frame]), 20.0, 20.0)];
    [_buttonShuffle setBackgroundImage:[UIImage imageNamed:@"mw_shuffle_off_5"] forState:UIControlStateNormal];
    [_buttonShuffle setBackgroundImage:[UIImage imageNamed:@"mw_shuffle_off_5"] forState:UIControlStateSelected];
    [_buttonShuffle addTarget:self action:@selector(_actionToggle:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonShuffle];
    
    if (self.tracksFromRemote == YES) {
        _buttonDownload = [UIButton buttonWithType:UIButtonTypeCustom];
        [_buttonDownload setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 85.0, CGRectGetMinY([_statusLabel frame]), 20.0, 20.0)];
        [_buttonDownload setBackgroundImage:[UIImage imageNamed:@"mw_download_5"] forState:UIControlStateNormal];
        [_buttonDownload addTarget:self action:@selector(_actionDownload:) forControlEvents:UIControlEventTouchDown];
        //UIBarButtonItem *rightBarItem = [[UIBarButtonItem alloc]initWithCustomView:_buttonDownload];
        //self.navigationItem.rightBarButtonItem = rightBarItem;
        [view addSubview:_buttonDownload];
    }
    
//    _audioVisualizer = [[DOUAudioVisualizer alloc] initWithFrame:CGRectMake(0.0, visStart, CGRectGetWidth([view bounds]), visHeight)];
//    [_audioVisualizer setTintColor:[UIColor brownColor]];
//    [_audioVisualizer setStepCount:10];
//    [_audioVisualizer setInterpolationType:DOUAudioVisualizerSmoothInterpolation];
//    [view addSubview:_audioVisualizer];

    [[UISlider appearance] setMaximumTrackTintColor:UIColorFromRGB(0xA5A5A5)];
    [[UISlider appearance] setMinimumTrackTintColor:UIColorFromRGB(0x333333)];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"slider-dot"]
                                forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"slider-dot"]
                                forState:UIControlStateSelected];
    
    UIImage *logo = [UIImage imageNamed: @"logo3"];
    UIImageView *logoView = [[UIImageView alloc] initWithImage: logo];
    self.navigationItem.titleView = logoView;
    [self setView:view];
}
     
 - (void) processArtists:(NSDictionary *)artists {
     if ([artists objectForKey:@"items"]) {
         NSArray *items = (NSArray *)[artists objectForKey:@"items"];
         if ([items count]) {
             NSDictionary *first = [items objectAtIndex:0];
             //NSLog(@"%@", first);
             NSArray *images = (NSArray *)[first objectForKey:@"images"];
             if ([images count]) {
                 NSURL *url = [NSURL URLWithString:[images[0] objectForKey:@"url"]];
                 NSURLRequest *request = [NSURLRequest requestWithURL:url];
                 
                 [_cover setImageWithURLRequest:request
                               placeholderImage:[UIImage imageNamed:@"cover.jpg"]
                                        success:^(NSURLRequest *request, NSHTTPURLResponse *response, UIImage *image) {
                                            [_cover setImage:image];
                                        }
                                        failure:^(NSURLRequest *request, NSHTTPURLResponse *response, NSError *error) {
                                            NSLog(@"%@", error);
                 }];

             }
         }
     }
 }

- (void) setNowPlayingTrack:(Track *)track {
    if ([MPNowPlayingInfoCenter class]) {
        NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
        NSArray *values = [NSArray arrayWithObjects:[track getTitle], [track getArtist], track.duration, [NSNumber numberWithInt:1], nil];
        NSDictionary *currentlyPlayingTrackInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
    }
}

- (void)_cancelStreamer {
    if (_streamer != nil) {
        NSLog(@"Streamer is not null, playing %@", _streamer);
        [_streamer pause];
        [_streamer removeObserver:self forKeyPath:@"status"];
        [_streamer removeObserver:self forKeyPath:@"duration"];
        [_streamer removeObserver:self forKeyPath:@"bufferingRatio"];
        _streamer = nil;
    }
}

- (void)_resetStreamer {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    //NSTimeInterval currentTime = [app.streamer currentTime];
    //app.streamer = nil;
    
    Track *track = [_tracks objectAtIndex:_currentTrackIndex];
    
    [self _cancelStreamer];
    
    [_titleLabel setText:[track getTitle]];
    [_artistLabel setText:[track getArtist]];
    if (app.currentTrack == track && app.streamer != nil) {
        _streamer = app.streamer;
    } else {
        _streamer = [DOUAudioStreamer streamerWithAudioFile:track];
        [track loadArtists:self];
    }
    
    [_streamer addObserver:self forKeyPath:@"status" options:NSKeyValueObservingOptionNew context:kStatusKVOKey];
    [_streamer addObserver:self forKeyPath:@"duration" options:NSKeyValueObservingOptionNew context:kDurationKVOKey];
    [_streamer addObserver:self forKeyPath:@"bufferingRatio" options:NSKeyValueObservingOptionNew context:kBufferingRatioKVOKey];
    
    if (app.currentTrack != track)  {
        [_streamer play];
    } else {
        [self _updateStatus];
    }
    
    [self setNowPlayingTrack:track];
    
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
    } else {
        [self _updateCurrentTimeLabel];
        [self _updateElapsedTimeLabel];
        [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
    }
}

- (void)_updateCurrentTimeLabel {
    int currentMinutes = (int) floor([_streamer currentTime] / 60);
    int currentSeconds = [_streamer currentTime] - (currentMinutes * 60);
    [_currentTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", currentMinutes, currentSeconds]];
}

- (void)_updateElapsedTimeLabel {
    int elapsedTime = (int) floor([_streamer duration]) - (int) floor([_streamer currentTime]);
    int elapsedMinutes = (int) floor(elapsedTime / 60);
    int elapsedSeconds = (int) (elapsedTime - elapsedMinutes * 60);
    [_elapsedTimeLabel setText:[NSString stringWithFormat:@"%d:%02d", elapsedMinutes, elapsedSeconds]];
}

- (void)_updateStatus {
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"Playing"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"mw_pause_4"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"Paused"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"mw_play_5"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"Idle"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"mw_play_5"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"Finished"];
            if ([_buttonRepeat isSelected]) _currentTrackIndex--;
            else if ([_buttonShuffle isSelected]) _currentTrackIndex = arc4random_uniform([_tracks count]) -1;
            [self _actionNext:nil];
            break;
            
        case DOUAudioStreamerBuffering:
            [_statusLabel setText:@"Buffering"];
            break;
            
        case DOUAudioStreamerError:
            [_statusLabel setText:@"Error"];
            break;
    }
}

- (void)_updateBufferingStatus {
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

- (BOOL)canBecomeFirstResponder {
    return YES;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    [self _resetStreamer];
    
    _timer = [NSTimer scheduledTimerWithTimeInterval:1.0 target:self selector:@selector(_timerAction:) userInfo:nil repeats:YES];
    [_volumeSlider setValue:[DOUAudioStreamer volume]];

    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];

    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    } else {
        NSLog(@"Cannot become first responder");
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    if (theEvent.type == UIEventTypeRemoteControl) {
        switch (theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self _actionPlayPause:self];
                break;
            case UIEventSubtypeRemoteControlPlay:
                [_streamer play];
                break;
            case UIEventSubtypeRemoteControlPause:
                [_streamer pause];
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
    
     [[NSNotificationCenter defaultCenter]
      postNotificationName:@"TestNotification"
      object:self.tracks[self.currentTrackIndex]];
     [[NSNotificationCenter defaultCenter]
      postNotificationName:@"TestNotificationStreamer"
      object:_streamer];
     
     [super viewWillDisappear:animated];
 }

- (void)_actionToggle:(id)sender {
    UIButton* button = (UIButton*)sender;
    button.selected = !button.selected;
    if (button.selected) button.highlighted = NO;
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
    [self _updateCurrentTimeLabel];
    [self _updateElapsedTimeLabel];
}

- (void)_actionSliderVolume:(id)sender {
    [DOUAudioStreamer setVolume:[_volumeSlider value]];
}

- (void)_actionDownload:(id)sender {
    Track *track = [_tracks objectAtIndex:_currentTrackIndex];
    //@todo prevent to download track twice
    [track downloadWithProgressBlock:^(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead) {
        float progress = (float)totalBytesRead / totalBytesExpectedToRead;
        if (progress < 1.0f) {
            [_statusLabel setText:[NSString stringWithFormat:@"Downloading: %.1f%%", progress * 100.0f]];
        } else if (progress == 1.0f) {
            [_statusLabel setText:@"Downloaded"];
        }
    }];
}

@end
