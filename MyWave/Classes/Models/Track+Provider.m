//
//  Track+Provider.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track+Provider.h"

@implementation Track (Provider)

+ (NSArray *) myTracks {
    static NSArray *tracks = nil;
    
    DBManager *db = [DBManager sharedInstance];
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

// NIU
+ (NSArray *) musicLibraryTracks
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        NSMutableArray *allTracks = [NSMutableArray array];
        for (MPMediaItem *item in [[MPMediaQuery songsQuery] items]) {
            if ([[item valueForProperty:MPMediaItemPropertyIsCloudItem] boolValue]) {
                continue;
            }
            
            Track *track = [[Track alloc] init];
            [track setArtist:[item valueForProperty:MPMediaItemPropertyArtist]];
            [track setTitle:[item valueForProperty:MPMediaItemPropertyTitle]];
            [track setAudioFileURL:[item valueForProperty:MPMediaItemPropertyAssetURL]];
            [allTracks addObject:track];
        }
        
        for (NSUInteger i = 0; i < [allTracks count]; ++i) {
            NSUInteger j = arc4random_uniform((u_int32_t)[allTracks count]);
            [allTracks exchangeObjectAtIndex:i withObjectAtIndex:j];
        }
        
        tracks = [allTracks copy];
    });
    
    return tracks;
}
@end
