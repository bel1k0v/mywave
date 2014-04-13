//
//  ViewController.h
//  MyWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 MyWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"
#import "DBManager.h"

@interface MainViewController : UIViewController <VkontakteDelegate> {
    Vkontakte *_vk;
    DBManager *_db;
}

@end

