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
typedef void(^SucBlk)();
typedef void(^FailBlk)(NSError *err);

#define IsLogShow 0

#if IsLogShow
#define XLog(format, ...) NSLog((format), ##__VA_ARGS__)
#else
#define XLog(format, ...)
#endif

// 百度密钥
#define BAIDU_KEY @"puAybLNI7odsDotLGGebvoDrvn6I5qQZ"
// 七牛提供的站点URL数据
#define STATION_INFO_URL @"http://ois7g1xk4.bkt.clouddn.com/bicycleMapInfo.json"

// 初始化时检查互联网
#define NETWORK 0//@"联网"
#define PERMISSION 1//@"鉴权"
#define NET_SUCCESS @"1"
#define NET_INIT    @"F"
#define NET_FAIL    @"0"

#define PERMIT_SUCCESS @"1"
#define PERMIT_INIT    @"F"
#define PERMIT_FAIL    @"0"

// S/E 站点背景图名称
#define S_TERMI_IMG  @"起始站点"
#define E_TERIMI_IMG @"终点站点"

/**
 屏幕尺寸相关
 */
// 手机屏幕尺寸
#define WIDTH  [UIScreen mainScreen].bounds.size.width
#define HEIGHT [UIScreen mainScreen].bounds.size.height

// 底栏按键高度
#define BOTTOM_RECT_HEIGHT (1-0.618)*HEIGHT //底部栏的选项按钮凸起的高度,黄金分割
#define BTN_WIDTH 54
#define BTN_HEIGHT 42
#define BTN_TOP_HEIGHT BTN_WIDTH
//#define BTN_SEL_RECT   CGRectMake(self.frame.origin.x, -6, BTN_WIDTH, BTN_HEIGHT+6)
//#define BTN_DESEL_RECT CGRectMake(self.frame.origin.x, 0, BTN_WIDTH, BTN_HEIGHT)

#define SHOW_BOTTOM_RECT              CGRectMake(0, HEIGHT*0.618, WIDTH, BOTTOM_RECT_HEIGHT)
#define SHOW_BOTTOM_ONLY_OPTION_RECT  CGRectMake(0, HEIGHT-BTN_TOP_HEIGHT, WIDTH, BOTTOM_RECT_HEIGHT)
#define SHOW_SHORT_MAPVIEW            CGRectMake(0, 0, WIDTH, HEIGHT*0.618 + BTN_TOP_HEIGHT)
#define SCREEN_RECT                   [UIScreen mainScreen].bounds

// 顶栏距离相关
#define TOP_OFFSET  25
#define TOP_HEIGHT  52
#define SHOW_TOP_RECT                 CGRectMake(0, TOP_OFFSET, WIDTH, TOP_HEIGHT)

#define UNREACHABLE_INDEX   10000
// 标注背景图片的大小
#define ANNOTATION_RECT CGRectMake(0, 0, 30, 30);
#define ANNOTATION_REUSEID @"newAnnotation"


/**
 定位相关
 */
#define NEARBY_RADIUS 800   //附近站点的半径,单位m
#define UPDATAE_DISTANCE 100 //位置变动多少后，更新当前位置的缓存值
#define FUZHOU_CENTER_POINT CLLocationCoordinate2DMake(26.070179, 119.315313) //福州中心
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

/* 搜索模式 及 广播 */
#define GUIDE_MODE_RADIO @"searchModeCtrl"
typedef enum {
    NON_SELECT_MODE         = 0,//初始化的未选中状态
    NEARBY_GUIDE_MODE       = 1,// 周边站点搜索
    STATION_TO_STATION_MODE = 2,// 两个站点之间搜索
    
}BICYCLE_GUIDE_MODE;

/**
 自定义CELL相关
 */
#define CELL_HEIGHT 54
//#define CELL_SEL_COLOR   [UIColor colorWithRed:255/255.0 green:249/255.0 blue:214/255.0 alpha:1.0]
//#define CELL_DESEL_COLOR [UIColor colorWithRed:184/255.0 green:233/255.0 blue:134/255.0 alpha:1.0]

/**
 行政区域名
 */
#define GULOU    @"鼓楼区"
#define TAIJIANG @"台江区"
#define JINAN    @"晋安区"
#define MAWEI    @"马尾区"
#define CANGSHAN @"仓山区"
#define ALL_CITY @"全市"
#define ALL_CITY_POLYGAN_FIT @"全市屏幕适配" //全市显示时候的屏幕适配
#define DISTRICT_NUM 5

#define GULOU_OVERLAY_COLOR     [UIColor colorWithRed:248/255.0 green:238/255.0 blue:28/255.0 alpha:0.4]
#define TAIJIANG_OVERLAY_COLOR  [UIColor colorWithRed:245/255.0 green:166/255.0 blue:35/255.0 alpha:0.4]
#define JINAN_OVERLAY_COLOR     [UIColor colorWithRed:126/255.0 green:211/255.0 blue:33/255.0 alpha:0.4]
#define CANGSHAN_OVERLAY_COLOR  [UIColor colorWithRed:80/255.0 green:227/255.0 blue:194/255.0 alpha:0.4]
#define MAWEI_OVERLAY_COLOR     [UIColor colorWithRed:242/255.0 green:69/255.0 blue:61/255.0 alpha:0.4]
#define NEARBY_OVERLAY_COLOR    [UIColor colorWithRed:74/255.0 green:144/255.0 blue:226/255.0 alpha:0.4]

//保存行政区域边界的plist文件名
#define PLIST_NAME @"districtOutlineInfo.plist"

// ------------------- HUD ---------------------
#define HUD_NET_WARNING    [SVProgressHUD showErrorWithStatus:@"网络连接失败，请检查您的网络"]
#define HUD_ACCESS_WARNING [SVProgressHUD showErrorWithStatus:@"获取地图数据失败，请检查您的网络"] // 鉴权失败
#define HUD_DATA_WARNING   [SVProgressHUD showErrorWithStatus:@"数据请求失败，请检查您的网络"]

#define ANIMATION_TIME 0.4
#define ZOOM_LEVEL 17 // 选中一个站点时的放大等级

#endif /* config_h */
