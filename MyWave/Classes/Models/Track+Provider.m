//
//  Track+Provider.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track+Provider.h"
#import "TrackDbManager.h"
#import "FMDatabase.h"

@implementation Track (Provider)

+ (NSString *)getDbPath {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *dbPath = [[NSString alloc] initWithString:
                        [docsDir stringByAppendingPathComponent: @"downloaded.db"]];
    
    return dbPath;
}

+ (NSArray *) deviceTracks {
    static NSArray *tracks = nil;
    
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableArray *songs        = [[NSMutableArray alloc]init];
    
    
    FMDatabase *db = [FMDatabase databaseWithPath:[self getDbPath]];
    if (![db open]) {
        NSLog(@"Connot open db");
    } else {
        FMResultSet *result = [db executeQuery:@"select id, artist, title, duration, filename from mp3 order by id desc limit 200"];
        
        while ([result next]) {
            NSString *_id = [NSString stringWithFormat:@"%d", [result intForColumn:@"id"]];
            NSString *artist = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"artist"]];
            NSString *title = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"title"]];
            NSString *duration = [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"duration"]];
            NSString *filename = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [NSString stringWithUTF8String:[result UTF8StringForColumnName:@"filename"]]];
        

            NSArray *keys      = [NSArray arrayWithObjects:@"url", @"artist", @"title", @"duration", @"regNum", nil];
            NSArray *values    = [NSArray arrayWithObjects:filename, artist, title, duration, _id, nil];
            NSDictionary *song = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
            
            [songs addObject:song];
        }
    }
    
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
            NSLog(@"%@", song);
            Track *track = [self createTrackFromVkWithSong:song];
            [allTracks addObject:track];
        }
        
        tracks = [allTracks copy];
        [caller performSelectorOnMainThread:@selector(renderTracks:) withObject:tracks waitUntilDone:NO];
        
    } errorBlock:^(NSError * error) {
        if (error.code != VK_API_ERROR) {
            [error.vkError.request repeat];
        } else {
            NSLog(@"VK error: %@", error);
        } 
    }];
}

@end
