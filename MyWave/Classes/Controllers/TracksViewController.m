//
//  TracksTableViewController.m
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import "PlayerViewController.h"
#import "TrackCell.h"
#import "NSString+HTML.h"
#import "TracksViewController.h"
#import "Track.h"
#import "AppHelper.h"

@interface TracksViewController () <UISearchBarDelegate, UISearchResultsUpdating>
@property (nonatomic, strong) UISearchController *searchController;
@end

@implementation TracksViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tracks";
    self.tableView.backgroundColor = UIColorFromRGB(0xF4F4F4);
    self.searchController = [[UISearchController alloc] initWithSearchResultsController:nil];
    self.searchController.searchResultsUpdater = self;
    self.searchController.dimsBackgroundDuringPresentation = NO;
    self.searchController.searchBar.delegate = self;
    
    self.tableView.tableHeaderView = self.searchController.searchBar;
    self.definesPresentationContext = YES;
    [self.searchController.searchBar sizeToFit];
}

#pragma mark -
#pragma mark === UISearchBarDelegate ===
#pragma mark -

- (void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.searchController];
}

#pragma mark -
#pragma mark === UISearchResultsUpdating ===
#pragma mark -

- (void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    NSString *searchString = searchController.searchBar.text;
    [self searchForText:searchString];
    [self.tableView reloadData];
}

- (void)searchForText:(NSString *)searchText
{
    NSLog(@"Search %@", searchText);
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}

#pragma mark -
#pragma mark - Table view data source
#pragma mark -

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return [self->tracks count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TrackCell";
    TrackCell *cell = (TrackCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TrackCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.backgroundColor = UIColorFromRGB(0xF4F4F4);
    
    Track *track = [self->tracks objectAtIndex:indexPath.row];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        track = [searchData objectAtIndex:indexPath.row];
    }

    cell.labelTitle.text = [track getTitle];
    cell.labelArtist.text = [track getArtist];
    cell.labelDuration.text = [track getDuration];
    return cell;
}

- (BOOL) isTracksRemote {
    return NO;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 50.0f;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerViewController *playerViewController = [PlayerViewController new];
    NSArray *tracksData = [NSArray new];
    
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        tracksData = searchData;
    } else {
        tracksData = self->tracks;
    }

    [playerViewController setCurrentTrackIndex:indexPath.row];
    [playerViewController setTracksFromRemote:[self isTracksRemote]];
    [playerViewController setTracks:tracksData];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

@end
