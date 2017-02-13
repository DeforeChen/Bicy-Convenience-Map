//
//  ViewController.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/13.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduLocationTool.h"
#import "BaiduDistrictTool.h"
#import "BaiduRouteSearchTool.h"
#import "AppDelegate.h"

@class guideStartStationInfo,guideEndStationInfo;
@interface ViewController : UIViewController
@property (nonatomic) BICYCLE_GUIDE_MODE guideMode; // 导航模式，周边站点导航或
@property (nonatomic,strong) guideStartStationInfo *guideStartStation;
@property (nonatomic,strong) guideEndStationInfo    *guideEndStation;
@end

@interface guideStartStationInfo : NSObject
@property (nonatomic) CLLocationCoordinate2D coordiate;
@property (nonatomic,strong) NSString *name;
@end

@interface guideEndStationInfo : NSObject
@property (nonatomic) CLLocationCoordinate2D coordiate;
@property (nonatomic,strong) NSString *name;
@end
