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
#import <AVFoundation/AVFoundation.h>

@interface DownloadedViewController ()

@end

@implementation DownloadedViewController

- (id)initWithStyle:(UITableViewStyle)style
{
    self = [super initWithStyle:style];
    if (self) {
        // Custom initialization
    }
    return self;
}


- (void)setupData
{
    DBManager *db = [DBManager getSharedInstance];
    NSArray *data = [db findAll];
    _data = nil;
    
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
    
    _data = songs;
}

- (void)viewDidLoad
{
    [self setupData];
    [super viewDidLoad];
    self.navigationItem.title = @"Своя волна";
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
    return [self.data count];
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

// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        NSLog(@"Delete");
        NSDictionary *song = [_data objectAtIndex:indexPath.row];
        NSError *error = nil;
        //[[NSFileManager defaultManager]removeItemAtPath:[song objectForKey:@"url"] error:&error];
        NSLog(@"Remove file, %@", error);
        NSLog(@"ID: %@", [song objectForKey:@"regNum"]);
        DBManager *db = [DBManager getSharedInstance];
        [db deleteById:[song objectForKey:@"regNum"]];
        //[tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
        [self setupData];
        [tableView reloadData];
    }    
}

#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibName:@"PlayerViewController" bundle:nil];
    NSDictionary *song = [_data objectAtIndex:indexPath.row];
    playerViewController.song = song;
    playerViewController.songs = _data;
    playerViewController->currentSong = indexPath.row;
    
    [self.navigationController pushViewController:playerViewController animated:YES];
    
}




@end
