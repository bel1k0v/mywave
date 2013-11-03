//
//  PlayerViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController
@property (strong, nonatomic) IBOutlet UILabel *lblMusicName;
@property (strong, nonatomic) IBOutlet UILabel *lblMusicTime;
@property (strong, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (strong, nonatomic) NSDictionary *song;
- (IBAction)didTapPlayPause:(id)sender;
@end
