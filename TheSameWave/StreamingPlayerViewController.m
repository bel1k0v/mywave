//
//  StreamingPlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 27.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "StreamingPlayerViewController.h"
#import "AudioStreamer.h"
#import <QuartzCore/CoreAnimation.h>
#import <MediaPlayer/MediaPlayer.h>
#import <CFNetwork/CFNetwork.h>

@interface StreamingPlayerViewController ()

@end

@implementation StreamingPlayerViewController

- (id)initWithNibName:(NSString *)nibNameOrNil bundle:(NSBundle *)nibBundleOrNil
{
    self = [super initWithNibName:nibNameOrNil bundle:nibBundleOrNil];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.songNameLabel setText:self.songName];
    [self createStreamer];
    [self.streamer start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self destroyStreamer];
}

- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (self.streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * self.streamer.duration;
		//[self.streamer seekToTime:newSeekTime];
	}
}

//
// createStreamer
//
// Creates or recreates the AudioStreamer object.
//
- (void)createStreamer
{
	if (self.streamer)
	{
		return;
	}
    
	[self destroyStreamer];
	NSURL *url = [NSURL URLWithString:self.songUrl];
	self.streamer = [[AudioStreamer alloc] initWithURL:url];
	
	
    self.progressUpdateTimer =
    [NSTimer
     scheduledTimerWithTimeInterval:0.1
     target:self
     selector:@selector(updateProgress:)
     userInfo:nil
     repeats:YES];
    [[NSNotificationCenter defaultCenter]
     addObserver:self
     selector:@selector(playbackStateChanged:)
     name:ASStatusChangedNotification
     object:self.streamer];
    
}

//
// destroyStreamer
//
// Removes the streamer, the UI update timer and the change notification
//
- (void)destroyStreamer
{
	if (self.streamer)
	{
		[[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:self.streamer];
		[self.progressUpdateTimer invalidate];
		self.progressUpdateTimer = nil;
		
		[self.streamer stop];
		self.streamer = nil;
	}
}

-(void) updateProgress:(NSTimer *)aNotification
{
    if (self.streamer.bitRate != 0.0)
	{
		double progress = self.streamer.progress;
		double duration = self.streamer.duration;
		
		if (duration > 0)
		{
			[self.playingTimeLabel setText:
             [NSString stringWithFormat:@"Time Played: %.1f/%.1f seconds",
              progress,
              duration]];
			[self.progressSlider setEnabled:YES];
			[self.progressSlider setValue:100 * progress / duration];
		}
		else
		{
			[self.progressSlider setEnabled:NO];
		}
	}
	else
	{
		[self.playingTimeLabel  setText:@"Time Played:"];
	}
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([self.streamer isWaiting])
	{
        NSLog(@"Loading");
    }
	else if ([self.streamer isPlaying])
	{
		NSLog(@"Playing");
	}
	else if ([self.streamer isIdle])
	{
		[self destroyStreamer];
		NSLog(@"Idle");
	}
}

@end
