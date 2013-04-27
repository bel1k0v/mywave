//
//  StreamingPlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 27.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "StreamingPlayerViewController.h"
#import "AudioStreamer.h"

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
    NSURL *url = [NSURL URLWithString:self.songUrl];
	self.streamer = [[AudioStreamer alloc] initWithURL:url];
    NSLog(@"%@", self.songUrl);
    NSLog(@"%@", self.streamer);
    [self.streamer start];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)destroyStreamer
{
	if (self.streamer)
	{
        /*
         [[NSNotificationCenter defaultCenter]
         removeObserver:self
         name:ASStatusChangedNotification
         object:streamer];
         [progressUpdateTimer invalidate];
         progressUpdateTimer = nil;
         */
		[self.streamer stop];
		self.streamer = nil;
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
	
	//NSString *escapedValue = songUrl;
    
	NSURL *url = [NSURL URLWithString:self.songUrl];
	self.streamer = [[AudioStreamer alloc] initWithURL:url];
	
	/*
     progressUpdateTimer =
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
     object:streamer];
     */
}

-(void)viewDidDisappear:(BOOL)animated
{
    [self.streamer stop];
}

@end
