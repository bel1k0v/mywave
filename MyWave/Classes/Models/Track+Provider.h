//
//  Track+Provider.h
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"

@interface Track (Provider)

+ (NSArray *)vkontakteTracks;
+ (NSArray *)myTracks;
+ (NSArray *)musicLibraryTracks;
+ (NSArray *)tracksWithArray:(NSArray *)songs url:(BOOL)url;
@end
