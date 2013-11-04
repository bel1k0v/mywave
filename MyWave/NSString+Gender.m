//
//  NSString+Gender.m
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "NSString+Gender.h"

@implementation NSString (Gender)
+ (NSString *)stringWithGenderId:(NSUInteger)gId
{
    switch (gId)
    {
        case 1:
            return @"Женский";
            break;
            
        case 2:
            return @"Мужской";
            break;
            
        default:
            return @"";
            break;
    }
}
@end
