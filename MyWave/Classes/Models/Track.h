//
//  Track.h
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import <Foundation/Foundation.h>
#import "DOUAudioFile.h"

@interface Track : NSObject <DOUAudioFile>

@property (nonatomic, strong) NSString *regID;
@property (nonatomic, strong) NSString *artist;
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) NSString *duration;
@property (nonatomic, strong) NSURL *audioFileURL;

- (NSString *) getArtist;
- (NSString *) getTitle;
@end