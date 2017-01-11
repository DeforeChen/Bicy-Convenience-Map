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
 选中主页上对应的站点标注
 @param listIndex 列表中的站点索引
 */
-(void)selectCorrespondingAnnotation:(NSInteger)listIndex;

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

/**
 选中底部栏中对应列表中的站点元素
 @param listIndex 索引值
 */
-(void)selectCorrespondingCellInStationList:(NSInteger)listIndex;
@end
