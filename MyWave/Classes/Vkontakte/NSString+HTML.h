//
//  NSString+HTML.h
//  MyWave
//
//  Created by Дмитрий on 20.02.14.
//
//

#import <Foundation/Foundation.h>

@interface NSString (HTML)
+ (NSString *)htmlEntityDecode:(NSString *)string;
@end
