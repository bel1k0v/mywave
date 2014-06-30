//
//  MainViewController.h
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "TrackDbManager.h"

@interface MainViewController : UIViewController<VkontakteDelegate, UITableViewDelegate, UITableViewDataSource> {
    Vkontakte *_vk;
    TrackDbManager *_db;
}

@end

