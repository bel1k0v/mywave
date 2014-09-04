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

- (void) deleteFile {
    NSError *error;
    [[NSFileManager defaultManager]removeItemAtPath:[self.audioFileURL path] error:&error];
    if (error) {
        NSLog(@"%@",[error description]);
    }
}

- (void) deleteDbRecord {
    [[TrackDbManager sharedInstance] deleteById:self.regID];
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

- (void) downloadWithProgressBlock:(void (^)(NSUInteger bytesRead, NSInteger totalBytesRead, NSInteger totalBytesExpectedToRead))progressBlock
{
    TrackDbManager *db = [TrackDbManager sharedInstance];
    if ([db findByTitle:self.title andArtist:self.artist] != nil) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You already have this track"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSURL *url = self.audioFileURL;
        NSString *filename = [[NSString stringWithFormat:@"%@ - %@", self.artist, self.title] stringByAppendingString:@".mp3"];
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        NSString *filepath = [[paths objectAtIndex:0] stringByAppendingPathComponent:filename];
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
        [operation setDownloadProgressBlock:progressBlock];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (YES == [db saveData:self.artist title:self.title duration:self.duration filename:filename]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ok"
                                                                message:@"Saved"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            } else {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                                message:@"Please try again later"
                                                               delegate:nil
                                                      cancelButtonTitle:@"Ok"
                                                      otherButtonTitles:nil];
                [alert show];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[NSFileManager defaultManager]removeItemAtPath:filepath error:&error];
            UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Error"
                                                            message:@"Please try again later"
                                                           delegate:nil
                                                  cancelButtonTitle:@"Ok"
                                                  otherButtonTitles:nil];
            [alert show];
        }];
        
        [operation start];
    }
}

@end
