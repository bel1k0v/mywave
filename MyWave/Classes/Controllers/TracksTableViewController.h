//
//  TracksTableViewController.h
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import <UIKit/UIKit.h>

@interface TracksTableViewController : UITableViewController
{
    @public
    NSArray *tracks;
    @protected
    NSMutableArray *searchData;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}
- (BOOL) isTracksRemote;
@end
