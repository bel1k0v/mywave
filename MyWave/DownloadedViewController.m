//
//  DownloadedViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "DownloadedViewController.h"
#import "PlayerViewController.h"
#import "DBManager.h"
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
    self.data = nil;
    self.data = data;
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    NSString *cellTitle = [NSString stringWithFormat:@"%@ - %@", [[self.data objectAtIndex:indexPath.row]objectAtIndex:0], [[self.data objectAtIndex:indexPath.row]objectAtIndex:1]];
    cell.textLabel.text = cellTitle;
    CGFloat fontSize = 14.0f;
    cell.textLabel.font = [UIFont fontWithName:@"Helvetica" size:fontSize];

    return cell;
}

/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    }   
    else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath
{
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath
{
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/


#pragma mark - Table view delegate

// In a xib-based application, navigation from a table can be handled in -tableView:didSelectRowAtIndexPath:
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    PlayerViewController *playerViewController = [[PlayerViewController alloc]initWithNibName:@"PlayerViewController" bundle:nil];
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSMutableArray *songs = [[NSMutableArray alloc]init];
    NSMutableArray *playlist = [[NSMutableArray alloc]init];
    
    for(int i = 0; i < [_data count]; ++i)
    {
        NSString *artist = [[_data objectAtIndex:i]objectAtIndex:0];
        NSString *title = [[_data objectAtIndex:i]objectAtIndex:1];
        NSString *duration = [[_data objectAtIndex:i]objectAtIndex:2];
        NSString *songPath = [NSString stringWithFormat:@"%@/%@", documentsDirectory, [[_data objectAtIndex:i]objectAtIndex:3]];
        
        NSArray *keys = [NSArray arrayWithObjects:@"url", @"artist", @"title", @"duration", nil];
        NSArray *values = [NSArray arrayWithObjects:songPath, artist, title, duration, nil];
        NSDictionary *song = [[NSDictionary alloc] initWithObjects:values forKeys:keys];
        
        [songs addObject:song];
        
        AVPlayerItem *item = [AVPlayerItem playerItemWithURL:[song objectForKey:@"url"]];
        [playlist addObject:item];
    }
    
    NSDictionary *song = [songs objectAtIndex:indexPath.row];
    
    playerViewController.song = song;
    playerViewController.songs = songs;
    playerViewController.playlist = playlist;
    playerViewController->currentSong = indexPath.row;
    
    [self.navigationController pushViewController:playerViewController animated:YES];
    
}




@end
