//
//  StationInfo.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import "MyPinAnnotationView.h"

typedef void(^stationSucBlk)();
typedef void(^stationFailBlk)(NSError *err);

@protocol stationProtocol<NSObject>
@required
@property (nonatomic , copy)   NSString *district;
@property (nonatomic , strong) NSNumber *latitude;
@property (nonatomic , strong) NSNumber *longtitude;
@property (nonatomic , copy)  NSString  *stationAddress;
@property (nonatomic , copy)  NSString  *stationName;
@end

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
 更新所有区域的站点信息

 @param sucBlk 成功时回调
 @param failblk 失败时回调
 */
- (void)updateAllStationsInfoWithSuccessBlk:(stationSucBlk)sucBlk
                                    FailBlk:(stationFailBlk)failblk;
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
- (NSArray<MyPinAnnotation*>*)fetchDistrictStationAnnotationWithArray:(NSArray<id<stationProtocol>>*)districtStationArray;
@end
