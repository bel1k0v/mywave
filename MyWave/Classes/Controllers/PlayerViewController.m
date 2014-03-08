//
//  PlayerViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#import "PlayerViewController.h"
#import "DOUAudioStreamer.h"
#import "DOUAudioStreamer+Options.h"
#import "Track.h"
#import "NSString+HTML.h"
#import "DBManager.h"
#import "AFHTTPRequestOperation.h"
#import <MediaPlayer/MediaPlayer.h>

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
    UIButton *_buttonDownload;
    
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
    view.backgroundColor = UIColorFromRGB(0xF8F8F8);
    /*
    CAGradientLayer *gradient = [CAGradientLayer layer];
    gradient.frame = view.bounds;
    gradient.colors = [NSArray arrayWithObjects:(id)[UIColorFromRGB(0xF8F8F8) CGColor], (id)[UIColorFromRGB(0x18AAD6) CGColor], nil];
    [view.layer insertSublayer:gradient atIndex:0];
    */
    NSString *labelFontName = @"HelveticaNeue-CondensedBlack";
    
    CGFloat topPoint = 34.0;
    if ([[UIDevice currentDevice].systemVersion floatValue] > 6.1f) {
        topPoint = 84.0;
    }

    _titleLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, topPoint, CGRectGetWidth([view bounds]) - 40, 30.0)];
    [_titleLabel setFont:[UIFont fontWithName:labelFontName size:18.0]];
    [_titleLabel setTextColor:[UIColor blackColor]];
    [_titleLabel setTextAlignment:NSTextAlignmentCenter];
    [_titleLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_titleLabel];
    
    _artistLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_titleLabel frame]) + 10.0, CGRectGetWidth([view bounds]) - 40, 30.0)];
    [_artistLabel setFont:[UIFont fontWithName:labelFontName size:16.0]];
    [_artistLabel setTextColor:[UIColor blackColor]];
    [_artistLabel setTextAlignment:NSTextAlignmentCenter];
    [_artistLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_artistLabel];

    _statusLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_artistLabel frame]) + 10.0, CGRectGetWidth([view bounds]) - 40, 30.0)];
    [_statusLabel setFont:[UIFont fontWithName:labelFontName size:14.0]];
    [_statusLabel setTextColor:[UIColor darkGrayColor]];
    [_statusLabel setTextAlignment:NSTextAlignmentCenter];
    [_statusLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_statusLabel];
    
    _progressSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_statusLabel frame]) + 15.0, CGRectGetWidth([view bounds]) - 40.0, 40.0)];
    [_progressSlider addTarget:self action:@selector(_actionSliderProgress:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_progressSlider];
    
    _miscLabel = [[UILabel alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_progressSlider frame]) + 8.0, CGRectGetWidth([view bounds]) - 40, 20.0)];
    [_miscLabel setFont:[UIFont fontWithName:labelFontName size:10.0]];
    [_miscLabel setTextColor:[UIColor darkGrayColor]];
    [_miscLabel setTextAlignment:NSTextAlignmentCenter];
    [_miscLabel setLineBreakMode:NSLineBreakByTruncatingTail];
    [view addSubview:_miscLabel];
    
    /*
    _miscProgress = [[UIProgressView alloc] initWithFrame:CGRectMake(20, CGRectGetMaxY([_miscLabel frame]) + 10.0, 280, 3)];
    _miscProgress.progress = 0.0f;
    [view addSubview:_miscProgress];
    */
    
    _buttonPlayPause = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPlayPause setFrame:CGRectMake((CGRectGetWidth([view bounds]) - 99.0) / 2 , CGRectGetMaxY([_miscLabel frame]) + 10.0, 99.0, 99.0)];
    [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    [_buttonPlayPause addTarget:self action:@selector(_actionPlayPause:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPlayPause];
    
    _buttonNext = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonNext setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 20.0 - 53.0, CGRectGetMinY([_buttonPlayPause frame]), 53.0, 53.0)];
    [_buttonNext setBackgroundImage:[UIImage imageNamed:@"arrow_right"] forState:UIControlStateNormal];
    [_buttonNext addTarget:self action:@selector(_actionNext:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonNext];
    
    if (self.tracksFromRemote == YES) {
        _buttonDownload = [UIButton buttonWithType:UIButtonTypeSystem];
        [_buttonDownload setFrame:CGRectMake(CGRectGetWidth([view bounds]) - 20.0 - 32.0, CGRectGetMaxY([_buttonNext frame]) + 10.0, 32.0, 32.0)];
        [_buttonDownload setBackgroundImage:[UIImage imageNamed:@"plus"] forState:UIControlStateNormal];
        [_buttonDownload addTarget:self action:@selector(_actionDownload:) forControlEvents:UIControlEventTouchDown];
        [view addSubview:_buttonDownload];
    }
    
    _buttonPrevious = [UIButton buttonWithType:UIButtonTypeSystem];
    [_buttonPrevious setFrame:CGRectMake(20, CGRectGetMinY([_buttonPlayPause frame]), 53.0, 53.0)];
    [_buttonPrevious setBackgroundImage:[UIImage imageNamed:@"arrow_left"] forState:UIControlStateNormal];
    [_buttonPrevious addTarget:self action:@selector(_actionPrevious:) forControlEvents:UIControlEventTouchDown];
    [view addSubview:_buttonPrevious];
    
    _volumeSlider = [[UISlider alloc] initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_buttonPlayPause frame]) + 10.0, CGRectGetWidth([view bounds]) - 40.0, 40.0)];
    [_volumeSlider addTarget:self action:@selector(_actionSliderVolume:) forControlEvents:UIControlEventValueChanged];
    [view addSubview:_volumeSlider];

    [[UISlider appearance] setMaximumTrackImage:[UIImage imageNamed:@"slider_max"]
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setMinimumTrackImage:[UIImage imageNamed:@"slider_min"]
                                       forState:UIControlStateNormal];
    [[UISlider appearance] setThumbImage:[UIImage imageNamed:@"position"]
                                forState:UIControlStateNormal];
    /*
    [[UIProgressView appearance] setProgressTintColor:[UIColor whiteColor]];
    [[UIProgressView appearance] setTrackTintColor:UIColorFromRGB(0x136f8a)];
    */
    if ([[UIDevice currentDevice].systemVersion floatValue] < 7.0f) {
        [_titleLabel setBackgroundColor:[UIColor clearColor]];
        [_artistLabel setBackgroundColor:[UIColor clearColor]];
        [_miscLabel setBackgroundColor:[UIColor clearColor]];
        [_statusLabel setBackgroundColor:[UIColor clearColor]];
    }
    
    [self setView:view];
}
- (void) setNowPlayingTrack:(Track *)track
{
    if ([MPNowPlayingInfoCenter class]) {
        NSArray *keys = [NSArray arrayWithObjects:MPMediaItemPropertyTitle, MPMediaItemPropertyArtist, MPMediaItemPropertyPlaybackDuration, MPNowPlayingInfoPropertyPlaybackRate, nil];
        NSArray *values = [NSArray arrayWithObjects:track.title, track.artist, track.duration, [NSNumber numberWithInt:1], nil];
        NSDictionary *currentlyPlayingTrackInfo = [NSDictionary dictionaryWithObjects:values forKeys:keys];
        
        [MPNowPlayingInfoCenter defaultCenter].nowPlayingInfo = currentlyPlayingTrackInfo;
    }
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
    [self setNowPlayingTrack:track];
    
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
    } else {
        //int minutes = (int) floor([_streamer duration] / 60);
        //int seconds = [_streamer duration] - (minutes * 60);

        int currentMinutes = (int) floor([_streamer currentTime] / 60);
        int currentSeconds = [_streamer currentTime] - (currentMinutes * 60);

        [_miscLabel setText:[NSString stringWithFormat:@"%d:%02d", currentMinutes, currentSeconds]];
        [_progressSlider setValue:[_streamer currentTime] / [_streamer duration] animated:YES];
    }
}

