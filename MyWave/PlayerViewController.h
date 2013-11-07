//
//  PlayerViewController.h
//  TheSameWave
//
//  Created by Дмитрий on 03.11.13.
//  Copyright (c) 2013 SameWave. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

@interface PlayerViewController : UIViewController <AVAudioSessionDelegate>
{
    @public
    int currentSong;
    @protected
    float restoreAfterScrubbingRate;
}

@property (strong, nonatomic) IBOutlet UILabel *lblMusicArtist;
@property (strong, nonatomic) IBOutlet UILabel *lblMusicName;
@property (strong, nonatomic) IBOutlet UILabel *lblMusicTime;
@property (strong, nonatomic) IBOutlet UIButton *btnPlayPause;
@property (strong, nonatomic) IBOutlet UIButton *btnDownload;
@property (strong, nonatomic) IBOutlet UIButton *btnNext;
@property (strong, nonatomic) IBOutlet UIButton *btnPrev;
@property (strong, nonatomic) IBOutlet UISlider *scrubber;



@property (strong, nonatomic) NSDictionary *song;
@property (strong, nonatomic) NSArray *songs;
@property (strong, nonatomic) NSArray *playlist;
- (IBAction)didTapPlayPause:(id)sender;
- (IBAction)didTapDownload:(id)sender;
- (IBAction)didTapNext:(id)sender;
- (IBAction)didTapPrev:(id)sender;
- (IBAction)beginScrubbing:(id)sender;
- (IBAction)scrub:(id)sender;
- (IBAction)endScrubbing:(id)sender;
@end
