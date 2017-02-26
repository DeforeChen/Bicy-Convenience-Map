//
//  StationInfo.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MyPinAnnotationView.h"
#import "StationProtocol.h"
#import "MyPinAnnotationView.h"

typedef void(^SucBlk)();
typedef void(^FailBlk)(NSError *err);

#pragma mark models
@interface BaseInfo :NSObject<stationProtocol>
@property (nonatomic , copy)   NSString *district;
@property (nonatomic , strong) NSNumber *latitude;
@property (nonatomic , strong) NSNumber *longtitude;
@property (nonatomic , copy)  NSString  *stationAddress;
@property (nonatomic , copy)  NSString  *stationName;
@end

@interface Jinan :BaseInfo
@end

@interface Gulou :BaseInfo
@end

@interface Cangshan :BaseInfo
@end

@interface Mawei :BaseInfo
@end

@interface Taijiang :BaseInfo
@end

@interface DistrictsInfo :NSObject
@property (nonatomic , strong) NSArray<Jinan *>     *jinan;//晋安区
@property (nonatomic , strong) NSArray<Gulou *>     *gulou;//鼓楼区
@property (nonatomic , strong) NSArray<Cangshan *>  *cangshan;//仓山区
@property (nonatomic , strong) NSArray<Mawei *>     *mawei;//马尾区
@property (nonatomic , strong) NSArray<Taijiang *>  *taijiang;//台江区

/**
 通过传入得到的json数据，获取区域站点信息的model实体

 @param keyValues json数据包
 @return model实体
 */
+ (instancetype)mj_objectWithKeyValues:(id)keyValues;
@end


@interface StationInfo: NSObject
//单例
+ (instancetype)shareInstance;

/**
 判断给定的S/E站点是否在给定的区域内

 @param termiStationName S/E站点名
 @param districtName 行政区域名
 @return 是否处于区域内
 */
-(BOOL)judgeTermiStationWithinDistrict:(NSString *)districtName temirStation:(NSString *)termiStationName;

/**
 更新所有区域的站点信息

 @param sucBlk 成功时回调
 @param failblk 失败时回调
 */
- (void)updateAllStationsInfoWithSuccessBlk:(SucBlk)sucBlk
                                    FailBlk:(FailBlk)failblk;
/**
 传入行政区域的名字，返回对应行政区域站点信息的model

 @param districtName 行政区域名字，如鼓楼，晋安，台江...
 @return 返回对应区域的所有站点信息
 */
- (NSArray<id<stationProtocol>>*)fetchDistrictStationsInfoWithName:(NSString*)districtName;

/**
 根据传入的站点信息数组，获取到一个标注的数组

 @param districtStationArray 站点信息数组
 @return 标注类数组
 */
- (NSArray<BMKPointAnnotation*>*)fetchDistrictStationAnnotationWithArray:(NSArray<id<stationProtocol>>*)districtStationArray;

/**
 根据传入的中心点坐标，获取到一个包含重中点周围所有站点标注的数组
 
 @param currentLocation 中心点坐标
 @return 标注类数组
 */

- (NSArray<BMKPointAnnotation*>*)fetchNearbyStationAnnotationWithPoint:(CLLocationCoordinate2D)currentLocation;
@end
