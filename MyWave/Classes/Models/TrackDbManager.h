//  DBManager.h
//  MyWave
//
//  Created by Дмитрий on 04.11.13.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface TrackDbManager : NSObject
{
    NSString *databasePath;
}

+ (TrackDbManager*) sharedInstance;

- (BOOL) createDB;
- (BOOL) saveData:(NSString*)artist title:(NSString*)title
       duration:(NSString*)duration filename:(NSString*)filename;

- (BOOL) deleteById:(NSString *)registeredNumber;

- (NSArray*) findById:(NSString*)registerNumber;
- (NSArray*) findAll;
- (NSArray*) getSongs;
- (NSArray*) findByTitle:(NSString*)title andArtist:(NSString *)artist;

@end
