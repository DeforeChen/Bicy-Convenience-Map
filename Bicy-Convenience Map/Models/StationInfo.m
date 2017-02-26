//
//  StationInfo.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "StationInfo.h"
#import "MJExtension.h"
#import "config.h"
#import "AFNetworking.h"
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#import "BaiduLocationTool.h"

#define SELFCLASS_NAME StationInfo
#define SELFCLASS_NAME_STR @"StationInfo"

static StationInfo *center = nil;//定义一个全局的静态变量，满足静态分析器的要求

@interface StationInfo()
@property(nonatomic,strong) DistrictsInfo* districtInfo;
@property(nonatomic,strong) AFHTTPRequestOperationManager *manager;
@property(nonatomic) CLLocationCoordinate2D centerLocation;
@property(nonatomic,strong) NSArray<BMKPointAnnotation*> *nearbyStationAnnotations;
@end

@implementation StationInfo
//单例
+ (instancetype)shareInstance {
    static dispatch_once_t predicate;
    //线程安全
    dispatch_once(&predicate, ^{
        center                = (SELFCLASS_NAME *)SELFCLASS_NAME_STR;
        center                = [[SELFCLASS_NAME alloc] init];
        center.manager        = [AFHTTPRequestOperationManager manager];
        center.centerLocation = FUZHOU_CENTER_POINT;
    });
    
    // 防止子类使用
    NSString *classString = NSStringFromClass([self class]);
    if ([classString isEqualToString: SELFCLASS_NAME_STR] == NO)
        NSParameterAssert(nil);
    
    return center;
}

- (instancetype)init {
    NSString *string = (NSString *)center;
    if ([string isKindOfClass:[NSString class]] == YES && [string isEqualToString:SELFCLASS_NAME_STR]) {
        self = [super init];
        if (self) {
            // 防止子类使用
            NSString *classString = NSStringFromClass([self class]);
            if ([classString isEqualToString:SELFCLASS_NAME_STR] == NO)
                NSParameterAssert(nil);
        }
        return self;
        
    } else
        return nil;
}

-(NSArray<BMKPointAnnotation*>*)nearbyStationAnnotations {
    if (_nearbyStationAnnotations == nil) {
        NSMutableArray *nearbyStations = [NSMutableArray new];
        // 调用本类函数时，默认已经先执行了底下的updateAllStations，保证所有的属性参数都已经赋值
        NSArray *allStations = [self fetchDistrictStationsInfoWithName:ALL_CITY];
        for (id<stationProtocol> station in allStations) {
            CLLocationCoordinate2D stationPoint = CLLocationCoordinate2DMake([[station latitude] floatValue], [[station longtitude] floatValue]);
            BOOL insideArea = BMKCircleContainsCoordinate(stationPoint, self.centerLocation, NEARBY_RADIUS);
            if (insideArea == YES)
                [nearbyStations addObject:station];
        }
        
        NSArray *annotations = [self fetchDistrictStationAnnotationWithArray:nearbyStations];
        _nearbyStationAnnotations = [NSArray arrayWithArray:annotations];
        XLog(@"生成的周围站点的标注数组 = %@",_nearbyStationAnnotations);
    }
    return _nearbyStationAnnotations;
}

#pragma mark 接口函数
-(BOOL)judgeTermiStationWithinDistrict:(NSString *)districtName temirStation:(NSString *)termiStationName {
    NSArray *stations = [self fetchDistrictStationsInfoWithName:districtName];
    for (id<stationProtocol> station in stations) {
        if ([termiStationName isEqualToString:[station stationName]]) {
            return YES;
        }
    }
    return NO;
}

- (void)updateAllStationsInfoWithSuccessBlk:(SucBlk)sucBlk
                                    FailBlk:(FailBlk)failblk {
    [_manager GET:STATION_INFO_URL
       parameters:nil
          success:^(AFHTTPRequestOperation * _Nonnull operation, id  _Nonnull responseObject) {
              XLog(@"请求数据 = %@",responseObject);
              self.districtInfo = [DistrictsInfo mj_objectWithKeyValues:responseObject
                                                                context:nil];
              
              sucBlk();
          }
          failure:^(AFHTTPRequestOperation * _Nullable operation, NSError * _Nonnull error) {
              failblk(error);
          }];
}

