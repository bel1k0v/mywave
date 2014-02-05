//
//  PlayerViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "NSString+Gender.h"
#import "PlayerViewController.h"
#import "AFHTTPRequestOperation.h"
#import "DBManager.h"
#import "SoundManager.h"

@implementation PlayerViewController

@synthesize
    classNameRef = _classNameRef,
    player = _player,
    songs = _songs,
    song = _song,
    currentItem = _currentItem,
    progressObserver = _progressObserver,
    lblMusicArtist = _lblMusicArtist,
    lblMusicName = _lblMusicName,
    lblMusicTime = _lblMusicTime,
    btnDownload = _btnDownload,
    btnNext = _btnNext,
    btnPrev = _btnPrev,
    btnPlayPause = _btnPlayPause,
    scrubber = _scrubber;

static void *PlayerItemStatusContext = &PlayerItemStatusContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Плеер";
        
    }
    return self;
}

- (SoundManager *)soundManager
{
    SoundManager *sharedInstance = [SoundManager sharedInstance];
    return sharedInstance;
}

- (void)updateUserInterface {
    if ([_classNameRef isEqualToString:@"MyMusic"])
        [_btnDownload removeFromSuperview];
    
    [_lblMusicArtist setText:[NSString htmlEntityDecode:[NSString stringWithFormat:@"%@",
                                               [_song objectForKey:@"artist"]]]];
    [_lblMusicName setText:[NSString htmlEntityDecode:[NSString stringWithFormat:@"%@",
                                              [_song objectForKey:@"title"]]]];
    
    double duration = [[_song objectForKey:@"duration"]doubleValue];
    int minutes = (int) floor(duration / 60);
    int seconds = duration - (minutes * 60);
    NSString *durationLabel = [NSString stringWithFormat:@"0:00 - %d:%02d", minutes, seconds];
    [_lblMusicTime setText:durationLabel];
    
    [_scrubber setValue:0];
    [_scrubber setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
}

- (BOOL)canIncreaseSongNumber {
    int temp;
    temp = self->currentSong +1;
    return (temp >= 0 && (temp < [_songs count])) ? YES : NO;
}

- (void) setButtonsDisabled {
    [_btnNext setEnabled:NO];
    [_btnPrev setEnabled:NO];
    [_btnPlayPause setEnabled:NO];
    [_btnDownload setEnabled:NO];
}

- (void) setButtonsEnabled {
    [_btnNext setEnabled:YES];
    [_btnPrev setEnabled:YES];
    [_btnPlayPause setEnabled:YES];
    if (![_classNameRef isEqualToString:@"MyMusic"])
        [_btnDownload setEnabled:YES];
}

- (void) prepareAssetAndInitPlayer {
    SoundManager *soundManager = [self soundManager];
    _player = soundManager.player;
    
    NSDictionary *nowPlaying = [soundManager playingSong];
    
    // Continue Playing
    if ([[nowPlaying objectForKey:@"url"]isEqualToString:[_song objectForKey:@"url"]] == YES) {
        [soundManager setTimer];
        soundManager.delegate = self;
        [self initScrubberTimer];
        return ;
    }
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self getSongFilePath] options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];

    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:^{
         dispatch_async(dispatch_get_main_queue(), ^{
            NSError *error = nil;
            AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks"
                                                           error:&error];
            if (status == AVKeyValueStatusLoaded) {
                [_player pause];
                _currentItem = [AVPlayerItem playerItemWithAsset:asset];
                [_currentItem addObserver:self
                               forKeyPath:@"status"
                                  options:0
                                  context:PlayerItemStatusContext];
                [_player replaceCurrentItemWithPlayerItem:_currentItem];
            
                NSNotificationCenter *nc = [NSNotificationCenter defaultCenter];
                [nc addObserver:self
                       selector:@selector(itemDidFinishPlaying)
                           name:AVPlayerItemDidPlayToEndTimeNotification
                         object:_currentItem];
            } else NSLog(@"Error: %d", status);
        });
     }];
}

- (void)itemDidFinishPlaying {
    if ([self canIncreaseSongNumber] == YES) {
        self->currentSong++;
        SoundManager *soundManager = [self soundManager];
        [soundManager removeTimer];
        [self removePlayerProgressObserver];
        [_player removeAllItems];
        
        _currentItem = nil;
        _song = [_songs objectAtIndex:self->currentSong];
        
        [self updateUserInterface];
        [self setButtonsDisabled];
        [self prepareAssetAndInitPlayer];
    }
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context
{
    if (context == PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(), ^{
            // Start Playing
            [self setButtonsEnabled];
            
            SoundManager *soundManager = [self soundManager];
            [soundManager setTimer];
            soundManager.currentSong = _song;
            soundManager.delegate = self;
            [self initScrubberTimer];
            [_player play];
            if (_btnPlayPause.selected) {
                [_player play];
                [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"]
                                         forState:UIControlStateSelected];
            } else {
                [_player pause];
                [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"]
                                         forState:UIControlStateNormal];
            }
        });
    } else {
        [super observeValueForKeyPath:keyPath
                             ofObject:object
                               change:change
                              context:context];
    }
}