- (void)_updateStatus {
    switch ([_streamer status]) {
        case DOUAudioStreamerPlaying:
            [_statusLabel setText:@"Playing"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerPaused:
            [_statusLabel setText:@"Paused"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerIdle:
            [_statusLabel setText:@"Idle"];
            [_buttonPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
            break;
            
        case DOUAudioStreamerFinished:
            [_statusLabel setText:@"Finished"];
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
    _miscProgress.progress = (float) [_streamer receivedLength] / [_streamer expectedLength];
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

- (void)_actionDownload:(id)sender {
    Track *track = [_tracks objectAtIndex:_currentTrackIndex];
    DBManager *db = [DBManager getSharedInstance];
    if ([db findByTitle:track.title andArtist:track.artist] != nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You already have this track"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSURL *url = track.audioFileURL;
        NSString *filename = [NSString stringWithFormat:@"%@ - %@.mp3", track.artist, track.title];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
        
        [operation setDownloadProgressBlock:^(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead) {
            float progress = (float)totalBytesRead / totalBytesExpectedToRead;
            if (progress < 1.0f) {
                [_statusLabel setText:@"Downloading"];
            } else if (progress == 1.0f) {
                [_statusLabel setText:@"Downloaded"];
            }
            
            NSLog(@"%f", progress);
        }];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (YES == [db saveData:track.artist title:track.title duration:track.duration filename:filename]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ok"
                                                                message:@"Saved"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Please try again later"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSFileManager defaultManager]removeItemAtPath:filepath error:&error];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please try again later"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
        
        [operation start];
    }
}

@end
