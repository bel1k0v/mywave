//
//  SoundManager.m
//  MyWave
//
//  Created by Дмитрий on 14.01.14.
//
//

#import "SoundManager.h"
#import "PlayerViewController.h"

@implementation SoundManager
@synthesize
    currentSong = _currentSong,
    player = _player,
    delegate = _delegate,
    timeObserver = _timeObserver;

+ (SoundManager *)sharedInstance
{
    static SoundManager *sharedInstance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[SoundManager alloc] init];
        sharedInstance.player = [[AVQueuePlayer alloc]init];
    });
    return sharedInstance;
}


- (void) setTimer
{
    if(_timeObserver)
    {
        _timeObserver = nil;
    }
    
    void (^observerBlock)(CMTime time) = ^(CMTime time) {
        double progress = (double)time.value / (double)time.timescale;
        double duration = [[_currentSong objectForKey:@"duration"] doubleValue];
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
            _delegate.lblMusicTime.text = timeString;
            //NSLog(@"App is active. Time is: %@", timeString);
        } else {
            //NSLog(@"App is backgrounded. Time is: %@", timeString);
        }
    };
    
    _timeObserver = [_player addPeriodicTimeObserverForInterval:CMTimeMake(10, 1000)
                                                          queue:dispatch_get_main_queue()
                                                     usingBlock:observerBlock];
    
}

- (void) removeTimer
{
    [_player removeTimeObserver:_timeObserver];
    _timeObserver = nil;
}

- (NSDictionary *)playingSong
{
    if (_player.rate != 0.f && _currentSong != nil)
        return _currentSong;
    
    return nil;
}

@end
