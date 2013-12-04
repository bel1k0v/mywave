//
//  PlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//
#import "NSString+Gender.h"
#import "PlayerViewController.h"
#import "AFHTTPRequestOperation.h"
#import "DBManager.h"
#import "AppDelegate.h"

@implementation PlayerViewController
@synthesize classNameRef = _classNameRef;

static void *PlayerItemStatusContext = &PlayerItemStatusContext;

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Плеер";
        
    }
    return self;
}


-(void)updateUserInterface
{
    NSString *artist = [NSString htmlEntityDecode:[NSString stringWithFormat:@"%@",
                                               [_song objectForKey:@"artist"]]];
    NSString *title = [NSString htmlEntityDecode:[NSString stringWithFormat:@"%@",
                                              [_song objectForKey:@"title"]]];
    _lblMusicArtist.text = artist;
    _lblMusicName.text = title;
    
    if ([_classNameRef isEqualToString:@"Downloaded"])
        [self.btnDownload setEnabled:NO];

    [_scrubber setValue:0];
    [_scrubber setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    double duration = [[_song objectForKey:@"duration"]doubleValue];
    int minutes = (int) floor(duration / 60);
    int seconds = duration - (minutes * 60);
    NSString *durationLabel = [NSString stringWithFormat:@"0:00 - %d:%02d", minutes, seconds];
    [_lblMusicTime setText:durationLabel];
}

- (BOOL)increaseSongNumber
{
    int temp;
    temp = self->currentSong +1;
    NSLog(@"%d", temp);
    if (temp >= 0 && (temp <= ([_songs count] -1)))
    {
        self->currentSong++;
        return YES;
    }
    else
    {
        NSLog(@"Wrong song number");
    }
    return NO;
}

- (void)itemDidFinishPlaying
{
    [_player removeTimeObserver:_timeObserver];
    [self removePlayerProgressObserver];
    [_player removeAllItems];
    _currentItem = nil;
    
    if ([self increaseSongNumber] == YES)
    {
        _song = [_songs objectAtIndex:self->currentSong];
        
        [self updateUserInterface];
        [self prepareAssetAndInitPlayer];
    }
}

- (void) prepareAssetAndInitPlayer
{
    [_btnNext setEnabled:NO];
    [_btnPrev setEnabled:NO];
    [_btnPlayPause setEnabled:NO];
    [_btnDownload setEnabled:NO];
    
    AppDelegate *delegate = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    _player = delegate.player;
    
    AVURLAsset *asset = [AVURLAsset URLAssetWithURL:[self getSongFilePath] options:nil];
    NSArray *requestedKeys = [NSArray arrayWithObjects:@"tracks", @"playable", nil];
    NSLog(@"%@", asset);
    
    [asset loadValuesAsynchronouslyForKeys:requestedKeys completionHandler:
     ^{
         dispatch_async(dispatch_get_main_queue(),
            ^{
                NSError *error = nil;
                AVKeyValueStatus status = [asset statusOfValueForKey:@"tracks" error:&error];
                
                if (status == AVKeyValueStatusLoaded)
                {
                    delegate.currentSong = _song;
                    NSLog(@"Asset loaded");
                    _currentItem = [AVPlayerItem playerItemWithAsset:asset];
                    [[NSNotificationCenter defaultCenter] addObserver:self
                                                             selector:@selector(itemDidFinishPlaying)
                                                                 name:AVPlayerItemDidPlayToEndTimeNotification object:_currentItem];
                    if (_player == nil) _player = [[AVQueuePlayer alloc]init];
                    else [_player pause];
                    
                    [_player replaceCurrentItemWithPlayerItem:_currentItem];
                    //NSLog(@"%@", _player.currentItem);
                    
                    [_currentItem addObserver:self
                                   forKeyPath:@"status"
                                      options:0
                                      context:PlayerItemStatusContext];
                }
                else
                {
                    NSLog(@"Error: %d", status);
                }
            });
     }];
}


- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if (context == PlayerItemStatusContext) {
        dispatch_async(dispatch_get_main_queue(),
                       ^{
                           NSLog(@"Start Playing!");
                           [_btnNext setEnabled:YES];
                           [_btnPrev setEnabled:YES];
                           [_btnPlayPause setEnabled:YES];
                           if (![_classNameRef isEqualToString:@"Downloaded"])
                               [_btnDownload setEnabled:YES];
                           [self setTimer];
                           [self initScrubberTimer];
                           [_player play];
                           if (_btnPlayPause.selected)
                           {
                               [_player play];
                               [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
                           }
                           else
                           {
                               [_player pause];
                               [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
                           }
                       });
    } else {
        NSLog(@"%@", context);
        [super observeValueForKeyPath:keyPath ofObject:object change:change
                              context:context];
    }
}

- (void)remoteControlReceivedWithEvent:(UIEvent *)theEvent
{
    if (theEvent.type == UIEventTypeRemoteControl)
    {
        switch(theEvent.subtype) {
            case UIEventSubtypeRemoteControlTogglePlayPause:
                NSLog(@"TogglePlayPause");
                [self playPause];
                return;
                
            case UIEventSubtypeRemoteControlPlay:
                NSLog(@"TogglePlay");
                [_player play];
                return;
            case UIEventSubtypeRemoteControlPause:
                NSLog(@"TogglePause");
                //[_player pause];
                return;
            case UIEventSubtypeRemoteControlStop:
                NSLog(@"ToggleStop");
                return;
                //Insert code.
            case UIEventSubtypeRemoteControlNextTrack:
                NSLog(@"ToggleNext");
                [self next];
                return;
            case UIEventSubtypeRemoteControlPreviousTrack:
                NSLog(@"TogglePrevious");
                [self previous];
                return;
            default:
                NSLog(@"Other");
                return;
        }
    }
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:nil];
    [[AVAudioSession sharedInstance] setActive: YES error: nil];
    
    [[UIApplication sharedApplication] beginReceivingRemoteControlEvents];
    if ([self canBecomeFirstResponder]) {
        [self becomeFirstResponder];
    }
    
    [self updateUserInterface];
    [self prepareAssetAndInitPlayer];

    self.btnPlayPause.selected = YES;
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)setTimer
{
    if(_timeObserver)
    {
        _timeObserver = nil;
    }
    
    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        double progress = (double)time.value / (double)time.timescale;
		double duration = [[self.song objectForKey:@"duration"] doubleValue];
        double secondsLeft = duration - progress;
        
        int leftMinutes = (int) floor(secondsLeft / 60);
        int leftMinuteSeconds = (int) secondsLeft - leftMinutes * 60;
        
        int progressMinutes = (int) floor(progress / 60);
        int progressMinuteSeconds = (int) progress - progressMinutes * 60;
        
        NSString *timeString = [NSString stringWithFormat:@"%d:%02d - %d:%02d",
                                progressMinutes,
                                progressMinuteSeconds,
                                leftMinutes,
                                leftMinuteSeconds];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            self.lblMusicTime.text = timeString;
        } else {
            //NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                          queue:dispatch_get_main_queue()
                                                     usingBlock:observerBlock];
}

