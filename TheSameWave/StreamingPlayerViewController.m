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

@synthesize songNameLabel, playingTimeLabel, playButton, progressSlider, volumeSlider;

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
    [self createPlayerPannel];
    
    self.songNameLabel = [self createLabelWithFrame:CGRectMake(42, 61, 238, 85) andFontSize:16 andText:self.songName];
    self.playingTimeLabel = [self createLabelWithFrame:CGRectMake(42, 162, 238, 55) andFontSize:14 andText:@"Enjoy the music"];
    self.progressSlider = [self createSliderWithFrame:CGRectMake(60, 122, 200, 18)];
    self.volumeSlider = [self createSliderWithFrame:CGRectMake(60, 222, 200, 20)];
    [self.view addSubview:self.songNameLabel];
    [self.view addSubview:self.playingTimeLabel];
    [self.progressSlider addTarget:self action:@selector(sliderMoved:) forControlEvents:UIControlEventValueChanged];
    [self.view addSubview:self.progressSlider];
    [self.view addSubview:self.volumeSlider];
    [self setButtonWithLabel:@"stop"];
    [self setVolumeSlider];
    UIColor *backgroundColor = [UIColor colorWithPatternImage:[UIImage imageNamed:@"bg-splash.png"]];
    [self.view setBackgroundColor:backgroundColor];
    
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

-(void)createPlayerPannel
{
    self.playButton = [self createButtonWithFrame:CGRectMake(20, 40, 100, 100)];
    [self.playButton setTitle:@"Play" forState:UIControlStateNormal];
    [self.playButton addTarget:self action:@selector(buttonPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    [self.view addSubview:self.playButton];
}

- (IBAction)sliderMoved:(UISlider *)aSlider
{
	if (self.streamer.duration)
	{
		double newSeekTime = (aSlider.value / 100.0) * self.streamer.duration;
        [self.streamer seekToTime:newSeekTime];
	}
}

- (IBAction)buttonPressed:(id)sender
{
    NSLog(@"Button pressed, player state is %@", self.playerState);
	if ([self.playerState isEqual:@"play"])
	{
		[self createStreamer];
        [self setButtonWithLabel:@"stop"];
		[self.streamer start];
	}
	else
	{
        [self setButtonWithLabel:@"play"];
		[self.streamer stop];
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
        double secondsLeft = duration - progress;

        int minutesLeft = (int) floor(secondsLeft/60);
        int minuteSecondsLeft = (int) (secondsLeft - minutesLeft * 60);
        
        int progressMinutes = (int) floor(progress/60);
        int progressMinuteSeconds = (int) progress;
        if (progressMinutes > 1) {
            progressMinuteSeconds = (int)(progress - progressMinutes * 60);
        }
        
		if (duration > 0)
		{
			[self.playingTimeLabel setText:
             [NSString stringWithFormat:@"%d:%02d - %d:%02d",
              progressMinutes,
              progressMinuteSeconds,
              minutesLeft,
              minuteSecondsLeft]];
			[self.progressSlider setEnabled:YES];
            self.progressSlider.maximumValue = 100;
			[self.progressSlider setValue:(100 * (progress / duration))];
		}
		else
		{
			[self.progressSlider setEnabled:NO];
		}
	}
	else
	{
		[self.playingTimeLabel  setText:@"Загружаю твою любимую музыку"];
	}
}

- (void)playbackStateChanged:(NSNotification *)aNotification
{
	if ([self.streamer isWaiting])
	{
        //[self setButtonWithLabel:@"loading"];
    }
	else if ([self.streamer isPlaying])
	{
		[self setButtonWithLabel:@"stop"];
	}
	else if ([self.streamer isIdle])
	{
		[self destroyStreamer];
		[self setButtonWithLabel:@"play"];
	}
}

-(UILabel*)createLabelWithFrame:(CGRect)frame andFontSize:(float)fontSize andText:(NSString*)text
{
    UILabel *label = [[UILabel alloc]initWithFrame:frame];
    [label setFont:[UIFont systemFontOfSize:fontSize]];
    [label setTextColor:[UIColor whiteColor]];
    [label setShadowColor:[UIColor blackColor]];
    [label setShadowOffset:CGSizeMake(0, -1)];
    [label setTextAlignment:UITextAlignmentCenter];
    [label setBackgroundColor:[UIColor clearColor]];
    [label setText:text];
    
    return label;
}

-(UIButton*)createButtonWithFrame:(CGRect)frame
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    return button;
}

- (UISlider*)createSliderWithFrame:(CGRect)frame
{
    UISlider *slider = [[UISlider alloc]initWithFrame:frame];
    return slider;
}

- (void)setButtonWithLabel:(NSString *)label
{
	if (!label)
	{
		label = @"playFirstTime";
	}

	self.playerState = label;
	
	[self.playButton.layer removeAllAnimations];
	[self.playButton setTitle:label.uppercaseString forState:0];
}

-(void) setVolumeSlider{
    self.volumeView = [[MPVolumeView alloc] initWithFrame:[self.volumeSlider frame]];
    NSArray *tempArray = self.volumeView.subviews;
    
    for (id current in tempArray){
        if ([current isKindOfClass:[UISlider class]]){
            UISlider *tempSlider = (UISlider *) current;
            UIImage *img = [UIImage imageNamed:@"trackImage.png"];
            img = [img stretchableImageWithLeftCapWidth:5.0 topCapHeight:0];
            [tempSlider setMinimumTrackImage:img forState:UIControlStateNormal];
            
            [tempSlider setThumbImage:[UIImage imageNamed:@"thumbImage.png"] forState:UIControlStateNormal];
            
        }
    }
    //[self.volumeSlider removeFromSuperview];
    [self.view addSubview:self.volumeView];
}

@end
