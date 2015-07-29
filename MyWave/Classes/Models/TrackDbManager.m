//  TrackDbManager.m
//  MyWave
//
//  Created by Дмитрий on 04.11.13.

#import "TrackDbManager.h"

static NSString *dbName = @"downloaded.db";
static TrackDbManager *sharedInstance = nil;
static sqlite3 *database = nil;
static sqlite3_stmt *statement = nil;

@implementation TrackDbManager

+ (TrackDbManager*) sharedInstance{
    if (!sharedInstance) {
        sharedInstance = [[super allocWithZone:NULL]init];
        [sharedInstance createDB];
    }
    return sharedInstance;
}

- (BOOL) createDB {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    // Build the path to the database file
    databasePath = [[NSString alloc] initWithString:
                    [docsDir stringByAppendingPathComponent: dbName]];
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
         duration:(NSString*)duration filename:(NSString*)filename {
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK) {
        NSString *insertSQL = [NSString stringWithFormat:@"insert into mp3 (artist, title, duration, filename) values(\"%@\", \"%@\", \"%@\",  \"%@\")", artist, title, duration, filename];
        const char *insert_stmt = [insertSQL UTF8String];
        sqlite3_prepare_v2(database, insert_stmt, -1, &statement, NULL);
        if (sqlite3_step(statement) == SQLITE_DONE) {
            return YES;
        } else {
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
        if (sqlite3_step(statement) == SQLITE_DONE) {
            NSLog(@"Success");
            result = YES;
        } else {
            NSLog(@"Error delete, %s", sqlite3_errmsg(database));
        }
        
        sqlite3_finalize(statement);
        sqlite3_close(database);
    }
    
    return result;
}

- (NSArray *) findAll {
    const char *TrackDbpath = [databasePath UTF8String];
    if (sqlite3_open(TrackDbpath, &database) == SQLITE_OK) {
        NSString *querySQL = @"select id, artist, title, duration, filename from mp3 order by id desc limit 200";
        const char *query_stmt = [querySQL UTF8String];
        NSMutableArray *resultArray = [[NSMutableArray alloc]init];
        if (sqlite3_prepare_v2(database, query_stmt, -1, &statement, NULL) == SQLITE_OK) {
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
