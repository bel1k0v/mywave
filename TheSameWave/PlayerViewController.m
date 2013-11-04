//
//  PlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//
#import "AppDelegate.h"
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
        self.title = NSLocalizedString(@"Audio", @"Audio");
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    // Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    
    self.lblMusicArtist.text = [NSString stringWithFormat:@"%@",
                                [self.song objectForKey:@"artist"]];
    self.lblMusicName.text = [NSString stringWithFormat:@"%@",
                              [self.song objectForKey:@"title"]];
    [self.scrubber setThumbImage:[UIImage imageNamed:@"position"] forState:UIControlStateNormal];
    
    NSURL *filePath;
    if ([NSURL URLWithString:[self.song objectForKey:@"url"]])
    {
        filePath = [NSURL URLWithString:[self.song objectForKey:@"url"]];
    }
    else
    {
        filePath = [NSURL fileURLWithPath:[self.song objectForKey:@"url"]];
        [self.btnDownload setEnabled:NO];
        [self.btnDownload setTitle:@"" forState:UIControlStateDisabled];
    }
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:filePath];
    
    if (!self.player)
    {
        AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
        self.player = app.player;
        
    }
    
    [self.player pause];
    
    [self.player replaceCurrentItemWithPlayerItem:item];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    
    [self.player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
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
    
    self.timeObserver = [self.player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                                  queue:dispatch_get_main_queue()
                                                             usingBlock:observerBlock];
    [self initScrubberTimer];
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
    }
    else
    {
        [self.player pause];
        [self.btnPlayPause setBackgroundImage:[UIImage imageNamed:@"play"] forState:UIControlStateNormal];
    }
}

- (IBAction)didTapDownload:(id)sender
{
    NSLog(@"Download %@", [self.song objectForKey:@"url"]);
    NSURL *url = [NSURL URLWithString:[self.song objectForKey:@"url"]];
    NSString *filename = [NSString stringWithFormat:@"%@ - %@.mp3", [self.song objectForKey:@"artist"], [self.song objectForKey:@"title"]];
    
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *path = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
    operation.outputStream = [NSOutputStream outputStreamToFileAtPath:path append:NO];
    
    [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
        NSLog(@"Successfully downloaded file to %@", path);
        
        DBManager *db = [DBManager getSharedInstance];
        if ([db saveData:[self.song objectForKey:@"artist"] title:[self.song objectForKey:@"title"] duration:[self.song objectForKey:@"duration"] filename:filename] == YES)
        {
            NSLog(@"Successfully saved to database");
        }
        
        NSString *successMessage = [NSString stringWithFormat:@"Successfully downloaded file to %@", path];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Downloaded" message:successMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
        NSString *errorMessage = [NSString stringWithFormat:@"Something wrong happened"];
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:errorMessage delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }];
    
    [operation start];
    
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
