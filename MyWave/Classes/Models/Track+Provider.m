//
//  Track+Provider.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track+Provider.h"
#import "Vkontakte.h"
#import <MediaPlayer/MediaPlayer.h>

@implementation Track (Provider)

+ (void)load
{
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self vkontakteTracks];
    });
    
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_BACKGROUND, 0), ^{
        [self musicLibraryTracks];
    });
}

+ (NSArray *)vkontakteTracks
{
    static NSArray *tracks = nil;
    
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        Vkontakte *vk = [Vkontakte sharedInstance];
        NSArray *songs = [vk getUserAudio];
        
        NSMutableArray *allTracks = [NSMutableArray array];
        for (NSDictionary *song in songs) {
            Track *track = [[Track alloc] init];
            [track setArtist:[song objectForKey:@"artist"]];
            [track setTitle:[song objectForKey:@"title"]];
            [track setDuration:[song objectForKey:@"duration"]];
            [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
    });
    
    return tracks;
}

+ (NSArray *)musicLibraryTracks
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

+ (NSArray *)tracksWithArray:(NSArray *)songs url:(BOOL)isRemote {
    static NSArray *tracks = nil;
    
    NSMutableArray *allTracks = [NSMutableArray array];
    for (NSDictionary *song in songs) {
        Track *track = [[Track alloc] init];
        [track setRegID:[song objectForKey:@"regNum"]];
        [track setArtist:[song objectForKey:@"artist"]];
        [track setTitle:[song objectForKey:@"title"]];
        [track setAudioFileURL: (isRemote ? [NSURL URLWithString:[song objectForKey:@"url"]] : [NSURL fileURLWithPath:[song objectForKey:@"url"]])];
        [track setDuration:[song objectForKey:@"duration"]];
        [allTracks addObject:track];
    }
    
    tracks = [allTracks copy];
    
    return tracks;
}

@end
