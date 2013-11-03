//
//  PlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//
#import "AppDelegate.h"
#import "PlayerViewController.h"


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
    self.navigationItem.leftBarButtonItem.title = @"Back";
    self.navigationItem.title = [self.song objectForKey:@"artist"];
    // Set AVAudioSession
    NSError *sessionError = nil;
    [[AVAudioSession sharedInstance] setDelegate:self];
    [[AVAudioSession sharedInstance] setCategory:AVAudioSessionCategoryPlayAndRecord error:&sessionError];
    
    // Change the default output audio route
    UInt32 doChangeDefaultRoute = 1;
    AudioSessionSetProperty(kAudioSessionProperty_OverrideCategoryDefaultToSpeaker, sizeof(doChangeDefaultRoute), &doChangeDefaultRoute);
    
    self.lblMusicName.text = [NSString stringWithFormat:@"%@",
                              [self.song objectForKey:@"title"]];
    AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.song objectForKey:@"url"]]];
    
    //NSArray *queue = @[item];
    
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication] delegate];
    self.player = app.player;
    [self.player removeAllItems];
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
        
        if (leftMinutes <= 0 && leftMinuteSeconds <= 0)
        {
            [self.player pause];
        }
        
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
    if ([keyPath isEqualToString:@"currentItem"])
    {
        AVPlayerItem *item = ((AVPlayer *)object).currentItem;
        //self.lblMusicName.text = ((AVURLAsset*)item.asset).URL.pathComponents.lastObject;
        //NSLog(@"New music name: %@", self.lblMusicName.text);
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)didTapPlayPause:(id)sender
{
    self.btnPlayPause.selected = !self.btnPlayPause.selected;

    if (self.btnPlayPause.selected)
    {
        [self.player play];
        [self.btnPlayPause setTitle:@"Pause" forState:UIControlStateNormal];

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
        [self.btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    }
}

/* ---------------------------------------------------------
 **  Get the duration for a AVPlayerItem.
 ** ------------------------------------------------------- */

- (CMTime)playerItemDuration
{
	AVPlayerItem *playerItem = [self.player currentItem];
	if (playerItem.status == AVPlayerItemStatusReadyToPlay)
	{
        /*
         NOTE:
         Because of the dynamic nature of HTTP Live Streaming Media, the best practice
         for obtaining the duration of an AVPlayerItem object has changed in iOS 4.3.
         Prior to iOS 4.3, you would obtain the duration of a player item by fetching
         the value of the duration property of its associated AVAsset object. However,
         note that for HTTP Live Streaming Media the duration of a player item during
         any particular playback session may differ from the duration of its asset. For
         this reason a new key-value observable duration property has been defined on
         AVPlayerItem.
         
         See the AV Foundation Release Notes for iOS 4.3 for more information.
         */
        
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
