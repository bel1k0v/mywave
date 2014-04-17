//
//  TracksTableViewController.h
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import <UIKit/UIKit.h>

@interface TracksViewController : UITableViewController<UISearchBarDelegate, UISearchDisplayDelegate>
{
    @public
    NSMutableArray *tracks;
    @protected
    NSMutableArray *searchData;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

- (void) initSearch;
- (BOOL) isTracksRemote;

@end
