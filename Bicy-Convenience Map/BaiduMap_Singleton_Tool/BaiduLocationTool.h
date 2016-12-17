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
+ (instancetype)shareInstanceWithMapView:(BMKMapView*)mapView;
-(void)startLocation;
@end
