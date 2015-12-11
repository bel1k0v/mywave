//
//  AppHelper.m
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import "AppHelper.h"

@implementation AppHelper

+ (BOOL) isNetworkAvailable {
    NSURL *scriptUrl = [NSURL URLWithString:@"http://google.com"];
    NSData *data     = [NSData dataWithContentsOfURL:scriptUrl];
    if (data) {
        return YES;
    } else {
        return NO;
    }
}

+ (CGFloat) getDeviceHeight {
    CGRect bounds = [[UIScreen mainScreen] bounds];
    return bounds.size.height;
}

+ (NSString *) dbPath {
    NSString *docsDir;
    NSArray *dirPaths;
    // Get the documents directory
    dirPaths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    docsDir = dirPaths[0];
    NSString *dbPath = [[NSString alloc] initWithString:
                        [docsDir stringByAppendingPathComponent: DbName]];
    
    return dbPath;
}

+ (NSString *) filesDir {
    NSArray *paths               = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    return documentsDirectory;
}

@end
