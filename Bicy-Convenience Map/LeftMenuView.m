//
//  LeftMenuView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/1.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "LeftMenuView.h"
#import "StationInfo.h"
#import "config.h"
@interface LeftMenuView()
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@end

@implementation LeftMenuView
#pragma mark interaction
- (IBAction)stationToStationSearchMode:(UIButton *)sender {
    [self.delegate switchToSearchBetweenStationsMode];
    [self removeCurrentLeftMenu];
}


- (IBAction)nearbySearchMode:(UIButton *)sender {
//    [self.delegate switchSearchMode:NEARBY_GUIDE_MODE];
    /*
     1. 定位到当前位置
     2. 调用BMKGeometry，组合出所有在圆形区域内的站点数组，通过代理，连同刚刚的圆形区域，这两个覆盖物，传给主页
     */

    [[BaiduLocationTool shareInstance] startLocateWithBlk:^(CLLocationCoordinate2D myLacation) {
        NSArray<BMKPointAnnotation*> *nearbyStationAnnotations = [[StationInfo shareInstance] fetchNearbyStationAnnotationWithPoint:myLacation];
        [self.delegate addNearbyStationAnnotations:nearbyStationAnnotations
                                  CircleWithRadius:NEARBY_RADIUS
                                  CircleWithCenter:myLacation];
    }];
    [self removeCurrentLeftMenu];
}



#pragma mark instance
-(instancetype)initMyView {
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil].lastObject;
        
        
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(removeCurrentLeftMenu)];
        [self.bgImgView addGestureRecognizer:gesture];
    }
    return self;
}

-(void)removeCurrentLeftMenu {
    CGRect rect = CGRectMake(-WIDTH, 60, WIDTH, HEIGHT);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = rect;
                         [self.delegate finishedRemoveLeftView];
                     }
                     completion:^(BOOL finished) {
                         self.delegate = nil;//其实delegat的属性是weak可以不用写了
                         [self removeFromSuperview];
                         NSLog(@"如果已经移除当前的view了，还会执行吗？");
                     }];
}

@end
