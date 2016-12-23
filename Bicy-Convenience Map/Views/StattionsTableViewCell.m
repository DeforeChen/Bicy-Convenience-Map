//
//  StattionsTableViewCell.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "StattionsTableViewCell.h"

@implementation StattionsTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

+ (instancetype)initMyCellWithStationName:(NSString*)name
                           StationAddress:(NSString*)address{
    StattionsTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                                 owner:nil
                                                               options:nil].lastObject;
    cell.stationName.text = name;
    cell.stationAddress.text = address;
    return cell;
}
@end
