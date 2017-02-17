//
//  ViewController.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/13.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduLocationTool.h"
#import "BaiduDistrictTool.h"
#import "BaiduRouteSearchTool.h"
#import "AppDelegate.h"
#import "MyPinAnnotationView.h"

@class termiStation;
@interface ViewController : UIViewController
@property (nonatomic) BICYCLE_GUIDE_MODE guideMode; // 导航模式，周边站点导航或
@property (nonatomic,strong) termiStation *guideStartStation;
@property (nonatomic,strong) termiStation *guideEndStation;
@end

// --------------------------------------------------------------------------
/**
 S/E 站点的信息
 */
@interface termiStation : NSObject
@property (nonatomic) CLLocationCoordinate2D coordiate;
@property (nonatomic,copy) NSString *name;
@property (nonatomic) BOOL isInChangedDistrict; //站点是否在变更后的行政区域内
@property (nonatomic) NSInteger annotationIndex;//站点若处于行政区域内，他对应的标注索引值
//@property (nonatomic,strong) terminalStationAnnotation *annotation;


/**
 根据标注，写入S/E 站点信息
 @param annotation 标注
 @param index 处于行政区域内时，标注的索引
 */
-(void)writeInDataFromAnnotation:(id<BMKAnnotation>) annotation
                 annotationIndex:(NSInteger)index;

/**
 若S/E在行政区域内，就去生成一个对应的标注
 @return S/E站点标注
 */
-(terminalStationAnnotation*)generateTermiStationAnnotation;

///**
// 复位数据
// */
//-(void)resetTermiInfo;
@end


