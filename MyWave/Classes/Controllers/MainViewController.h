//
//  MainViewController.h
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TrackDbManager.h"

@interface MainViewController : UIViewController<UITableViewDelegate, UITableViewDataSource> {
    TrackDbManager *_db;
}

@end

