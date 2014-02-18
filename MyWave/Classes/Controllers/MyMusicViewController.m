//
//  DownloadedViewController.m
//  MyWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "MyMusicViewController.h"
#import "PlayerViewController.h"
#import "SongCell.h"
#import "NSString+FontAwesome.h"
#import "NSString+Gender.h"
#import "Track+Provider.h"
#import "DBManager.h"

@implementation MyMusicViewController
@synthesize data = _data;

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
    _data = nil;
    _data = [self getSongs];
}

- (void)initSearch {
    searchData = [NSMutableArray arrayWithCapacity:[_data count]];
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
    self.navigationItem.title = @"Моя Музыка";
    UIBarButtonItem *cameraItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = cameraItem;
}

- (void) back {
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchData count];
    } else {
        return [_data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"SongCell";

    SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects) {
            if ([currentObject isKindOfClass:[UITableViewCell class]]) {
                cell = (SongCell *) currentObject;
                break;
            }
        }
    }
    
    NSDictionary *song = [_data objectAtIndex:indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        song = [searchData objectAtIndex:indexPath.row];
    }
    
    
    cell.titleLabel.text = [NSString htmlEntityDecode:[song objectForKey:@"title"]];    
    cell.artistLabel.text = [NSString htmlEntityDecode:[song objectForKey:@"artist"]];
    
    double duration = [[song objectForKey:@"duration"]doubleValue];
    int minutes = (int) floor(duration / 60);
    int seconds = duration - (minutes * 60);
    NSString *durationLabel = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    cell.durationLabel.text = durationLabel;
    
    return cell;
}

#pragma mark - Table view delegate
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *song = [_data objectAtIndex:indexPath.row];
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


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerViewController *playerViewController = [PlayerViewController new];
    [playerViewController setTitle:@"Плеер ♫"];
    
    NSArray *songs = [NSArray new];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        songs = searchData;
    } else {
        songs = _data;
    }
    [playerViewController setCurrentTrackIndex:indexPath.row];
    [playerViewController setTracks:[Track tracksWithArray:songs url:NO]];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [searchData removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"title CONTAINS[c] %@", searchText];
    searchData = [NSMutableArray arrayWithArray:[_data filteredArrayUsingPredicate:predicate]];
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
