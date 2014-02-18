//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import "VkMusicViewController.h"
#import "PlayerViewController.h"
#import "SongCell.h"
#import "NSString+Gender.h"
#import "NSString+FontAwesome.h"
#import "Track+Provider.h"

@implementation VkMusicViewController
@synthesize data = _data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        searchCache = [[NSCache alloc] init];
        searchData = [[NSMutableArray alloc]initWithArray:[self getSongs]];
    }
    return self;
}

- (void)initSearch
{
    searchData = [NSMutableArray arrayWithCapacity:[_data count]];
    searchBar = [[UISearchBar alloc] initWithFrame:CGRectMake(0, 0, 320, 44)];
    
    searchDisplayController = [[UISearchDisplayController alloc] initWithSearchBar:searchBar contentsController:self];
    searchDisplayController.delegate = self;
    searchDisplayController.searchResultsDelegate = self;
    searchDisplayController.searchResultsDataSource = self;
    
    self.tableView.tableHeaderView = searchBar;
}
- (void)setupData
{
    _data = nil;
    _data = [self getSongs];
}
-(NSArray *)getSongs
{
    return ((BOOL)[_vkInstance isAuthorized] != FALSE) ? [_vkInstance getUserAudio] : [[NSArray alloc]init];
}
- (void)viewDidLoad
{
    [super viewDidLoad];
    _vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    
    if ((BOOL)[_vkInstance isAuthorized] != FALSE) {
        [self setupData];
        [self.tableView reloadData];
    }
    
    self.navigationItem.title = @"Вконтакте";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind
                                                                              target:self
                                                                              action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Войти"
                                                           style:UIBarButtonItemStylePlain
                                                          target:self
                                                          action:@selector(loginBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = _loginBarButtonItem;
    [self refreshButtonState];
    [self initSearch];
}

- (void) viewDidAppear:(BOOL)animated
{
    [self.tableView reloadData];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginBarButtonItemPressed:(id)sender
{
    if ((BOOL)[_vkInstance isAuthorized] == FALSE)
        [_vkInstance authenticate];
    else
        [_vkInstance logout];
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
    /*
    if ([[nowPlaying objectForKey:@"url"]isEqualToString:[song objectForKey:@"url"]] == YES)
    {
        cell.playLabel.font = [UIFont fontWithName:@"FontAwesome" size:15.0f];
        cell.playLabel.text = [NSString stringWithFormat:@"%@", [NSString fontAwesomeIconStringForEnum:FAIconEject]];
    } else {
        cell.playLabel.text = @"";
    }
    */
    cell.artistLabel.text = [NSString htmlEntityDecode:[song objectForKey:@"artist"]];
    
    double duration = [[song objectForKey:@"duration"]doubleValue];
    int minutes = (int) floor(duration / 60);
    int seconds = duration - (minutes * 60);
    NSString *durationLabel = [NSString stringWithFormat:@"%d:%02d", minutes, seconds];
    cell.durationLabel.text = durationLabel;
    
    return cell;
}

- (void)refreshButtonState
{
    if (![_vkInstance isAuthorized])
        _loginBarButtonItem.title = @"Войти";
    else
        _loginBarButtonItem.title = @"Выйти";
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *playerViewController = [PlayerViewController new];
    [playerViewController setTitle:@"Плеер ♫"];
    
    NSArray *songs = [NSArray new];
    if (tableView == self.searchDisplayController.searchResultsTableView) {
        songs = searchData;
    } else {
        songs = _data;
    }
    [playerViewController setCurrentTrackIndex:indexPath.row];
    [playerViewController setTracks:[Track tracksWithArray:songs url:YES]];
    [self.navigationController pushViewController:playerViewController animated:YES];
}

#pragma mark - VkontakteDelegate

- (void)vkontakteDidFailedWithError:(NSError *)error
{
    UIAlertView* alert = [[UIAlertView alloc] initWithTitle:@"Fail!" message:@"VK Error" delegate:nil cancelButtonTitle:@"OK" otherButtonTitles: nil];
    [alert show];
}

- (void)showVkontakteAuthController:(UIViewController *)controller
{
    [self presentViewController:controller animated:YES completion:nil];
}

- (void)vkontakteAuthControllerDidCancelled
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (void)vkontakteDidFinishLogin:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
    [self setupData];
    [self.tableView reloadData];
}


- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

#pragma mark - Search display delegate
- (BOOL)searchDisplayController:(UISearchDisplayController *)controller shouldReloadTableForSearchString:(NSString *)searchString {
    NSLog(@"%@", searchString);

    if (searchString.length > 3 && searchString.length < 25) {
        NSArray *cachedData = [searchCache objectForKey:searchString];
        if (cachedData == NULL) {
            cachedData = [_vkInstance searchAudio:searchString];
            if (cachedData != NULL) [searchCache setObject:cachedData forKey:searchString];
            else cachedData = [[NSArray alloc]init];
        }
        searchData = [[NSMutableArray alloc]initWithArray:cachedData];
        [self.tableView reloadData];
    }
    
    return YES;
}

@end
