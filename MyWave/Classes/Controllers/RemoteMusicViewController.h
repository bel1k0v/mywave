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

@interface RemoteMusicViewController : TracksViewController
{
    Vkontakte *_vk;
    NSCache *_searchCache;
}

- (void) setVk:(Vkontakte *)vk;

@end
