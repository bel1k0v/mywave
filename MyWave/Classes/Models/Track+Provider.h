//
//  Track+Provider.h
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"

@interface Track (Provider)

+ (NSArray *) deviceTracks;
+ (NSArray *) vkontakteTracks;

@end
