//
//  StattionsTableViewCell.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StattionsTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *stationName;
@property (weak, nonatomic) IBOutlet UILabel *stationAddress;
@property (weak, nonatomic) IBOutlet UIImageView *stationBgImage;
@property (weak, nonatomic) IBOutlet UIButton *gotoBtn;

+ (instancetype)initMyCellWithStationName:(NSString*)name
                           StationAddress:(NSString*)address;
@end
