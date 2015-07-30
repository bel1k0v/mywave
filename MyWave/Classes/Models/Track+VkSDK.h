//
//  Track+VkSDK.h
//  MyWave
//
//  Created by Дмитрий on 29.07.15.
//
//

#import "Track.h"
#include "VkSDK.h"

@interface Track (VkSDK)


+ (void) vkontakteTracks:(id) caller;
+ (void) vkontakteTracksForSearchString:(NSString *)q andCaller:(id)caller;

@end
