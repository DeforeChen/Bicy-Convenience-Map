//
//  BottomDistrictView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/20.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "StationInfo.h"

@interface BottomDistrictView : UIView
@property (weak, nonatomic) IBOutlet UITableView *stationList;
+ (instancetype) initMyViewWithOwner:(UIViewController*)viewCtrl;
@end
