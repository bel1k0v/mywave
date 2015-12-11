//
//  Track+VkSDK.m
//  MyWave
//
//  Created by Дмитрий on 29.07.15.
//
//

#import "AppDelegate.h"
#import "Track+VkSDK.h"

static NSString const* VK_AUDIO_CACHE_KEY = @"user.audio";

@implementation Track (VkSDK)

+ (void) vkontakteTracksForSearchString:(NSString *)q andCaller:(id)caller {
    
    VKRequest *audioReq = [VKApi requestWithMethod:@"audio.search" andParameters:@{@"q": q, @"auto_complete": @1, @"sort": @2} andHttpMethod:@"GET"];
    
    [audioReq executeWithResultBlock:^(VKResponse *response) {
        NSArray *tracks = nil;
        
        NSDictionary* responseDict = [NSDictionary dictionaryWithObject:response.json forKey:@"response"];
        
        NSDictionary *songs = [responseDict objectForKey:@"response"];
        NSMutableArray *allTracks = [NSMutableArray array];
        
        //NSLog(@"%@", [songs objectForKey:@"count"]);
        
        for (NSDictionary *song in [songs objectForKey:@"items"]) {
            Track *track = [self createTrackFromVkWithSong:song];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
        [caller performSelectorOnMainThread:@selector(renderSearchTracks:) withObject:tracks waitUntilDone:YES];
        
        
    } errorBlock:^(NSError *error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        }
    }];
}

+ (NSCache *) cache {
    AppDelegate *app = (AppDelegate *)[[UIApplication sharedApplication]delegate];
    NSCache *cache = app.cache;
    
    return cache;
}

+ (void) vkontakteTracks:(id)caller {
    __block NSMutableArray *allTracks = [NSMutableArray array];
    __block NSArray *tracks = nil;
    __block NSCache *cache = [self cache];
    
    if ([cache objectForKey:VK_AUDIO_CACHE_KEY] != nil) {
        allTracks = (NSMutableArray *)[cache objectForKey:VK_AUDIO_CACHE_KEY];
        tracks = [allTracks copy];
        [caller performSelectorOnMainThread:@selector(renderTracks:) withObject:tracks waitUntilDone:NO];
    } else {
        VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:@{} andHttpMethod:@"GET"];
        
        [audioReq executeWithResultBlock:^(VKResponse * response) {
            
            NSDictionary* audio = [NSDictionary dictionaryWithObject:response.json forKey:@"response"];
            NSDictionary *songs = [audio objectForKey:@"response"];
            
            for (NSDictionary *song in [songs objectForKey:@"items"]) {
                Track *track = [self createTrackFromVkWithSong:song];
                [allTracks addObject:track];
            }
            
            [cache setObject:allTracks forKey:VK_AUDIO_CACHE_KEY];
            
            tracks = [allTracks copy];
            [caller performSelectorOnMainThread:@selector(renderTracks:) withObject:tracks waitUntilDone:NO];
            
        } errorBlock:^(NSError * error) {
            if (error.code != VK_API_ERROR) {
                [error.vkError.request repeat];
            } else {
                UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:error.description delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
                [alert show];
            }
        }];
    }
}

@end
