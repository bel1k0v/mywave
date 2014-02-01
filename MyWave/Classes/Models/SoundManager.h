//
//  SoundManager.h
//  MyWave
//
//  Created by Дмитрий on 14.01.14.
//
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>

@class PlayerViewController;

@interface SoundManager : NSObject {
    @public int currentSong;
}

@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSDictionary *currentSong;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) PlayerViewController *delegate;

+ (SoundManager *)sharedInstance;

- (void) setTimer;
- (void) removeTimer;
- (NSDictionary *)playingSong;

@end
