//
//  Track+Provider.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track+Provider.h"
#import "TrackDbManager.h"
#import "VKSdk.h"

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

// Async operation
+ (void) vkontakteTracks:(id) caller {
    __block NSArray *tracks = nil;
    
    VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:@{} andHttpMethod:@"GET"];
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {
        //NSLog(@"Json result: %@", response.json);
        //NSError* error;
        NSDictionary* audio = [NSDictionary dictionaryWithObject:response.json forKey:@"response"];
        //NSLog(@"%@", [audio objectForKey:@"response"]);
        NSDictionary *songs = [audio objectForKey:@"response"];
        NSMutableArray *allTracks = [NSMutableArray array];
        
        for (NSDictionary *song in [songs objectForKey:@"items"]) {
            //NSLog(@"Song: %@", song);
            Track *track = [self createTrackFromVkWithSong:song];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
        
        [caller performSelectorOnMainThread:@selector(renderTracks:) withObject:tracks waitUntilDone:NO];
        //NSLog(@"%@",tracks);
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        } 
    }];
}

@end
