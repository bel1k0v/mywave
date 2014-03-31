//
//  AppHelper.h
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]
#define BaseFont @"HelveticaNeue-CondensedBlack"

@interface AppHelper : NSObject

@end