//
//  StationInfo.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "AFNetworking.h"
typedef void(^SuccessBlock)();
typedef void(^FailBlock)(NSError *err);

@protocol stationProtocol<NSObject>
@required
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

#pragma mark models
@interface Jinan :NSObject<stationProtocol>
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

@interface Gulou :NSObject<stationProtocol>
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

@interface Cangshan :NSObject<stationProtocol>
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

@interface Mawei :NSObject<stationProtocol>
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

@interface Taijiang :NSObject<stationProtocol>
@property (nonatomic , copy) NSString  *district;
@property (nonatomic , copy) NSString  *latitude;
@property (nonatomic , copy) NSString  *longtitude;
@property (nonatomic , copy) NSString  *stationAddress;
@property (nonatomic , copy) NSString  *stationName;
@end

@interface DistrictsInfo :NSObject
@property (nonatomic , strong) NSArray<Jinan *>             *jinan;//晋安区
@property (nonatomic , strong) NSArray<Gulou *>             *gulou;//鼓楼区
@property (nonatomic , strong) NSArray<Cangshan *>          *cangshan;//仓山区
@property (nonatomic , strong) NSArray<Mawei *>             *mawei;//马尾区
@property (nonatomic , strong) NSArray<Taijiang *>          *taijiang;//台江区

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
- (void)updateAllStationsInfoWithSuccessBlk:(SuccessBlock)sucBlk
                                    FailBlk:(FailBlock)failblk;
/**
 传入行政区域的名字，返回对应行政区域站点信息的model

 @param districtName 行政区域名字，如鼓楼，晋安，台江...
 @return 返回对应区域的所有站点信息
 */
- (NSArray<id<stationProtocol>>*)fetchDistrictStationsInfoWithName:(NSString*)districtName;
@end
