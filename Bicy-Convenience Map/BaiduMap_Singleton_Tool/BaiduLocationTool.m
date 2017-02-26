//
//  BaiduLocationTool.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BaiduLocationTool.h"
#import <BaiduMapAPI_Utils/BMKGeometry.h>
#define SELFCLASS_NAME BaiduLocationTool
#define SELFCLASS_NAME_STR @"BaiduLocationTool"

static BaiduLocationTool *center = nil;//定义一个全局的静态变量，满足静态分析器的要求

@interface BaiduLocationTool()<BMKLocationServiceDelegate>
@property (nonatomic,strong) BMKLocationService* locService;
@property (nonatomic,copy) SearchNearbyStationBlk sendMyLocBlk;
@property (nonatomic) BOOL beginLocation; //开始定位标志位
@end

@implementation BaiduLocationTool
#pragma mark 单例初始化
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView {
    static dispatch_once_t predicate;
    //线程安全
    dispatch_once(&predicate, ^{
        center = (SELFCLASS_NAME *)SELFCLASS_NAME_STR;
        center = [[SELFCLASS_NAME alloc] init];
        center.mapView = mapView;
        center.locService = [[BMKLocationService alloc] init];
        center.currentLocation = center.locService.userLocation.location.coordinate;// 初始化默认是0.0
        // 添加广播收听者，接收主页控制的代理创建/销毁
        [[NSNotificationCenter defaultCenter] addObserver:center
                                                 selector:@selector(LocationDelegateSwitch:)
                                                     name:BAIDU_DELEGATE_CTRL_RADIO
                                                   object:nil];
    });
    
    // 防止子类使用
    NSString *classString = NSStringFromClass([self class]);
    if ([classString isEqualToString:SELFCLASS_NAME_STR] == NO)
        NSParameterAssert(nil);
    return center;
}

+(instancetype)shareInstance {
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

-(void)startLocateWithBlk:(SearchNearbyStationBlk)block {
    // block 为空时表示单纯的定位而非包含周边站点功能。地图居中的操作，放在didUpdateBMKUserLocation中去做
    self.sendMyLocBlk = block;
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation  = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode   = BMKUserTrackingModeHeading;
    self.mapView.showsUserLocation  = YES;//显示定位图层
    _beginLocation = YES;
    if (self.sendMyLocBlk) {
        self.sendMyLocBlk(self.currentLocation);
    }
    //不论是单纯的定位还是搜索周边车站功能，只要开启了搜索标志位，就要将当前view居中
    self.mapView.centerCoordinate = self.currentLocation;
    
}

#pragma mark 代理实现
/**
 *在地图View将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
    XLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
//    XLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
//        XLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.mapView updateLocationData:userLocation];
    if (_beginLocation == YES) {
        _beginLocation = NO;
            /*
             判断更新到的数据，和currentLocation之间相距是否大于500m，若大于500m，
             不采用实时更新的目的，是因为搜索周边站点的功能每次都要添加覆盖物，如果实时更新，消耗的资源太大，也不合理
             但是，如果大于500m，也要讲当前位置重置
             */
            BOOL insideArea = BMKCircleContainsCoordinate(self.currentLocation, userLocation.location.coordinate, UPDATAE_DISTANCE);
            if (!insideArea) {
                self.currentLocation = userLocation.location.coordinate;
                XLog(@"大于500m后的更新位置 = %f,%f",self.currentLocation.latitude,self.currentLocation.longitude);
                if (self.sendMyLocBlk) {
                    self.sendMyLocBlk(self.currentLocation);
                }
                self.mapView.centerCoordinate = self.currentLocation;
            }
    }
}


/**
 *在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {
    XLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    XLog(@"location error");
}

#pragma mark TEST
-(CLLocationCoordinate2D)getActualLocation {
    return self.locService.userLocation.location.coordinate;
}

#pragma mark 广播接收释放/设置代理
-(void)LocationDelegateSwitch:(NSNotification*)delegateSwitch {
    NSString *switchInfo = (NSString*)delegateSwitch.object;
    XLog(@"位置功能 = %@",switchInfo);
    if ([switchInfo isEqualToString:DELEGATE_ON]) {
        self.locService.delegate = self;
//        self.mapView.delegate    = self;
    } else if ([switchInfo isEqualToString:DELEGATE_OFF]) {
        self.locService.delegate = nil;
    }
}
@end
