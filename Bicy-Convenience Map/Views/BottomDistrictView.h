//
//  BottomDistrictView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/20.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "StationInfo.h"
#import "DistrictButton.h"
typedef void (^selStationInImageBlk)(NSUInteger imgIndex);
@protocol stationInteractionDelegate <NSObject>
/**
 发送列表中选中的站点索引

 @param listIndex 列表中的站点索引
 @param blk 图中的站点索引信息通知回列表
 */
-(void)selStationWithListIndex:(NSInteger)listIndex
                  selMyCellBlk:(selStationInImageBlk)blk;


/**
 通知当前选中的行政区域
 @param districtName 行政区域名称
 */
-(void)addOverlaysToDistrictWithName:(NSString*)districtName;

/**
 通知主页开始上拉底栏，同时缩小mapview
 */
-(void)startMapviewTransform;

/**
 通知主页停止上拉底栏，同时恢复mapview
 */
-(void)stopMapviewTransform;

/**
 通知主页在当前区域内添加标注点信息
 @param annotationArray 标注点数组
 */
-(void)addAnnotationPointInDistrict:(NSArray<BMKPointAnnotation*>*)annotationArray;
@end




//==========================================================================================
@interface BottomDistrictView : UIView
@property (weak, nonatomic) IBOutlet UITableView *stationList;
@property (strong,nonatomic) id<stationInteractionDelegate> delegate;
+ (instancetype) initMyView;
@end
