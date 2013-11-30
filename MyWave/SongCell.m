//
//  SongCell.m
//  MyWave
//
//  Created by Дмитрий on 30.11.13.
//
//

#import "SongCell.h"

@implementation SongCell
@synthesize titleLabel = _titleLabel, artistLabel = _artistLabel,
durationLabel = _durationLabel;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

@end
