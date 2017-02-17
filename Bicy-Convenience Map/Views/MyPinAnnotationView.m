//
//  MyPinAnnotationView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/9.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "MyPinAnnotationView.h"
#import "config.h"
@class terminalStationAnnotation;
@implementation MyPinAnnotationView
-(instancetype)initWithCustomAnotation:(BMKPointAnnotation*)annotation isAnimation:(BOOL)isAnimationn {
    self = [super init];
    if (self) {
        self = [[MyPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:ANNOTATION_REUSEID];
        self.frame = ANNOTATION_RECT;
        self.animatesDrop = isAnimationn;
        self.image = [UIImage imageNamed:@"站点_deselected"];
    }
    return self;
}
@end

@implementation terminalStationAnnotation
-(instancetype)initWithCoordiate:(CLLocationCoordinate2D) coordiate {
    self = [super init];
    if (self) {
        self = [[terminalStationAnnotation alloc] init];
        self.coordinate = coordiate;
    }
    return self;
}
@end
