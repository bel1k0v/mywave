//
//  DownloadedViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "NSString+Gender.h"
#import "DownloadedViewController.h"
#import "PlayerViewController.h"
#import "DBManager.h"
#import "SongCell.h"
#import "AppDelegate.h"

@implementation DownloadedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        searchData = [NSMutableArray arrayWithArray:[self getTableViewData]];
    }
    return self;
}

- (NSArray *)getTableViewData
{
    DBManager *db = [DBManager getSharedInstance];
    NSArray *data = [db findAll];
    
    
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableArray *songs = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [data count]; ++i)
    {
        NSString *regNum = [[data objectAtIndex:i]objectAtIndex:0];
        NSString *artist = [[data objectAtIndex:i]objectAtIndex:1];
        NSString *title = [[data objectAtIndex:i]objectAtIndex:2];
        NSString *duration = [[data objectAtIndex:i]objectAtIndex:3];
        NSString *songPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [[data objectAtIndex:i]objectAtIndex:4]];
        
        NSArray *keys = [NSArray arrayWithObjects:@"url", @"artist", @"title", @"duration", @"regNum", nil];
        NSArray *values = [NSArray arrayWithObjects:songPath, artist, title, duration, regNum, nil];
        NSDictionary *song = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
        [songs addObject:song];
    }
    
    return songs;
}

- (void)setupData
{
    _data = nil;
    _data = [self getTableViewData];
}


- (void)viewDidLoad
{
    [self setupData];
    searchData = [NSMutableArray arrayWithCapacity:[_data count]];
    [super viewDidLoad];
    self.navigationItem.title = @"Своя волна";
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        return [searchData count];
    } else {
        return [_data count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *CellIdentifier = @"SongCell";

    SongCell *cell = (SongCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        NSArray *topLevelObjects = [[NSBundle mainBundle] loadNibNamed:@"SongCell" owner:nil options:nil];
        for (id currentObject in topLevelObjects){
            if ([currentObject isKindOfClass:[UITableViewCell class]]){
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
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        NSDictionary *song = [_data objectAtIndex:indexPath.row];
        if (tableView == self.searchDisplayController.searchResultsTableView) {
            song = [searchData objectAtIndex:indexPath.row];
        }
        NSError *error = nil;
        [[NSFileManager defaultManager]removeItemAtPath:[song objectForKey:@"url"] error:&error];
        DBManager *db = [DBManager getSharedInstance];
        [db deleteById:[song objectForKey:@"regNum"]];
        [self setupData];
        [self.tableView reloadData];
    }    
}


- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibName:@"PlayerViewController" bundle:nil];
    NSDictionary *song = [_data objectAtIndex:indexPath.row];
    NSArray *songs = _data;
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        song = [searchData objectAtIndex:indexPath.row];
        songs = searchData;
    }
    
    playerViewController.song = song;
    playerViewController.songs = songs;
    playerViewController.classNameRef = @"Downloaded";
    playerViewController->currentSong = indexPath.row;
    
    [self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark Content Filtering
- (void)filterContentForSearchText:(NSString*)searchText scope:(NSString*)scope {
    [searchData removeAllObjects];
    NSPredicate *predicate = [NSPredicate predicateWithFormat:@"artist CONTAINS[c] %@", searchText];
    searchData = [NSMutableArray arrayWithArray:[_data filteredArrayUsingPredicate:predicate]];
}


#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString
{
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