- (void)viewDidLoad {
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                              target:self
                                                                              action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    [self updateUserInterface];
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive:YES error:nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    // Headphones controls @see (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    [self prepareAssetAndInitPlayer];
    self.btnPlayPause.selected = YES;
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent {
    if (theEvent.type == UIEventTypeRemoteControl) {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                [self playPause];
                return;
            case UIEventSubtypeRemoteControlPlay:
                [self playPause];
                return;
            case UIEventSubtypeRemoteControlPause:
                [self playPause];
                return;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"ToggleStop");
                return;
            case UIEventSubtypeRemoteControlNextTrack:
                [self next];
                return;
            case UIEventSubtypeRemoteControlPreviousTrack:
                [self previous];
                return;
            default:
                NSLog(@"Other");
                return;
        }
    }
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}

- (NSURL *)getSongFilePath {
    if ([NSURL URLWithString:[_song objectForKey:@"url"]])
        return [NSURL URLWithString:[_song objectForKey:@"url"]];
    else
        return [NSURL fileURLWithPath:[_song objectForKey:@"url"]];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapPlayPause:(id)sender {
    [self playPause];
}

- (void) playPause {
    _btnPlayPause.selected = !_btnPlayPause.selected;
    if (_btnPlayPause.selected) {
        [_player play];
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"]
                                 forState:UIControlStateSelected];
    } else {
        [_player pause];
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"]
                                 forState:UIControlStateNormal];
    }
}

- (IBAction)didTapDownload:(id)sender {
    [_btnDownload setEnabled:NO];
    
    DBManager *db = [DBManager getSharedInstance];
    if ([db findByTitle:[_song objectForKey:@"title"] andArtist:[_song objectForKey:@"artist"]] != nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение"
                                                        message:@"У вас уже загружена эта песня."
                                                       delegate:nil
                                              cancelButtonTitle:@"OK"
                                              otherButtonTitles:nil];
        [alert show];
        [_btnDownload setEnabled:YES];
    } else {
        NSDictionary *song = _song;
        NSURL *url = [NSURL URLWithString:[song objectForKey:@"url"]];
        NSString *filename = [NSString stringWithFormat:@"%@ - %@.mp3", [song objectForKey:@"artist"], [song objectForKey:@"title"]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([db saveData:[song objectForKey:@"artist"]
                       title:[song objectForKey:@"title"]
                    duration:[song objectForKey:@"duration"]
                    filename:filename] == YES)
            {
                NSLog(@"Successfully saved to database and saved to: %@", path);
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"OK"
                                                                message:@"Песня загружена"
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [_btnDownload setEnabled:NO];
            } else {
                NSError *error = nil;
                [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
                NSLog(@"Remove file, %@", error);
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                                message:@"Something wrong happened. Database error."
                                                               delegate:nil
                                                      cancelButtonTitle:@"OK"
                                                      otherButtonTitles:nil];
                [alert show];
                [_btnDownload setEnabled:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка"
                                                            message:@"Something wrong happened"
                                                           delegate:nil
                                                  cancelButtonTitle:@"OK"
                                                  otherButtonTitles:nil];
            [alert show];
            [_btnDownload setEnabled:YES];
        }];
        [operation start];
    }
}

- (IBAction)didTapNext:(id)sender {
    [self next];
}

- (void) next {
    [self itemDidFinishPlaying];
}

- (IBAction)didTapPrev:(id)sender {
    [self previous];
}

- (void) previous {
    if (self->currentSong) {
        int temp = self->currentSong - 2;
        if (temp >= -1) {
            self->currentSong = self->currentSong - 2;
            [self itemDidFinishPlaying];
        } else return ;
    } else return ;
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration {
	AVPlayerItem *playerItem = [_player currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay) {
		return([playerItem duration]);
	}
	return(kCMTimeInvalid);
}

#pragma mark Scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer {
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration)) {
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration)) {
		CGFloat width = CGRectGetWidth([_scrubber bounds]);
		interval = 0.5f * duration / width;
	}
    
	/* Update the scrubber during normal playback. */
	[self createPlayerProgressObserver:interval];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber {
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration)) {
		_scrubber.minimumValue = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration)) {
		float minValue = [_scrubber minimumValue];
		float maxValue = [_scrubber maximumValue];
		double time = CMTimeGetSeconds([_player currentTime]);
		
		[_scrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender {
	restoreAfterScrubbingRate = [_player rate];
	[_player setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerProgressObserver];
}

-(void)removePlayerProgressObserver {
	if (_progressObserver) {
		[_player removeTimeObserver:_progressObserver];
		_progressObserver = nil;
	}
}
-(void)createPlayerProgressObserver:(double)interval {
    if (!_progressObserver) {
        void (^progressBlock)(CMTime time) = ^(CMTime time) {
            [self syncScrubber];
        };
        _progressObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                          queue:NULL
                                                                    usingBlock:progressBlock];
    }
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender {
	if ([sender isKindOfClass:[UISlider class]]) {
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration)) {
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			
			[_player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
		}
	}
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration)) {
        return;
    }
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration)) {
        CGFloat width = CGRectGetWidth([_scrubber bounds]);
        double tolerance = 0.5f * duration / width;
        [self createPlayerProgressObserver:tolerance];
    }
    
	if (restoreAfterScrubbingRate) {
		[_player setRate:restoreAfterScrubbingRate];
		restoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing {
	return restoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber {
    _scrubber.enabled = YES;
}

-(void)disableScrubber {
    _scrubber.enabled = NO;
}

@end
