//
//  Track+VkSDK.m
//  MyWave
//
//  Created by Дмитрий on 29.07.15.
//
//

#import "Track+VkSDK.h"

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

+ (void) vkontakteTracks:(id)caller {
    
    if ([VKSdk isLoggedIn]) {
        VKRequest * audioReq = [VKApi requestWithMethod:@"audio.get" andParameters:@{} andHttpMethod:@"GET"];
        
        [audioReq executeWithResultBlock:^(VKResponse * response) {
            NSArray *tracks = nil;
            NSDictionary* audio = [NSDictionary dictionaryWithObject:response.json forKey:@"response"];
            
            NSDictionary *songs = [audio objectForKey:@"response"];
            NSMutableArray *allTracks = [NSMutableArray array];
            
            for (NSDictionary *song in [songs objectForKey:@"items"]) {
                Track *track = [self createTrackFromVkWithSong:song];
                [allTracks addObject:track];
            }
            
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
    } else {
        UIAlertView *alert = [[UIAlertView alloc]initWithTitle:@"Alert" message:@"You're not authorized in vk" delegate:self cancelButtonTitle:@"OK" otherButtonTitles: nil];
        [alert show];
    }
    
}

@end
