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

@implementation VkontakteMusicViewController {
    @private
    Vkontakte *_vk;
    NSCache *_searchCache;
    NSArray *_cachedData;
}

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        _searchCache = [[NSCache alloc] init];
        _vk = [Vkontakte sharedInstance];
    }
    
    return self;
}

- (void)viewDidLoad {
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
        _cachedData = [_searchCache objectForKey:searchString];
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (_cachedData == NULL) {
                _cachedData = [Track vkontakteTracksForSearchString:searchString];
                if (_cachedData != NULL) [_searchCache setObject:_cachedData forKey:searchString];
                else _cachedData = [NSArray new];
            }
            searchData = [[NSMutableArray alloc]initWithArray:_cachedData];
            [self.tableView reloadData];
        });
        return YES;
    }
    return NO;
}

@end
