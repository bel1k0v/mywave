//
//  Track+Provider.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track+Provider.h"
#import "TrackDbManager.h"

@implementation Track (Provider)

+ (NSArray *) deviceTracks {
    static NSArray *tracks = nil;
    
    TrackDbManager *db = [TrackDbManager sharedInstance];
    NSArray *songs = [db getSongs];
    
    NSMutableArray *allTracks = [NSMutableArray array];
    for (NSDictionary *song in songs) {
        Track *track = [self createTrackFromDbWithSong:song];
        [allTracks addObject:track];
    }
    
    tracks = [allTracks copy];
    
    return tracks;
}

+ (NSArray *) vkontakteTracks
{
    static NSArray *tracks = nil;
    Vkontakte *vk = [Vkontakte sharedInstance];
    if (![vk isAuthorized]) return nil;
    
    NSArray *songs = [vk getUserAudio];
    
    NSMutableArray *allTracks = [NSMutableArray array];
    for (NSDictionary *song in songs) {
        Track *track = [self createTrackFromVkWithSong:song];
        [allTracks addObject:track];
    }
    
    tracks = [allTracks copy];

    
    return tracks;
}

@end
