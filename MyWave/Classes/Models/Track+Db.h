//
//  Track+Db.h
//  MyWave
//
//  Created by Дмитрий on 30.07.15.
//
//

#import "Track.h"

@interface Track (Db)

+ (NSArray *) saved;
- (BOOL) deleteRec;
- (BOOL) isSaved;
- (BOOL) save;
- (void) downloadWithProgressBlock:(void (^)(NSUInteger bytesRead, long long totalBytesRead, long long totalBytesExpectedToRead))progressBlock;
@end
