//
//  Track.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"
#import "NSString+HTML.h"

@implementation Track

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

+ (Track *)createTrackFromVkWithSong:(NSDictionary *) song {
    Track *track = [[Track alloc] init];
    [track setArtist:[song objectForKey:@"artist"]];
    [track setTitle:[song objectForKey:@"title"]];
    [track setDuration:[song objectForKey:@"duration"]];
    [track setAudioFileURL:[NSURL URLWithString:[song objectForKey:@"url"]]];
    
    return track;
}

+ (Track *)createTrackFromDbWithSong:(NSDictionary *) song {
    Track *track = [[Track alloc] init];
    [track setRegID:[song objectForKey:@"regNum"]];
    [track setArtist:[song objectForKey:@"artist"]];
    [track setTitle:[song objectForKey:@"title"]];
    [track setDuration:[song objectForKey:@"duration"]];
    [track setAudioFileURL:[NSURL fileURLWithPath:[song objectForKey:@"url"]]];
    
    return track;
}

@end
