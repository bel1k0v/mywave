//
//  MusicViewController.h
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"

@interface VkMusicViewController : UITableViewController <VkontakteDelegate, UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *searchData;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
    NSCache *searchCache;
    
    Vkontakte *_vkInstance;
    UIBarButtonItem *_loginBarButtonItem;
}

@property (nonatomic, strong) NSArray *data;
@end
