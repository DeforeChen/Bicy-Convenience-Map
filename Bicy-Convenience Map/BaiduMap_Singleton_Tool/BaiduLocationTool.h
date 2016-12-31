//
//  BaiduLocationTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Location/BMKLocationComponent.h>
#import "BaiduMapTool.h"

@interface BaiduLocationTool : BaiduMapTool<BMKMapViewDelegate>

/**
 单例的初始化，将mapview放入自己的类中，便于代理的指定和释放控制
 @param mapView 主页的mapview
 @return 单例
 */
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView;
+ (instancetype)shareInstance;
-(void)startLocation;
@end
