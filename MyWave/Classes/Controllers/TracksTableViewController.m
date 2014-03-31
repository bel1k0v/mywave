//
//  TracksTableViewController.m
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import "PlayerViewController.h"
#import "SongCell.h"
#import "NSString+HTML.h"
#import "TracksTableViewController.h"
#import "Track+Provider.h"

@interface TracksTableViewController ()

@end

@implementation TracksTableViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
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
    return 0;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
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
    NSDictionary *song = [self->tracks objectAtIndex:indexPath.row];
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

- (BOOL) isTracksRemote {
    return NO;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    PlayerViewController *playerViewController = [PlayerViewController new];
    NSArray *songs = [NSArray new];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        songs = searchData;
    } else {
        songs = self->tracks;
    }

    [playerViewController setCurrentTrackIndex:indexPath.row];
    [playerViewController setTracks:[Track tracksWithArray:songs url:[self isTracksRemote]]];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

@end
