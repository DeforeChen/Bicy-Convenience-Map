//
//  AppDelegate.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/13.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BaiduMapAPI_Base/BMKMapManager.h>

#define BAIDU_KEY @"puAybLNI7odsDotLGGebvoDrvn6I5qQZ"
typedef void (^BaiduAccessCompleteBlk)(BOOL isAccess);

@interface AppDelegate : UIResponder <UIApplicationDelegate,BMKGeneralDelegate>
@property (strong, nonatomic) UIWindow *window;
@property (strong, nonatomic) BaiduAccessCompleteBlk accessCompleteBlk;
@end
