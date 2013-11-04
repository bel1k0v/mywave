//
//  ViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"

@interface AuthViewController : UIViewController <VkontakteDelegate>
{
    IBOutlet UIButton *_loginButton;
    IBOutlet UIButton *_musicButton;
    IBOutlet UIButton *_downloadedButton;
    
    Vkontakte *_vkInstance;
}

- (IBAction)loginButtonPressed:(id)sender;
- (IBAction)musicButtonPressed:(id)sender;
- (IBAction)downloaderButtonPressed:(id)sender;
@end

