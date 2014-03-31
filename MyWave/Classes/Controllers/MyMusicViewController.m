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

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
        searchData = [NSMutableArray arrayWithArray:[self getSongs]];
    }
    return self;
}

- (NSArray *)getSongs {
    DBManager *db = [DBManager getSharedInstance];
    return [db getSongs];
}

- (void)setupData {
    self->tracks = nil;
    self->tracks = [self getSongs];
}

- (void)initSearch {
    searchData = [NSMutableArray arrayWithCapacity:[self->tracks count]];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
}

- (void) viewDidAppear:(BOOL)animated {
    [self.tableView reloadData];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self setupData];
    [self initSearch];
    self.navigationItem.title = @"My Wave";
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchData count];
    } else {
        return [self->tracks count];
    }
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *song = [self->tracks objectAtIndex:indexPath.row];
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            song = [searchData objectAtIndex:indexPath.row];
        }
        NSError *error = nil;
        [[NSFileManager defaultManager]removeItemAtPath:[song objectForKey:@"url"] error:&error];
        [[DBManager getSharedInstance] deleteById:[song objectForKey:@"regNum"]];
        [searchData removeObject:song];
        [self setupData];
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
