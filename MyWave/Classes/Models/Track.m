//
//  Track.m
//  MyWave
//
//  Created by Дмитрий on 18.02.14.
//
//

#import "Track.h"
#import "NSString+HTML.h"

@implementation Track

- (NSString *) getTitle {
    return [NSString htmlEntityDecode:[self.title stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}

- (NSString *) getArtist {
    return [NSString htmlEntityDecode:[self.artist stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]];
}
@end
