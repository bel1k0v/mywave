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

@interface SoundManager : NSObject

@property (strong, nonatomic) AVQueuePlayer *player;
@property (strong, nonatomic) NSNumber *currentSongNumber;
@property (strong, nonatomic) NSDictionary *currentSong;
@property (strong, nonatomic) NSMutableArray *songs;

@property (nonatomic, strong) id timeObserver;
@property (nonatomic, strong) PlayerViewController *delegate;

+ (SoundManager *)sharedInstance;

- (void) setTimer;
- (void) removeTimer;
- (NSDictionary *)playingSong;

@end
