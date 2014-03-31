//
//  MusicViewController.h
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "TracksTableViewController.h"

@interface VkMusicViewController : TracksTableViewController<VkontakteDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSCache *searchCache;
    Vkontakte *_vkInstance;
    UIBarButtonItem *_loginBarButtonItem;
}

@end
