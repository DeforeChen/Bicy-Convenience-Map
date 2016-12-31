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
// 七牛提供的站点URL数据
#define STATION_INFO_URL @"http://ois7g1xk4.bkt.clouddn.com/test.json"

/**
 屏幕尺寸相关
 */
// 手机屏幕尺寸
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

// 底栏按键高度
#define BOTTOM_RECT_HEIGHT 261 //底部栏的选项按钮凸起的高度
#define BTN_WIDTH 53.5
#define BTN_HEIGHT 42
#define BTN_TOP_HEIGHT 48
#define BTN_SEL_RECT   CGRectMake(self.frame.origin.x, -6, BTN_WIDTH, BTN_HEIGHT+6)
#define BTN_DESEL_RECT CGRectMake(self.frame.origin.x, 0, BTN_WIDTH, BTN_HEIGHT)

#define SHOW_BOTTOM_RECT              CGRectMake(0, HEIGHT-BOTTOM_RECT_HEIGHT, WIDTH, BOTTOM_RECT_HEIGHT)
#define SHOW_BOTTOM_ONLY_OPTION_RECT  CGRectMake(0, HEIGHT-BTN_TOP_HEIGHT, WIDTH, BOTTOM_RECT_HEIGHT)
#define SHOW_SHORT_MAPVIEW            CGRectMake(0, 0, WIDTH, HEIGHT-BOTTOM_RECT_HEIGHT+BTN_TOP_HEIGHT)
#define SCREEN_RECT                   [UIScreen mainScreen].bounds
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


/**
 行政区域名
 */
#define GULOU    @"鼓楼区"
#define TAIJIANG @"台江区"
#define JINAN    @"晋安区"
#define MAWEI    @"马尾区"
#define CANGSHAN @"仓山区"
#define ALL_CITY @"全市"
#define DISTRICT_NUM 5

//保存行政区域边界的plist文件名
#define PLIST_NAME @"districtOutlineInfo.plist"

#define ANIMATION_TIME 0.4
#endif /* config_h */
