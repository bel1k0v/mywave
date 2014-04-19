//
//  Track+Search.m
//  MyWave
//
//  Created by Дмитрий on 20.04.14.
//
//

#import "Track+Search.h"

@implementation Track (Search)

+ (NSArray *)vkontakteTracksForSearchString:(NSString *)q {
    static NSArray *tracks = nil;
    
    Vkontakte *vk = [Vkontakte sharedInstance];
    if (![vk isAuthorized]) return nil;
    
    NSArray *songs = [vk searchAudio:q];
    NSMutableArray *allTracks = [NSMutableArray array];
    for (NSDictionary *song in songs) {
        Track *track = [self createTrackFromVkWithSong:song];
        [allTracks addObject:track];
    }
    tracks = [allTracks copy];
    
    return tracks;
}
@end
