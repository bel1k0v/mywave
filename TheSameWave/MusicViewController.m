//
//  MusicViewController.m
//  TheSameWave
//
//  Created by Дмитрий on 23.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import "MusicViewController.h"
#import "StreamingPlayerViewController.h"

@interface MusicViewController ()

@end

@implementation MusicViewController

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
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
 
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if ([tableView isEqual:self.tableView])
    {
        static NSString *TableViewCellIdentifier = @"Cell";
        
        cell = [tableView dequeueReusableCellWithIdentifier:TableViewCellIdentifier];
        
        if (cell == nil)
        {
            cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault
                                           reuseIdentifier:TableViewCellIdentifier];
        }
        NSDictionary *song = [_data objectAtIndex:indexPath.row];

        CGFloat fontSize = 14.0f;
        cell.textLabel.font = [UIFont fontWithName:@"Times New Roman" size:fontSize];
        cell.textLabel.text = [NSString stringWithFormat:@"%@ - %@",
                               [song objectForKey:@"artist"],
                               [song objectForKey:@"title"]];
    }
    
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

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    StreamingPlayerViewController *playerViewController = [[StreamingPlayerViewController alloc] initWithNibName:@"StreamingPlayerViewController" bundle:nil];
    NSDictionary *song = [_data objectAtIndex:indexPath.row];

    playerViewController.songUrl = [song objectForKey:@"url"];
    playerViewController.songName = [NSString stringWithFormat:@"%@ - %@",
                                          [song objectForKey:@"artist"],
                                          [song objectForKey:@"title"]];
    [self.navigationController pushViewController:playerViewController animated:YES];
     
}

@end
