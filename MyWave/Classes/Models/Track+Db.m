//
//  Track+Db.m
//  MyWave
//
//  Created by Дмитрий on 30.07.15.
//
//

#import "Track+Db.h"
#import "FMDB.h"
#import "AppHelper.h"

@implementation Track (Db)

+ (NSArray *) saved {
    static NSArray *tracks = nil;
    
    NSMutableArray *allTracks = [NSMutableArray array];
    
    FMDatabase *db = [FMDatabase databaseWithPath:[AppHelper dbPath]];
    
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        [db executeStatements:@"create table if not exists mp3 (id integer primary key, artist text, title text, duration integer, filename text)"];
        
        FMResultSet *result = [db executeQuery:@"select id, artist, title, duration, filename from mp3 order by id desc limit 200"];
        
        while ([result next]) {
            NSString *_id = [NSString stringWithFormat:@"%d", [result intForColumn:@"id"]];
            NSString *artist = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"artist"]];
            NSString *title = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"title"]];
            NSString *duration = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"duration"]];
            NSString *filename = [NSString stringWithFormat:@"%@/%@", [AppHelper filesDir], [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"filename"]]];
            
            
            NSArray *keys      = [NSArray arrayWithObjects:@"url", @"artist", @"title", @"duration", @"regNum", nil];
            NSArray *values    = [NSArray arrayWithObjects:filename, artist, title, duration, _id, nil];
            NSDictionary *song = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
            
            Track *track = [self createTrackFromDbWithSong:song];
            [allTracks addObject:track];
        }
    }
    
    tracks = [allTracks copy];
    
    return tracks;
}

- (BOOL) deleteRec
{
    BOOL result = NO;
    FMDatabase *db = [FMDatabase databaseWithPath:[AppHelper dbPath]];
    
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        result = [db executeUpdateWithFormat:@"delete from mp3 where id = %ld", (long) [self.regID integerValue]];
    }
    
    return result;
}

- (BOOL) save:(NSString *)filename {
    BOOL result = NO;
    FMDatabase *db = [FMDatabase databaseWithPath:[AppHelper dbPath]];
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        NSLog(@"%@ %@ %@ %@", self.artist, self.title, self.duration, filename);
        result = [db executeUpdate:@"insert into mp3 (artist, title, duration, filename) values((?), (?), (?),  (?))", self.artist, self.title, self.duration, filename];
    }
    
    return result;
}

+ (Track *) findById:(NSUInteger)num {
    FMDatabase *db = [FMDatabase databaseWithPath:[AppHelper dbPath]];
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        FMResultSet *result = [db executeQuery:@"select id, artist, title, duration, filename from mp3 where id = %ld", num];
        while ([result next]) {
            Track *track = [Track new];
            track.regID = [NSString stringWithFormat:@"%d", [result intForColumn:@"id"]];
            track.artist = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"artist"]];
            track.title = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"title"]];
            track.duration = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"duration"]];
            track.audioFileURL = [NSString stringWithFormat:@"%@/%@", [AppHelper filesDir], [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"filename"]]];
            
            return track;
        }
    }
    
    return nil;
}

- (BOOL) isSaved {
    FMDatabase *db = [FMDatabase databaseWithPath:[AppHelper dbPath]];
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        FMResultSet *result = [db executeQuery:@"select id from mp3 where artist = (?) and title = (?)", self.artist, self.title];
        if ([result next]) {
            return YES;
        }
    }
    
    return NO;
}

- (void) downloadWithProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock
{
    if ([self isSaved]) {
        UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Warning"
                                                        message:@"You already have this track"
                                                       delegate:nil
                                              cancelButtonTitle:@"Ok"
                                              otherButtonTitles:nil];
        [alert show];
    } else {
        NSString        *name = [NSString stringWithFormat:@"%@ - %@", self.artist, self.title];
        NSString    *filename = [name stringByAppendingString:@".mp3"];
        
        NSURL            *url = self.audioFileURL;
        NSURLRequest *request = [NSURLRequest requestWithURL:url];
        
        AFHTTPRequestOperation *operation = [[AFHTTPRequestOperation alloc] initWithRequest:request];
        
        NSString    *filepath = [[AppHelper filesDir] stringByAppendingPathComponent:filename];
        NSLog(@"filepath %@", filepath);
        operation.outputStream = [NSOutputStream outputStreamToFileAtPath:filepath append:NO];
        [operation setDownloadProgressBlock:progressBlock];
        
        [operation setCompletionBlockWithSuccess:^(AFHTTPRequestOperation *operation, id responseObject) {
            //NSLog(@"%@", responseObject);
            
            if ([self save:filename]) {
                UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Ok"
                                                                message:[NSString stringWithFormat:@"%@ saved", name]
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
            [self deleteFile];
            //NSLog(@"Error");
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
