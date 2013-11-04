//
//  PlayerViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PlayerViewController : UIViewController
{
    float restoreAfterScrubbingRate;
}

@property (strong, nonatomic) IBOutlet UILabel *lblMusicName;
@property (strong, nonatomic) IBOutlet UILabel *lblMusicTime;
@property (strong, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload;
@property (strong, nonatomic) IBOutlet UISlider *scrubber;



@property (strong, nonatomic) NSDictionary *song;
- (IBAction)didTapPlayPause:(id)sender;
- (IBAction)didTapDownload:(id)sender;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
@end
