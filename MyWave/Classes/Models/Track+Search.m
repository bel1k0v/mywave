//
//  Track+Search.m
//  MyWave
//
//  Created by Дмитрий on 20.04.14.
//
//

#import "Track+Search.h"

@implementation Track (Search)

+ (void) vkontakteTracksForSearchString:(NSString *)q andCaller:(id) caller {

    __block NSArray *tracks = nil;
    
    VKRequest * audioReq = [VKApi requestWithMethod:@"audio.search" andParameters:@{@"q": q} andHttpMethod:@"GET"];
    
    [audioReq executeWithResultBlock:^(VKResponse * response) {

        NSDictionary* audio = [NSDictionary dictionaryWithObject:response.json forKey:@"response"];

        NSDictionary *songs = [audio objectForKey:@"response"];
        NSMutableArray *allTracks = [NSMutableArray array];
        
        for (NSDictionary *song in [songs objectForKey:@"items"]) {
            Track *track = [self createTrackFromVkWithSong:song];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
        [caller performSelectorOnMainThread:@selector(renderSearchTracks:) withObject:tracks waitUntilDone:NO];
        
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
}
@end
