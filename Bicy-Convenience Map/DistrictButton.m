//
//  DistrictButton.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/23.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "DistrictButton.h"
@interface DistrictButton()

@end

@implementation DistrictButton

-(void)awakeFromNib {
    [super awakeFromNib];
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(heardFromSelection:)
                                                 name:DISTRICT_BTN_SEL_RADIO
                                               object:nil];
}

-(void)switchToSelectedState {
    self.frame = BTN_SEL_RECT;
    [self setImage:[self getSelectedImgWithID:self.restorationIdentifier]
          forState:UIControlStateNormal];
    self.isSelected = YES;
}

-(void)switchToDeselectedState {
    self.frame = BTN_DESEL_RECT;
    [self setImage:[self getDeselectedImgWithID:self.restorationIdentifier]
          forState:UIControlStateNormal];
    self.isSelected = NO;
}

-(UIImage*)getSelectedImgWithID:(NSString*)restorationIdentifier{
    NSString *selImgName = [NSString stringWithFormat:@"%@_select",restorationIdentifier];
    return [UIImage imageNamed:selImgName];
}

-(UIImage*)getDeselectedImgWithID:(NSString*)restorationIdentifier{
    NSString *selImgName = [NSString stringWithFormat:@"%@_deselect",restorationIdentifier];
    return [UIImage imageNamed:selImgName];
}

-(void)heardFromSelection:(NSNotification*)info {
    NSString* restorationIdentifier = (NSString*)info.object;
    if (self.isSelected == YES && [restorationIdentifier isEqualToString:self.restorationIdentifier] == NO) {
        [self switchToDeselectedState];
    }
}

@end
