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

+ (instancetype)initMyCell {
    StattionsTableViewCell *cell = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                                 owner:self
                                                               options:nil].lastObject;
    return cell;
}
@end
