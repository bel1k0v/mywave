//
//  AppHelper.m
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import "AppHelper.h"

@implementation AppHelper

+ (BOOL)isNetworkAvailable {
    NSURL *scriptUrl = [NSURL URLWithString:@"http://google.com"];
    NSData *data = [NSData dataWithContentsOfURL:scriptUrl];
    if (data) {
        NSLog(@"Device is connected to the internet"); return YES;
    } else {
        NSLog(@"Device is not connected to the internet"); return NO;
    }
}

@end
