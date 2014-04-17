//
//  MusicViewController.h
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "TracksViewController.h"

@interface VkMusicViewController : TracksViewController
{
    Vkontakte *_vk;
    NSCache *searchCache;
}

- (void) setVk:(Vkontakte *)vk;

@end
