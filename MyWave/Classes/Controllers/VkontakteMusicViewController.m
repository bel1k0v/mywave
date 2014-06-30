//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "VkontakteMusicViewController.h"
#import "NSString+Gender.h"
#import "Track+Provider.h"
#import "Track+Search.h"
#import "AppHelper.h"

#define MinSearchLength 2
#define MaxSearchLength 25

@implementation VkontakteMusicViewController
{
    @private
    Vkontakte *_vk;
    NSCache *_searchCache;
}

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        _searchCache = [[NSCache alloc] init];
        _vk = [Vkontakte sharedInstance];
    }
    
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    if ([_vk isAuthorized]) {
        [self initSearch];
        [[UITextField appearanceWhenContainedIn:[UISearchBar class], nil] setFont:[UIFont fontWithName:BaseFont
                                                                                                  size:BaseFontSizeDefault]];
    }
    
    [self.tableView reloadData];
}

- (BOOL) isTracksRemote {
    return YES;
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *) searchString {
    if (searchString.length > MinSearchLength && searchString.length < MaxSearchLength) {
        NSArray *cachedData = [_searchCache objectForKey:searchString];
        if (cachedData == NULL) {
            cachedData = [Track vkontakteTracksForSearchString:searchString];
            if (cachedData != NULL) [_searchCache setObject:cachedData forKey:searchString];
            else cachedData = [NSArray new];
        }
        searchData = [[NSMutableArray alloc]initWithArray:cachedData];
        [self.tableView reloadData];
        
        return YES;
    }
    return NO;
}

@end
