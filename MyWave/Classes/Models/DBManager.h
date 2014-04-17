//  DBManager.h
//  MyWave
//
//  Created by Дмитрий on 04.11.13.

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+ (DBManager*) getSharedInstance;

// C
- (BOOL) createDB;
- (BOOL) saveData:(NSString*)artist title:(NSString*)title
       duration:(NSString*)duration filename:(NSString*)filename;

// D
- (BOOL) deleteById:(NSString *)registeredNumber;

// S
- (NSArray*) findById:(NSString*)registerNumber;
- (NSArray*) findAll;
- (NSArray*) getSongs;
- (NSArray*) findByTitle:(NSString*)title andArtist:(NSString *)artist;

@end
