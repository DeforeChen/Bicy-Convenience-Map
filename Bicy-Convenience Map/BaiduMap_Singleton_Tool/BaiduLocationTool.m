//
//  BaiduLocationTool.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BaiduLocationTool.h"
#define SELFCLASS_NAME BaiduLocationTool
#define SELFCLASS_NAME_STR @"BaiduLocationTool"

static BaiduLocationTool *center = nil;//定义一个全局的静态变量，满足静态分析器的要求

@interface BaiduLocationTool()<BMKLocationServiceDelegate>
@property (nonatomic,strong) BMKLocationService* locService;
@property (nonatomic) BOOL setCurrentLocCenter;//开启定位时这个值置TRUE一次，让当前位置居中
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

-(void)startLocation {
    NSLog(@"进入罗盘定位状态");
    [self.locService startUserLocationService];
    self.mapView.showsUserLocation  = NO;//先关闭显示的定位图层
    self.mapView.userTrackingMode   = BMKUserTrackingModeNone;//BMKUserTrackingModeFollowWithHeading;//设置定位的状态
    self.mapView.showsUserLocation  = YES;//显示定位图层
    self.setCurrentLocCenter        = YES;
}

#pragma mark 代理实现
/**
 *在地图View将要启动定位时，会调用此函数
 */
- (void)willStartLocatingUser {
    NSLog(@"start locate");
}

/**
 *用户方向更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateUserHeading:(BMKUserLocation *)userLocation {
    [self.mapView updateLocationData:userLocation];
    NSLog(@"heading is %@",userLocation.heading);
}

/**
 *用户位置更新后，会调用此函数
 *@param userLocation 新的用户位置
 */
- (void)didUpdateBMKUserLocation:(BMKUserLocation *)userLocation {
//        NSLog(@"didUpdateUserLocation lat %f,long %f",userLocation.location.coordinate.latitude,userLocation.location.coordinate.longitude);
    [self.mapView updateLocationData:userLocation];
    if (self.setCurrentLocCenter == YES) {
        self.mapView.centerCoordinate = userLocation.location.coordinate;
        self.setCurrentLocCenter = NO;
    }
    
    
}

/**
 *在地图View停止定位后，会调用此函数
 */
- (void)didStopLocatingUser {
    NSLog(@"stop locate");
}

/**
 *定位失败后，会调用此函数
 *@param error 错误号，参考CLError.h中定义的错误号
 */
- (void)didFailToLocateUserWithError:(NSError *)error {
    NSLog(@"location error");
}

#pragma mark 广播接收释放/设置代理
-(void)LocationDelegateSwitch:(NSNotification*)delegateSwitch {
    NSString *switchInfo = (NSString*)delegateSwitch.object;
    NSLog(@"位置功能 = %@",switchInfo);
    if ([switchInfo isEqualToString:DELEGATE_ON]) {
        self.locService.delegate = self;
//        self.mapView.delegate    = self;
    } else if ([switchInfo isEqualToString:DELEGATE_OFF]) {
        self.locService.delegate = nil;
    }
}
@end
