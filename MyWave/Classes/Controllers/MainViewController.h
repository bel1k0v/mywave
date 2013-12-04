//
//  ViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 19.04.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MainViewController : UIViewController
{
    IBOutlet UIButton *_vkMusicButton;
    IBOutlet UIButton *_myMusicButton;
}


- (IBAction)vkMusicButtonPressed:(id)sender;
- (IBAction)myMusicButtonPressed:(id)sender;
@end
