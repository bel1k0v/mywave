//
//  MusicViewController.m
//  MyWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "VkMusicViewController.h"
#import "PlayerViewController.h"
#import "SongCell.h"
#include "NSString+Gender.h"

@implementation VkMusicViewController

@synthesize data = _data;

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    _vkInstance = [Vkontakte sharedInstance];
    _vkInstance.delegate = self;
    
    if ((BOOL)[_vkInstance isAuthorized] != FALSE)
    {
        _data = [_vkInstance getUserAudio];
        [self.tableView reloadData];
    }
    
    self.navigationItem.title = @"Вконтакте";
    UIBarButtonItem *backItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemRewind target:self action:@selector(back)];
    self.navigationItem.leftBarButtonItem = backItem;
    
    _loginBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"Войти" style:UIBarButtonItemStylePlain target:self action:@selector(loginBarButtonItemPressed:)];
    self.navigationItem.rightBarButtonItem = _loginBarButtonItem;
    [self refreshButtonState];
}

- (void) back
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)loginBarButtonItemPressed:(id)sender
{
    if ((BOOL)[_vkInstance isAuthorized] == FALSE)
    {
        [_vkInstance authenticate];
    }
    else
    {
        [_vkInstance logout];
    }
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
    return [_data count];
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
    cell.titleLabel.text = [NSString htmlEntityDecode:[song objectForKey:@"title"]];
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
    {
        _loginBarButtonItem.title = @"Войти";
    }
    else
    {
        //[_vkInstance getUserInfo];
        _loginBarButtonItem.title = @"Выйти";
    }
}

#pragma mark - Table view delegate

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibName:@"PlayerViewController" bundle:nil];

    playerViewController.song =[_data objectAtIndex:indexPath.row];
    playerViewController.songs = _data;
    playerViewController->currentSong = indexPath.row;
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
    _data = [vkontakte getUserAudio];
    [self.tableView reloadData];
}


- (void)vkontakteDidFinishLogOut:(Vkontakte *)vkontakte
{
    [self refreshButtonState];
}

@end
