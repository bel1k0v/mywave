//
//  Track+Search.h
//  MyWave
//
//  Created by Дмитрий on 20.04.14.
//
//

#import "Track.h"
#import "VKSdk.h"

@interface Track (Search)

+ (void) vkontakteTracksForSearchString:(NSString *)q andCaller:(id) caller;

@end
