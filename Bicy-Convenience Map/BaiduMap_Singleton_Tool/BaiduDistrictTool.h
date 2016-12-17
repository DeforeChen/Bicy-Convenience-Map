//
//  BaiduDistrictTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BaiduMapTool.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKSearchComponent.h>
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>


@interface BaiduDistrictTool : BaiduMapTool<BMKMapViewDelegate>
+ (instancetype)shareInstanceWithMapView:(BMKMapView*)mapView;
- (void)searchDistrictWithName:(NSString*)districtName;
@end
