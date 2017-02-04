//
//  LeftMenuView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/1.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduLocationTool.h"
typedef enum {
    NEARBY_GUIDE_MODE       = 0,
    STATION_TO_STATION_MODE = 1,
}BICYCLE_GUIDE_MODE;

@protocol LeftViewInteractionDelegate <NSObject>
/**
 当移除当前左侧菜单栏时的回调，通知主页的controller将TopView的按钮恢复原状
 */
-(void)finishedRemoveLeftView;

/**
 找出圆形区域内的所有站点并作为覆盖物添加到主页上
 
 @param stationAnnotations 满足条件的站点列表
 @param radius 半径，单位m
 @param center 圆心(当前位置)
 */
-(void)addNearbyStationAnnotations:(NSArray<BMKPointAnnotation*>*)stationAnnotations
                  CircleWithRadius:(NSInteger)radius
                  CircleWithCenter:(CLLocationCoordinate2D)center;


-(void)switchToSearchBetweenStationsMode;

@end

//==========================================================================================
@interface LeftMenuView : UIView
@property (nonatomic,weak) id<LeftViewInteractionDelegate>delegate;

-(instancetype)initMyView;
@end
