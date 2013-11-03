//
//  PlayerViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "PlayerViewController.h"
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController ()
@property (nonatomic, strong) AVQueuePlayer *player;
@property (nonatomic, strong) id timeObserver;

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
    
    self.lblMusicName.text = [NSString stringWithFormat:@"%@ - %@",
                              [self.song objectForKey:@"artist"],
                              [self.song objectForKey:@"title"]];
    
    NSArray *queue = @[
                       [AVPlayerItem playerItemWithURL:[NSURL URLWithString:[self.song objectForKey:@"url"]]]
                     ];

    self.player = [[AVQueuePlayer alloc] initWithItems:queue];
    self.player.actionAtItemEnd = AVPlayerActionAtItemEndAdvance;
    
    [self.player addObserver:self
                  forKeyPath:@"currentItem"
                     options:NSKeyValueObservingOptionNew
                     context:nil];
    
    void (^observerBlock)(CMTime time) = ^(CMTime time) {

        NSLog(@"%@", [self.player items]);
        if ([[self.player items] count] > 1)
        {
            [self.player pause];
            [self.player removeItem:self.player.currentItem];
        }
        
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
    NSLog(@"%ld", (long)self.player.status);

    if (self.btnPlayPause.selected)
    {
        [self.player play];
        [self.btnPlayPause setTitle:@"Pause" forState:UIControlStateNormal];
    }
    else
    {
        [self.player pause];
        [self.btnPlayPause setTitle:@"Play" forState:UIControlStateNormal];
    }
}

@end
