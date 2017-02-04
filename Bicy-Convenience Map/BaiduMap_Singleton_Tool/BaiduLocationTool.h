//
//  BaiduLocationTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "BaiduMapTool.h"

typedef void(^SearchNearbyStationBlk)(CLLocationCoordinate2D myLacation);
@interface BaiduLocationTool : BaiduMapTool
@property (nonatomic) CLLocationCoordinate2D currentLocation;//并非实时更新的当前位置，根据需求，可设置为每隔XXm更新一次


/**
 单例的初始化，将mapview放入自己的类中，便于代理的指定和释放控制
 @param mapView 主页的mapview
 @return 单例
 */
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView;
+ (instancetype)shareInstance;

/**
 开启定位功能
 @param block 搜索附近站点时的回调。旨在获取定位到的位置后搜索周围站点
 */
-(void)startLocateWithBlk:(SearchNearbyStationBlk) block;

// test
-(CLLocationCoordinate2D)getActualLocation;
@end
