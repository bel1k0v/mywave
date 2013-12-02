//
//  DownloadedViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DownloadedViewController : UITableViewController <UISearchBarDelegate, UISearchDisplayDelegate>
{
    NSMutableArray *searchData;
    UISearchBar *searchBar;
    UISearchDisplayController *searchDisplayController;
}

@property (nonatomic, strong) NSArray *data;
@end