- (NSURL *)getSongFilePath
{
    if ([NSURL URLWithString:[_song objectForKey:@"url"]])
        return [NSURL URLWithString:[_song objectForKey:@"url"]];
    else
        return [NSURL fileURLWithPath:[_song objectForKey:@"url"]];

}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapPlayPause:(id)sender
{
    [self playPause];
}

- (void) playPause
{
    _btnPlayPause.selected = !_btnPlayPause.selected;
    
    if (_btnPlayPause.selected)
    {
        [_player play];
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
    }
    else
    {
        [_player pause];
        [_btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (IBAction)didTapDownload:(id)sender
{
    [self.btnDownload setEnabled:NO];
    DBManager *db = [DBManager getSharedInstance];
    if ([db findByTitle:[self.song objectForKey:@"title"] andArtist:[self.song objectForKey:@"artist"]] != nil)
    {
        NSString *errorMessage = [NSString stringWithFormat:@"У вас уже загружена эта песня."];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Предупреждение" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.btnDownload setEnabled:YES];
    }
    else
    {
        NSLog(@"Start download");
        NSDictionary *song = _song;
        NSURL *url = [NSURL URLWithString:[song objectForKey:@"url"]];
        NSString *filename = [NSString stringWithFormat:@"%@ - %@.mp3", [song objectForKey:@"artist"], [song objectForKey:@"title"]];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if ([db saveData:[song objectForKey:@"artist"] title:[song objectForKey:@"title"] duration:[song objectForKey:@"duration"] filename:filename] == YES)
            {
                NSLog(@"Successfully saved to database and saved to: %@", path);
                NSString *successMessage = [NSString stringWithFormat:@"Файл успешно скачан в папку приложения"];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Поздравляю!" message:successMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [_btnDownload setEnabled:NO];
            }
            else
            {
                NSError *error = nil;
                [[NSFileManager defaultManager]removeItemAtPath:path error:&error];
                NSLog(@"Remove file, %@", error);
                NSString *successMessage = [NSString stringWithFormat:@"Something wrong happened"];
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:successMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
                [_btnDownload setEnabled:YES];
            }
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            NSString *errorMessage = [NSString stringWithFormat:@"Something wrong happened"];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ошибка" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
            [alert show];
            [_btnDownload setEnabled:YES];
        }];
        
        [operation start];
    }
}

- (IBAction)didTapNext:(id)sender
{
    [self next];
}

- (void) next
{
    NSLog(@"%d", self->currentSong);
    [self itemDidFinishPlaying];
}

- (IBAction)didTapPrev:(id)sender
{
    [self previous];
}

- (void) previous
{
    int temp = self->currentSong - 2;
    if (temp >= -1 && self->currentSong != 0)
    {
        self->currentSong = self->currentSong - 2;
        [self itemDidFinishPlaying];
    }
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [_player currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}

#pragma mark Scrubber control

/* ---------------------------------------------------------
 **  Methods to handle manipulation of the movie scrubber control
 ** ------------------------------------------------------- */

/* Requests invocation of a given block during media playback to update the movie scrubber control. */
-(void)initScrubberTimer
{
	double interval = .1f;
	
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		return;
	}
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		CGFloat width = CGRectGetWidth([self.scrubber bounds]);
		interval = 0.5f * duration / width;
	}
    
	/* Update the scrubber during normal playback. */
	[self createPlayerProgressObserver:interval];
}

