//
//  Track+Search.h
//  MyWave
//
//  Created by Дмитрий on 20.04.14.
//
//

#import "Track.h"

@interface Track (Search)

+ (NSArray *)vkontakteTracksForSearchString:(NSString *)q;

@end
