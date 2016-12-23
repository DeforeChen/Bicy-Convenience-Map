//
//  BaiduMapTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "config.h"

@interface BaiduMapTool : NSObject
@property (nonatomic,strong) BMKMapView* mapView;
@end
