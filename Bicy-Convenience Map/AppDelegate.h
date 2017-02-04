//
//  AppDelegate.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/13.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//


#import <BaiduMapAPI_Base/BMKMapManager.h>
#import "config.h"

typedef void (^BaiduAccessCompleteBlk)(BOOL isAccess);

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (copy, nonatomic) BaiduAccessCompleteBlk accessCompleteBlk;
@end
