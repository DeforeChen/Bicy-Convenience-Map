//
//  StattionsTableViewCell.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "StattionsTableViewCell.h"
#import "config.h"

@interface StattionsTableViewCell()

@end

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

-(void)makeCellUnderSelectionMode {
    self.contentView.backgroundColor = CELL_SEL_COLOR;
    NSLog(@"SELECT COLOR = %@",self.contentView.backgroundColor);
    BOOL hasGotoView = NO;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GotoView class]]) {
            hasGotoView = YES;
            break;
        }
    }
    
    if (hasGotoView == NO) {
        GotoView *gotoView = [GotoView initMyView];
        gotoView.frame = CGRectMake(WIDTH, 0, 104, 52);
        [self addSubview:gotoView];
        [gotoView rotate360DegreeWithImageView];
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0
             usingSpringWithDamping:3.0
              initialSpringVelocity:2.0
                            options:UIViewAnimationOptionOverrideInheritedCurve
                         animations:^{
                             gotoView.frame = CGRectMake(WIDTH-104, 0, 104, 52);
                         }
                         completion:nil];
    }
    
}

-(void)makeCellUnderDeselectionMode {
    self.contentView.backgroundColor = CELL_DESEL_COLOR;
    for (UIView *view in self.subviews) {
        if ([view isKindOfClass:[GotoView class]]) {
            [view removeFromSuperview];
            break;
        }
    }
}
@end
