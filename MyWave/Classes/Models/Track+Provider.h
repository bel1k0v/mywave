//
//  Track+Provider.h
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"
#import "VKSdk.h"

@interface Track (Provider)

+ (NSArray *) deviceTracks;
+ (void) vkontakteTracks:(id) caller;

@end
