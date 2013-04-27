
#import <UIKit/UIKit.h>

@class AudioStreamer;

@interface iPhoneStreamingPlayerViewController : UIViewController
{
	IBOutlet UITextField *downloadSourceField;
	IBOutlet UIButton *button;
	IBOutlet UIView *volumeSlider;
	IBOutlet UILabel *positionLabel;
	IBOutlet UISlider *progressSlider;
	AudioStreamer *streamer;
	NSTimer *progressUpdateTimer;
	NSString *currentImageName;

}

@property (nonatomic, strong) NSString *songUrl;

- (IBAction)buttonPressed:(id)sender;
- (void)spinButton;
- (void)updateProgress:(NSTimer *)aNotification;
- (IBAction)sliderMoved:(UISlider *)aSlider;

@end

