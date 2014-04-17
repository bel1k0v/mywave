//
//  TrackCell.h
//  MyWave
//
//  Created by Дмитрий on 30.11.13.
//
//

#import <UIKit/UIKit.h>

@interface TrackCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *labelTitle;
@property (nonatomic, strong) IBOutlet UILabel *labelArtist;
@property (nonatomic, strong) IBOutlet UILabel *labelDuration;
@end
