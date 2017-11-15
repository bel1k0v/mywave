//
//  TracksTableViewController.h
//  MyWave
//
//  Created by Дмитрий on 31.03.14.
//
//

#import <UIKit/UIKit.h>

@interface TracksViewController : UITableViewController<UISearchBarDelegate, UISearchResultsUpdating>
{
    @public
    NSMutableArray *tracks;
    @protected
    NSMutableArray *searchData;
}

- (BOOL) isTracksRemote;

@end