- (NSArray<id<stationProtocol>>*)fetchDistrictStationsInfoWithName:(NSString*)districtName {
    if ([districtName isEqualToString:GULOU]) {
        return self.districtInfo.gulou;
    } else if ([districtName isEqualToString:TAIJIANG]) {
        return self.districtInfo.taijiang;
    } else if ([districtName isEqualToString:JINAN]) {
        return self.districtInfo.jinan;
    } else if ([districtName isEqualToString:MAWEI]) {
        return self.districtInfo.mawei;
    }else if ([districtName isEqualToString:CANGSHAN]) {
        return self.districtInfo.cangshan;
    } else {//全市
        NSMutableArray *allcityStations = [NSMutableArray arrayWithArray:self.districtInfo.gulou];
        [allcityStations addObjectsFromArray:self.districtInfo.taijiang];
        [allcityStations addObjectsFromArray:self.districtInfo.jinan];
        [allcityStations addObjectsFromArray:self.districtInfo.mawei];
        [allcityStations addObjectsFromArray:self.districtInfo.cangshan];
        return allcityStations;
    }
}

- (NSArray<BMKPointAnnotation*>*)fetchDistrictStationAnnotationWithArray:(NSArray<id<stationProtocol>>*)districtStationArray {
    NSMutableArray *stationAnnotationArray = [NSMutableArray new];
    // 从站点信息中将经纬度取出，转化为浮点型，并添加到一个标注类中。完成后，将标注类对象放入数组并返回
    for (id<stationProtocol> station in districtStationArray) {
        BMKPointAnnotation* annotation = [[BMKPointAnnotation alloc]init];
        CLLocationCoordinate2D coor;
        XLog(@"json站点经纬度 = %@,%@",station.latitude,station.longtitude);
        coor.latitude = [station.latitude floatValue];
        coor.longitude = [station.longtitude floatValue];
        XLog(@"float转化后站点经纬度 = %f,%f",coor.latitude,coor.longitude);
        annotation.coordinate   = coor;
        annotation.title        = station.stationName;
        annotation.subtitle     = station.district;
        [stationAnnotationArray addObject:annotation];
    }
    return stationAnnotationArray;
}

- (NSArray<BMKPointAnnotation*>*)fetchNearbyStationAnnotationWithPoint:(CLLocationCoordinate2D)currentLocation {
    /* 因为在点击定位的时候，不论是否大于500m(大于500m只是会再调用一次而已)，都会返回来一个currentLocation
     因此这里还须再判断一次 */
    BOOL isFarMovement = BMKCircleContainsCoordinate(currentLocation, self.centerLocation, UPDATAE_DISTANCE);

    if (!isFarMovement) {
        self.centerLocation            = currentLocation;
        NSArray *allStations           = [self fetchDistrictStationsInfoWithName:ALL_CITY];
        NSMutableArray *nearbyStations = [NSMutableArray new];
        for (id<stationProtocol> station in allStations) {
            CLLocationCoordinate2D stationPoint = CLLocationCoordinate2DMake([[station latitude] floatValue], [[station longtitude] floatValue]);
            BOOL insideArea = BMKCircleContainsCoordinate(stationPoint, self.centerLocation, NEARBY_RADIUS);
            if (insideArea == YES)
                [nearbyStations addObject:station];
        }
        
        NSArray *annotations = [self fetchDistrictStationAnnotationWithArray:nearbyStations];
        self.nearbyStationAnnotations = [NSMutableArray arrayWithArray:annotations];
    }
    
    return self.nearbyStationAnnotations;
}

@end

@implementation BaseInfo
-(id)mj_newValueFromOldValue:(id)oldValue property:(MJProperty *)property {
    if ([property.name isEqualToString:@"latitude"]) {
        NSNumber *latitudeNum = [NSNumber numberWithFloat:[oldValue floatValue]];
        return latitudeNum;
    }
    
    if ([property.name isEqualToString:@"longtitude"]) {
        NSNumber *longtitudeNum = [NSNumber numberWithFloat:[oldValue floatValue]];
        return longtitudeNum;
    }
    
    return oldValue;
}
@end

@implementation Jinan
@end

@implementation Gulou
@end

@implementation Cangshan
@end

@implementation Mawei
@end

@implementation Taijiang
@end

@implementation DistrictsInfo
+ (instancetype)mj_objectWithKeyValues:(id)keyValues {
    return [self mj_objectWithKeyValues:keyValues context:nil];
}

+ (NSDictionary *)objectClassInArray{
    return @{@"jinan" : [Jinan class],
             @"gulou" : [Gulou class],
             @"cangshan" : [Cangshan class],
             @"mawei":[Mawei class],
             @"taijiang":[Taijiang class]
             };
}
@end
