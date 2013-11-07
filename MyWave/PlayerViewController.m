//
//  PlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//
//#import "AppDelegate.h"
#import "PlayerViewController.h"
#import "AFHTTPRequestOperation.h"
#import "DBManager.h"

@interface PlayerViewController ()

@property (nonatomic, strong) AVQueuePlayer *player;
@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) id progressObserver;
@end

@implementation PlayerViewController
- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        self.title = @"Плеер";
        
    }
    return self;
}

- (void)viewWillDisappear:(BOOL)animated
{
    [self dismissViewControllerAnimated:animated completion:nil];
    [_player removeAllItems];
    _player = nil;
}

- (BOOL)increaseSongNumber
{
    int temp;
    temp = self->currentSong +1;
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
    if ([self increaseSongNumber] == YES)
    {
        [self removePlayerProgressObserver];
        [_player pause];
        _song = [_songs objectAtIndex:self->currentSong];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[self getSongFilePath]];
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:item];
        
        [self updateUserInterface];
        
        _player = nil;
        _player = [[AVQueuePlayer alloc]initWithPlayerItem:item];
        _player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
        
        [_player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
        
        [self setTimer];
        [_player play];
    }
}


- (void)viewDidLoad
{
    [super viewDidLoad];

    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    // Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    UInt32 otherAudioIsPlaying;
    UInt32 propertySize = sizeof (otherAudioIsPlaying);
    AudioSessionGetProperty(kAudioSessionProperty_OtherAudioIsPlaying, &propertySize, &otherAudioIsPlaying);
    
    if (otherAudioIsPlaying) {
        NSLog(@"Audio");
        [[AVAudioSession sharedInstance]
         setCategory: AVAudioSessionCategoryAmbient
         error: nil];
    } else {
        [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayback error:&sessionError];
    }
    
    [self updateUserInterface];
    [self.scrubber setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[self getSongFilePath]];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(itemDidFinishPlaying) name:AVPlayerItemDidPlayToEndTimeNotification object:item];

    _player = [[AVQueuePlayer alloc]initWithPlayerItem:item];
    _player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    [_player addObserver:self
              forKeyPath:@"currentItem"
                 options:NSKeyValueObservingOptionNew
                 context:nil];
    
    [self setTimer];
}

-(void)updateUserInterface
{
    self.lblMusicArtist.text = [NSString stringWithFormat:@"%@",
                                [self.song objectForKey:@"artist"]];
    self.lblMusicName.text = [NSString stringWithFormat:@"%@",
                              [self.song objectForKey:@"title"]];
    
    //[self.btnDownload setEnabled:NO];
    //[self.btnDownload setTitle:@"" forState:UIControlStateDisabled];
    [self.scrubber setValue:0];
    [self.lblMusicTime setText:@"0:00 - 0:00"];
}

-(void)setTimer
{
    if(self.timeObserver)
    {
        _timeObserver = nil;
    }
    
    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        double progress = (double)time.value / (double)time.timescale;
		double duration = [[self.song objectForKey:@"duration"] doubleValue];
        double secondsLeft = duration - progress;
        
        int leftMinutes = (int) floor(secondsLeft/60);
        int leftMinuteSeconds = (int) secondsLeft - leftMinutes * 60;
        
        int progressMinutes = (int) floor(progress/60);
        int progressMinuteSeconds = (int) progress - progressMinutes * 60;
        
        NSString *timeString = [NSString stringWithFormat:@"%d:%02d - %d:%02d",
                                progressMinutes,
                                progressMinuteSeconds,
                                leftMinutes,
                                leftMinuteSeconds];
        
        if ([[UIApplication sharedApplication] applicationState] == UIApplicationStateActive) {
            self.lblMusicTime.text = timeString;
        } else {
            NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                          queue:dispatch_get_main_queue()
                                                     usingBlock:observerBlock];
}

- (NSURL *)getSongFilePath
{
    NSURL *filePath;
    if ([NSURL URLWithString:[_song objectForKey:@"url"]])
    {
        filePath = [NSURL URLWithString:[_song objectForKey:@"url"]];
    }
    else
    {
        filePath = [NSURL fileURLWithPath:[_song objectForKey:@"url"]];
    }
    
    return filePath;
}

- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context
{
    if ([keyPath isEqualToString:@"currentItem"]) // Item Changed
    {
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)didTapPlayPause:(id)sender
{
    self.btnPlayPause.selected = !self.btnPlayPause.selected;
    
    if (self.btnPlayPause.selected)
    {
        [self.player play];
        [self.btnPlayPause setBackgroundImage:[UIImage imageNamed:@"pause"] forState:UIControlStateSelected];
        
        [self initScrubberTimer];
    }
    else
    {
        [self.player pause];
        [self.btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (IBAction)didTapDownload:(id)sender
{
    [self.btnDownload setEnabled:NO];
    NSURL *url = [NSURL URLWithString:[self.song objectForKey:@"url"]];
    NSString *filename = [NSString stringWithFormat:@"%@ - %@.mp3", [self.song objectForKey:@"artist"], [self.song objectForKey:@"title"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        DBManager *db = [DBManager getSharedInstance];
        if ([db saveData:[self.song objectForKey:@"artist"] title:[self.song objectForKey:@"title"] duration:[self.song objectForKey:@"duration"] filename:filename] == YES)
        {
            NSLog(@"Successfully saved to database");
        }
        
        NSString *successMessage = [NSString stringWithFormat:@"Successfully downloaded file to %@", path];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Downloaded" message:successMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        
        [self.btnDownload setEnabled:YES];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Something wrong happened"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
        [self.btnDownload setEnabled:YES];
    }];
    
    [operation start];
    
}

- (IBAction)didTapNext:(id)sender
{
    [self itemDidFinishPlaying];
}

- (IBAction)didTapPrev:(id)sender
{
    int temp = self->currentSong - 2;
    if (temp > -1)
        self->currentSong = self->currentSong - 2;
    [self itemDidFinishPlaying];
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.player currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
		return([playerItem duration]);
	}
	
	return(kCMTimeInvalid);
}

#pragma mark -
#pragma mark Movie scrubber control

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
