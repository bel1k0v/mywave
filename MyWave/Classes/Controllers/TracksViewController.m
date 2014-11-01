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
#import "Track+Provider.h"
#import "AppHelper.h"

@interface TracksViewController ()

@end

@implementation TracksViewController

- (id)initWithStyle:(UITableViewStyle)style {
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)initSearch {
    searchData = [NSMutableArray arrayWithCapacity:[self->tracks count]];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar
                                                                contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Tracks";
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
        return [self->tracks count];
    }
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *CellIdentifier = @"TrackCell";
    TrackCell *cell = (TrackCell *)[tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) {
        cell = [[TrackCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    
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
