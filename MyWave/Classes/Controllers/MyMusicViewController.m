//
//  MyMusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "MyMusicViewController.h"
#import "NSString+Gender.h"
#import "DBManager.h"
#import "Track+Provider.h"

@implementation MyMusicViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    [self initSearch];
    [self.tableView reloadData];
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { // Delete track
        Track *track = [self->tracks objectAtIndex:indexPath.row];

        if (tableView == self.searchDisplayController.searchResultsTableView) {
            track = [searchData objectAtIndex:indexPath.row];
            [searchData removeObject:track];
        } else {
            [self->tracks removeObject:track];
        }
        
        [track deleteFile];
        [track deleteDbRecord];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath]
                         withRowAnimation:UITableViewRowAnimationFade];
        [self.tableView reloadData];
    } else
        return ;
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [searchData removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchText];
    searchData = [NSMutableArray arrayWithArray:[self->tracks filteredArrayUsingPredicate:predicate]];
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    [self filterContentForSearchText:searchString scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:[self.searchDisplayController.searchBar selectedScopeButtonIndex]]];
    return YES;
}

-(BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchScope:(NSInteger)searchOption {
    [self filterContentForSearchText:self.searchDisplayController.searchBar.text scope:
     [[self.searchDisplayController.searchBar scopeButtonTitles] objectAtIndex:searchOption]];
    return YES;
}

@end
