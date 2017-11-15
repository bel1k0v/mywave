//
//  MyMusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "DeviceMusicViewController.h"
#import "NSString+Gender.h"
#import "Track+Db.h"
#include "AppHelper.h"

@implementation DeviceMusicViewController

-(id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        self->tracks = [NSMutableArray arrayWithArray:[Track saved]];
    }
    return  self;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { // Delete track
        Track *track = [self->tracks objectAtIndex:indexPath.row];
        
        [track deleteFile];
        [track deleteRec];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    }
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [searchData removeAllObjects];
    
    NSPredicate *predicateByTitle = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@  ", searchText];
    NSPredicate *predicateByArtist = [NSPredicate predicateWithFormat:@"artist CONTAINS[c] %@  ", searchText];
    NSArray *byTitle = [self->tracks filteredArrayUsingPredicate:predicateByTitle];
    NSArray *byArtits = [self->tracks filteredArrayUsingPredicate:predicateByArtist];
    NSMutableSet *set = [NSMutableSet setWithArray:byTitle];
    [set addObjectsFromArray:byArtits];
    
    searchData = [NSMutableArray arrayWithArray:[set allObjects]];
}

@end
