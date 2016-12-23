//
//  DistrictButton.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/23.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "config.h"

@interface DistrictButton : UIButton
@property (nonatomic) BOOL isSelected;
-(void)switchToSelectedState;
-(void)switchToDeselectedState;
@end
