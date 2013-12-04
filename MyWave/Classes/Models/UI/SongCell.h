//
//  SongCell.h
//  MyWave
//
//  Created by Дмитрий on 30.11.13.
//
//

#import <UIKit/UIKit.h>

@interface SongCell : UITableViewCell
@property (nonatomic, strong) IBOutlet UILabel *titleLabel;
@property (nonatomic, strong) IBOutlet UILabel *artistLabel;
@property (nonatomic, strong) IBOutlet UILabel *durationLabel;
@end
