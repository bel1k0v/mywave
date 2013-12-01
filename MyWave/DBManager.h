//
//  DBManager.h
//  TheSameWave
//
//  Created by Дмитрий on 04.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <sqlite3.h>

@interface DBManager : NSObject
{
    NSString *databasePath;
}

+(DBManager*)getSharedInstance;
-(BOOL)createDB;
-(BOOL)saveData:(NSString*)artist title:(NSString*)title
       duration:(NSString*)duration filename:(NSString*)filename;
-(NSArray*) findById:(NSString*)registerNumber;
-(NSArray*) findAll;
-(NSArray*) findByTitle:(NSString*)title andArtist:(NSString *)artist;

@end