/* Set the scrubber based on the player current time. */
- (void)syncScrubber
{
	CMTime playerDuration = [self playerItemDuration];
	if (CMTIME_IS_INVALID(playerDuration))
	{
		self.scrubber.minimumValue = 0.0;
		return;
	}
    
	double duration = CMTimeGetSeconds(playerDuration);
	if (isfinite(duration))
	{
		float minValue = [self.scrubber minimumValue];
		float maxValue = [self.scrubber maximumValue];
		double time = CMTimeGetSeconds([self.player currentTime]);
		
		[self.scrubber setValue:(maxValue - minValue) * time / duration + minValue];
	}
}

/* The user is dragging the movie controller thumb to scrub through the movie. */
- (IBAction)beginScrubbing:(id)sender
{
	restoreAfterScrubbingRate = [self.player rate];
	[self.player setRate:0.f];
	
	/* Remove previous timer. */
	[self removePlayerProgressObserver];
}

-(void)removePlayerProgressObserver
{
	if (self.progressObserver)
	{
		[self.player removeTimeObserver:self.progressObserver];
		self.progressObserver = nil;
	}
}
-(void)createPlayerProgressObserver:(double)interval
{
    if (!self.progressObserver)
    {
        void (^progressBlock)(CMTime time) = ^(CMTime time) {
            [self syncScrubber];
        };
        self.progressObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMakeWithSeconds(interval, NSEC_PER_SEC)
                                                                          queue:NULL
                                                                    usingBlock:progressBlock];
    }
}

/* Set the player current time to match the scrubber position. */
- (IBAction)scrub:(id)sender
{
	if ([sender isKindOfClass:[UISlider class]])
	{
		UISlider* slider = sender;
		
		CMTime playerDuration = [self playerItemDuration];
		if (CMTIME_IS_INVALID(playerDuration)) {
			return;
		}
		
		double duration = CMTimeGetSeconds(playerDuration);
		if (isfinite(duration))
		{
			float minValue = [slider minimumValue];
			float maxValue = [slider maximumValue];
			float value = [slider value];
			
			double time = duration * (value - minValue) / (maxValue - minValue);
			
			[self.player seekToTime:CMTimeMakeWithSeconds(time, NSEC_PER_SEC)];
		}
	}
}

/* The user has released the movie thumb control to stop scrubbing through the movie. */
- (IBAction)endScrubbing:(id)sender
{
    CMTime playerDuration = [self playerItemDuration];
    if (CMTIME_IS_INVALID(playerDuration))
    {
        return;
    }
    
    double duration = CMTimeGetSeconds(playerDuration);
    if (isfinite(duration))
    {
        CGFloat width = CGRectGetWidth([self.scrubber bounds]);
        double tolerance = 0.5f * duration / width;
        [self createPlayerProgressObserver:tolerance];
    }
    
	if (restoreAfterScrubbingRate)
	{
		[self.player setRate:restoreAfterScrubbingRate];
		restoreAfterScrubbingRate = 0.f;
	}
}

- (BOOL)isScrubbing
{
	return restoreAfterScrubbingRate != 0.f;
}

-(void)enableScrubber
{
    self.scrubber.enabled = YES;
}

-(void)disableScrubber
{
    self.scrubber.enabled = NO;
}

@end
