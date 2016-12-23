//
//  config.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//
#import <UIKit/UIKit.h>

#ifndef config_h
#define config_h

// 百度密钥
#define BAIDU_KEY @"puAybLNI7odsDotLGGebvoDrvn6I5qQZ"


/**
 屏幕尺寸相关
 */
// 手机屏幕尺寸
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

// 底栏按键高度
#define BOTTOM_OPTION_HEIGHT 261 //底部栏的选项按钮凸起的高度
#define BTN_WIDTH 53.5
#define BTN_HEIGHT 42
#define BTN_TOP_HEIGHT 48
#define BTN_SEL_RECT   CGRectMake(self.frame.origin.x, -6, BTN_WIDTH, BTN_HEIGHT+6)
#define BTN_DESEL_RECT CGRectMake(self.frame.origin.x, 0, BTN_WIDTH, BTN_HEIGHT)

#define SHOW_BOTTOM_RECT              CGRectMake(0, HEIGHT-BOTTOM_OPTION_HEIGHT, WIDTH, self.frame.size.height)
#define SHOW_BOTTOM_ONLY_OPTION_RECT  CGRectMake(0, HEIGHT-BTN_TOP_HEIGHT, WIDTH, self.frame.size.height)
/**
 百度地图工具单例的广播代理控制
 */
#define BAIDU_DELEGATE_CTRL_RADIO @"BaiduDelegateCtrl"
#define DELEGATE_ON  @"on"
#define DELEGATE_OFF @"off"


/**
 底栏行政区域选项按钮选择时的广播
 */
#define DISTRICT_BTN_SEL_RADIO @"districtSelectCtrl"


#endif /* config_h */
