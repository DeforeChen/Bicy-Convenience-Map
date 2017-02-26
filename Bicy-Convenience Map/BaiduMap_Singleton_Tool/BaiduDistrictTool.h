//
//  BaiduDistrictTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BaiduMapTool.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

@interface BaiduDistrictTool : BaiduMapTool
@property (nonatomic,strong) NSMutableDictionary *districtPolyganDict; //存放区域overlay的字典

/**
 单例的初始化，将mapview放入自己的类中，便于代理的指定和释放控制
 @param mapView 主页的mapview
 @return 单例
 */
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView;
+ (instancetype)shareInstance;


/**
 按键传入对应的区域名称，显示对应的区域边界

 @param districtName 行政区域名
 */
- (void)showDistrictWithName:(NSString*)districtName;

/**
 更新行政区域边界信息

 @param sucBlk 区域更新成功时回调
 @param failBlk 区域更新失败时回调
 */
- (void)updateDistrictPlistWithSuccessBlk:(SucBlk)sucBlk
                                  FailBlk:(FailBlk)failBlk;

/**
 根据plist信息产生覆盖物，存放在本类的私有字典变量中供按键选取区域时调用
 */
- (void)generateOverlaysFromPlist;
@end
