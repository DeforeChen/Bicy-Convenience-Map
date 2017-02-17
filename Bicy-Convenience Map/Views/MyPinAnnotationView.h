//
//  MyPinAnnotationView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/9.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "StationProtocol.h"

@interface MyPinAnnotationView : BMKPinAnnotationView
-(instancetype)initWithCustomAnotation:(BMKPointAnnotation*)annotation isAnimation:(BOOL)isAnimationn;
@end


/**
 利用现有的标注，生成一个起点/终点 标注
 */
@interface terminalStationAnnotation : BMKPointAnnotation
-(instancetype)initWithCoordiate:(CLLocationCoordinate2D) coordiate;
@end
