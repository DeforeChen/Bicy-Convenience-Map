//
//  BaiduRouteSearchTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/22.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "BaiduMapTool.h"
#import <BaiduMapAPI_Search/BMKSearchComponent.h>

@interface BaiduRouteSearchTool : BaiduMapTool
/**
 单例的初始化，将mapview放入自己的类中，便于代理的指定和释放控制
 @param mapView 主页的mapview
 @return 单例
 */
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView;
+ (instancetype)shareInstance;


/**
 根据起止点的经纬度，规划出🚶步行路径

 @param startPoint 起始点坐标
 @param endPoint 终点坐标
 */
- (void)pathGuideWithStart:(CLLocationCoordinate2D)startPoint end:(CLLocationCoordinate2D)endPoint;
@end
