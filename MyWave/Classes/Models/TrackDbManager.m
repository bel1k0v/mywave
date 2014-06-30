//  TrackDbManager.m
//  MyWave
//
//  Created by Дмитрий on 04.11.13.

#import "TrackDbManager.h"

static TrackDbManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation TrackDbManager

+(TrackDbManager*) sharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createTrackDb];
    }
    return sharedInstance;
}

-(BOOL)createTrackDb {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: @"downloaded.db"]];
    BOOL isSuccess = YES;
    NSFileManager *filemgr = [NSFileManager defaultManager];
    if ([filemgr fileExistsAtPath: databasePath ] == NO)
    {
        const char *TrackDbpath = [databasePath UTF8String];
        if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
        {
            char *errMsg;
            const char *sql_stmt =
            "create table if not exists mp3 (id integer primary key, artist text, title text, duration integer, filename text)";
            if (sqlite3_exec(database, sql_stmt, NULL, NULL, &errMsg)
                != SQLITE_OK)
            {
                isSuccess = NO;
                NSLog(@"Failed to create table");
            }
            sqlite3_close(database);
            return  isSuccess;
        }
        else {
            isSuccess = NO;
            NSLog(@"Failed to open/create database");
        }
    }
    return isSuccess;
}

- (BOOL) saveData:(NSString*)artist title:(NSString*)title
         duration:(NSString*)duration filename:(NSString*)filename
{
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
    {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into mp3 (artist, title, duration, filename) values(\"%@\", \"%@\", \"%@\",  \"%@\")", artist, title, duration, filename];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            return YES;
        }
        else
        {
            NSLog(@"Error while preparing statement");
            return NO;
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return NO;
}

- (BOOL) deleteById:(NSString *)registeredNumber
{
    BOOL result = NO;
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
    {
        NSString *deleteSQL = [NSString stringWithFormat:@"delete from mp3 where id = %ld", (long)[registeredNumber integerValue]];
        const char *insert_stmt = [deleteSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt,-1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE)
        {
            NSLog(@"Success");
            result = YES;
        }
        else
        {
            NSLog(@"Error delete, %s", sqlite3_errmsg(database));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return result;
}

- (NSArray *) findAll
{
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = @"select id, artist, title, duration, filename from mp3 order by id desc limit 200";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            while (sqlite3_step(statement) == SQLITE_ROW) {
                NSMutableArray *row = [[NSMutableArray alloc]initWithObjects:nil];
                NSString *regNum = [[NSString alloc] initWithUTF8String:
                                (const char *) sqlite3_column_text(statement, 0)];
                [row addObject:regNum];
                NSString *artist = [[NSString alloc] initWithUTF8String:
                                    (const char *) sqlite3_column_text(statement, 1)];
                [row addObject:artist];
                
                NSString *title = [[NSString alloc] initWithUTF8String:
                                   (const char *) sqlite3_column_text(statement, 2)];
                [row addObject:title];
                NSString *duration = [[NSString alloc]initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 3)];
                [row addObject:duration];
                NSString *filename = [[NSString alloc]initWithUTF8String:
                                      (const char *) sqlite3_column_text(statement, 4)];
                [row addObject:filename];
                
                [resultArray addObject:row];
            }
            sqlite3_reset(statement);
            
            return resultArray;
        }
        
        sqlite3_close(database);
    }
    return nil;
}

- (NSArray *)getSongs
{
    NSArray *data = [self findAll];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableArray *songs = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [data count]; ++i)
    {
        NSString *regNum = [[data objectAtIndex:i]objectAtIndex:0];
        NSString *artist = [[data objectAtIndex:i]objectAtIndex:1];
        NSString *title = [[data objectAtIndex:i]objectAtIndex:2];
        NSString *duration = [[data objectAtIndex:i]objectAtIndex:3];
        NSString *songPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [[data objectAtIndex:i]objectAtIndex:4]];
        NSArray *keys = [NSArray arrayWithObjects:@"url", @"artist", @"title", @"duration", @"regNum", nil];
        NSArray *values = [NSArray arrayWithObjects:songPath, artist, title, duration, regNum, nil];
        NSDictionary *song = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
        [songs addObject:song];
    }
    
    return songs;
}

- (NSArray*) findById:(NSString*)registerNumber
{
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select artist, title, duration, filename from mp3 where id=\"%@\"",registerNumber];
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
                NSString *department = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:department];
                NSString *year = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:year];
                return resultArray;
            }
            else
            {
                NSLog(@"Not found");
                return nil;
            }
            
            sqlite3_reset(statement);
        }
        sqlite3_close(database);
    }
    return nil;
}

- (NSArray*) findByTitle:(NSString*)title andArtist:(NSString *)artist
{
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK)
    {
        NSString *querySQL = [NSString stringWithFormat: @"select artist, title, duration, filename from mp3 where title=\"%@\" and artist = \"%@\"", title, artist];
        
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK)
        {
            if (sqlite3_step(statement) == SQLITE_ROW)
            {
                NSString *name = [[NSString alloc] initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 0)];
                [resultArray addObject:name];
                NSString *department = [[NSString alloc] initWithUTF8String:
                                        (const char *) sqlite3_column_text(statement, 1)];
                [resultArray addObject:department];
                NSString *year = [[NSString alloc]initWithUTF8String:
                                  (const char *) sqlite3_column_text(statement, 2)];
                [resultArray addObject:year];
                return resultArray;
            }
            else
            {
                return nil;
            }
            
            sqlite3_reset(statement);
        }
        sqlite3_close(database);
    }
    return nil;
}
@end
