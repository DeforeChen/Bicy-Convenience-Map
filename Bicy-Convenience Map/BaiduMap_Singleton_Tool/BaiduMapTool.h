//
//  BaiduMapTool.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#define BAIDU_DELEGATE_CTRL_RADIO @"BaiduDelegateCtrl"
#define DELEGATE_ON  @"on"
#define DELEGATE_OFF @"off"

@interface BaiduMapTool : NSObject
@property (nonatomic,strong) BMKMapView* mapView;
@end
