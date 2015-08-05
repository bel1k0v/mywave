//
//  Track.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"
#import "NSString+HTML.h"
#import "AFHTTPRequestOperationManager.h"

@implementation Track

- (void) deleteFile {
    NSError *error;
    [[NSFileManager defaultManager]removeItemAtPath:[self.audioFileURL path] error:&error];
    if (error) {
        NSLog(@"%@",[error description]);
    }
}

- (void)loadArtists:(id)sender {
    NSString *url = [NSString stringWithFormat:@"https://api.spotify.com/v1/search?q=%@&type=artist", [self.artist stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]]];
    
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.requestSerializer = [AFJSONRequestSerializer serializer];
    [manager.requestSerializer setValue:@"Content-Type" forHTTPHeaderField:@"application/json"];
    
    [manager GET:url parameters:nil
         success:^(AFHTTPRequestOperation *operation, id responseObject) {
             NSDictionary *artists = (NSDictionary *)[responseObject objectForKey:@"artists"];
             [sender performSelectorOnMainThread:@selector(processArtists:) withObject:artists waitUntilDone:NO];
         }
         failure:^(AFHTTPRequestOperation *operation, NSError *error) {
             NSLog(@"Error: %@", error);
         }];
}

- (NSString *) getTitle {
    return [NSString htmlEntityDecode:[self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

- (NSString *) getArtist {
    return [NSString htmlEntityDecode:[self.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

- (NSString *) getDuration {
    float duration = [self.duration doubleValue];
    int minutes = (int) floor(duration / 60);
    int seconds = duration - (minutes * 60);
    NSString *durationText = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    return durationText;
}

+ (Track *) createTrackFromVkWithSong:(NSDictionary *) song {
    Track *track = [[Track alloc] init];
    [track setArtist:[song objectForKey:@"artist"]];
    [track setTitle:[song objectForKey:@"title"]];
    [track setDuration:[song objectForKey:@"duration"]];
    [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
    
    return track;
}

+ (Track *) createTrackFromDbWithSong:(NSDictionary *) song {
    Track *track = [[Track alloc] init];
    [track setRegID:[song objectForKey:@"regNum"]];
    [track setArtist:[song objectForKey:@"artist"]];
    [track setTitle:[song objectForKey:@"title"]];
    [track setDuration:[song objectForKey:@"duration"]];
    [track setAudioFileURL:[NSURL fileURLWithPath:[song objectForKey:@"url"]]];
    
    return track;
}

@end
