//
//  SongCell.m
//  MyWave
//
//  Created by Дмитрий on 30.11.13.
//
//

#import "TrackCell.h"
#import "AppHelper.h"

@interface TrackCell () {
}

@end
@implementation TrackCell

@synthesize
labelArtist = _labelArtist,
labelTitle = _labelTitle,
labelDuration = _labelDuration;

- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier
{
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        _labelTitle = [[UILabel alloc]initWithFrame:CGRectMake(20.0, 5.0, CGRectGetWidth([self bounds]) - 70.0, 20.0)];
        [_labelTitle setFont:[UIFont fontWithName:BaseFont size:14.0]];
        [_labelTitle setTextColor: UIColorFromRGB(0x333333)];
        [self addSubview:_labelTitle];
        
        _labelArtist = [[UILabel alloc]initWithFrame:CGRectMake(20.0, CGRectGetMaxY([_labelTitle bounds]) + 5.0, CGRectGetWidth([self bounds]) - 20.0, 20.0)];
        [_labelArtist setFont:[UIFont fontWithName:BaseFont size:12.0]];
        [_labelArtist setTextColor:UIColorFromRGB(0xA5A5A5)];
        [self addSubview:_labelArtist];
        
        _labelDuration = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetWidth([self bounds]) - 50, 5.0, 50.0, 20.0)];
        [_labelDuration setFont:[UIFont fontWithName:BaseFont size:12.0]];
        [_labelDuration setTextColor:UIColorFromRGB(0xA5A5A5)];
        [self addSubview:_labelDuration];
    }
    return self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
