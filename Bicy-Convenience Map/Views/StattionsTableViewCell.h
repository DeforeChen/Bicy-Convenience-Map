//
//  StattionsTableViewCell.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "GotoView.h"

@interface StattionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stationName;
@property (weak, nonatomic) IBOutlet UILabel *stationAddress;
@property (weak, nonatomic) IBOutlet UILabel *districtName;
@property (weak, nonatomic) IBOutlet UIImageView *districtImage;
@property (weak, nonatomic) IBOutlet UIImageView *bgImg;

+ (instancetype)initMyCell;

/**
 设置cell为选中模式
 */
-(void)makeCellUnderSelectionMode;

/**
 设置cell为非选中模式
 */
-(void)makeCellUnderDeselectionMode;
@end
