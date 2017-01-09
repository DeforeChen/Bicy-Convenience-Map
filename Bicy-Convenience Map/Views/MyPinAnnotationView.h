//
//  MyPinAnnotationView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/9.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <BaiduMapAPI_Map/BMKMapComponent.h>

@interface MyPinAnnotation : BMKPointAnnotation
@property (nonatomic,strong) NSString *districtName;
@end

@interface MyPinAnnotationView : BMKPinAnnotationView

-(instancetype)initWithDistrictName:(NSString*)name annotation:(MyPinAnnotation*)annotation isAnimation:(BOOL)isAnimationn;
@end
