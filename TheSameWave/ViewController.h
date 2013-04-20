//
//  ViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Vkontakte.h"

@interface ViewController : UIViewController <VkontakteDelegate>
{
    IBOutlet UIButton *_loginButton;
    Vkontakte *_vkInstance;
}

- (IBAction)loginButtonPressed:(id)sender;
@end
