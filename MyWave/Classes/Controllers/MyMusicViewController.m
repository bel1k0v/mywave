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

@implementation MyMusicViewController

- (void)refreshData {
    self->tracks = nil;
    DBManager *db = [DBManager getSharedInstance];
    self->tracks = [db getSongs];
    [self.tableView reloadData];
}

- (void) viewDidAppear:(BOOL)animated {
    [self refreshData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self initSearch];
    self.title = @"My music";
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) { // Delete track
        NSDictionary *song = [self->tracks objectAtIndex:indexPath.row];
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            song = [searchData objectAtIndex:indexPath.row];
        }
        NSError *error = nil;
        [[NSFileManager defaultManager]removeItemAtPath:[song objectForKey:@"url"] error:&error];
        [[DBManager getSharedInstance] deleteById:[song objectForKey:@"regNum"]];
        [searchData removeObject:song];
        [self refreshData];
        [tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] withRowAnimation:UITableViewRowAnimationFade];
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
