//
//  BaiduDistrictTool.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/16.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BaiduDistrictTool.h"
#import "plistManager.h"
#define SELFCLASS_NAME BaiduDistrictTool
#define SELFCLASS_NAME_STR @"BaiduDistrictTool"

static BaiduDistrictTool *center = nil;//定义一个全局的静态变量，满足静态分析器的要求

@interface BaiduDistrictTool()<BMKDistrictSearchDelegate>
@property (nonatomic,strong) BMKDistrictSearch *districtSearch;
@property (nonatomic,strong) NSMutableDictionary *districtOutlineInfoDict;
@property (nonatomic,strong) NSMutableArray *districtNameArray;
@property (nonatomic,strong) NSMutableDictionary *districtPolyganDict;
//更新行政区域边界时用。比如发起5次搜索，在代理回调中判断写入的次数是否和他对等。如果不对等或有其他错误，那么block返回失败
@property (nonatomic) int searchDistrictTimes;
@property (nonatomic,strong) districtSucBlk successBlk;
@property (nonatomic,strong) districtFailBlk failBlk;
@end

@implementation BaiduDistrictTool
#pragma mark 单例初始化
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView {
    static dispatch_once_t predicate;
    //线程安全
    dispatch_once(&predicate, ^{
        center = (SELFCLASS_NAME *)SELFCLASS_NAME_STR;
        center = [[SELFCLASS_NAME alloc] init];
        center.mapView = mapView;
        center.districtSearch = [[BMKDistrictSearch alloc] init];
        // 添加广播收听者，接收主页控制的代理创建/销毁
        [[NSNotificationCenter defaultCenter] addObserver:center
                                                 selector:@selector(DistrictDelegateSwitch:)
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
#pragma mark getter method
-(NSMutableDictionary *)districtOutlineInfoDict {
    if (_districtOutlineInfoDict == nil) {
        _districtOutlineInfoDict = [[NSMutableDictionary alloc] init];
    }
    return _districtOutlineInfoDict;
}

-(NSMutableArray *)districtNameArray {
    if (_districtNameArray == nil) {
        _districtNameArray = [[NSMutableArray alloc] init];
    }
    return _districtNameArray;
}

-(NSMutableDictionary *)districtPolyganDict {
    if (_districtPolyganDict == nil) {
        _districtPolyganDict = [[NSMutableDictionary alloc] init];
    }
    return _districtPolyganDict;
}

#pragma mark 实例化方法
-(void)showDistrictWithName:(NSString*)districtName {
    //先清空所有的覆盖物
    [self.mapView removeOverlays:self.mapView.overlays];
    // 根据对应的需求，添加覆盖物
    if ([districtName isEqualToString:ALL_CITY]) {
        [self.mapView addOverlays:self.districtPolyganDict[ALL_CITY]];
        [self mapViewFitPolygon:self.districtPolyganDict[ALL_CITY_POLYGAN_FIT]];
    } else {
        [self.mapView addOverlay:self.districtPolyganDict[districtName]];
        [self mapViewFitPolygon:self.districtPolyganDict[districtName]];
    }
}

- (void)updateDistrictPlistWithSuccessBlk:(districtSucBlk)sucBlk
                                  FailBlk:(districtFailBlk)failBlk {
    [self resetDistrictParams];
    //放入通知
    self.successBlk = sucBlk;
    self.failBlk    = failBlk;
    
    [self searchDistrictOuntlineWithName:GULOU];
}

/**
 将plist中读出的区域边界坐标信息，转换为一个字典，保存每个区域的多边形覆盖物数据
 */
-(void)generateOverlaysFromPlist {
    // 1. 读出plist数据
    plistManager *manager = [[plistManager alloc] initWithPlistName:PLIST_NAME];
    NSDictionary *districtOutlineDict = [manager readPlist];
    if (districtOutlineDict == nil) {
        NSLog(@"读取到了错误的plist信息错误");
    } else {
        NSArray *districtNameArray           = [districtOutlineDict allKeys];
        NSMutableArray *districtPolyganArray = [NSMutableArray new];
        // 2.1字典中，除了前五个value是NSString，最后一个ALL_CITY的value是一个NSArray
        for (NSString *name in districtNameArray) {
            BMKPolygon *polygan = [self transferPathStringToPolygon:districtOutlineDict[name]];
            [self.districtPolyganDict setValue:polygan forKey:name];
            [districtPolyganArray addObject:polygan];
        }
        
        // 2.2将所有的边界坐标拼成一个长的字符串，并转换成多边形，用于“全市显示”时的屏幕适配
        NSMutableString *polyganStr = [NSMutableString new];
        for (int i; i<DISTRICT_NUM; i++) {
            NSString *str = [NSString stringWithFormat:@"%@,",[[districtOutlineDict allValues] objectAtIndex:i]];
            [polyganStr appendString:str];
        }
        [polyganStr deleteCharactersInRange:NSMakeRange(polyganStr.length-1, 1)];//去掉最后一个逗号
        
        [self.districtPolyganDict setValue:districtPolyganArray forKey:ALL_CITY];
        [self.districtPolyganDict setValue:[self transferPathStringToPolygon:polyganStr] forKey:ALL_CITY_POLYGAN_FIT];
        NSLog(@"转换后的字典 = %@",self.districtPolyganDict);
    }
}

-(void)resetDistrictParams {
    //更新之前先将字典和计数器置空
    self.districtOutlineInfoDict = nil;
    self.searchDistrictTimes     = 0;
    NSMutableArray *array        = [NSMutableArray arrayWithObjects:GULOU,TAIJIANG,JINAN,CANGSHAN,MAWEI, nil];
    self.districtNameArray       = array;
    [self.districtPolyganDict removeAllObjects];
}

-(void)searchDistrictOuntlineWithName:(NSString*)districtName {
    BMKDistrictSearchOption *option = [[BMKDistrictSearchOption alloc] init];
    option.city     = @"福州";
    option.district = districtName;
    [self.districtSearch districtSearch:option];//onGetDistrictResult中回调结果
}

#pragma mark 区域搜索代理
/**
 *返回行政区域搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结BMKDistrictSearch果
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetDistrictResult:(BMKDistrictSearch *)searcher result:(BMKDistrictResult *)result errorCode:(BMKSearchErrorCode)error {
    //从区域名数组中将目前已搜到的区域remove，然后将数组中剩下的区域名取出，进行下一步搜索
    [self.districtNameArray removeObject:result.name];
    NSLog(@"区域数组内容=%@,当前搜索区域名=%@,调用次数 = %d",self.districtNameArray,result.name,self.searchDistrictTimes);

    self.searchDistrictTimes++;
    if (self.districtNameArray.count != 0) {
        [self searchDistrictOuntlineWithName:self.districtNameArray.lastObject];
    }
    
    NSLog(@"onGetDistrictResult error: %d", error);
    if (error == BMK_SEARCH_NO_ERROR) {
        NSLog(@"\nname:%@\ncode:%d\ncenter latlon:%lf,%lf", result.name, (int)result.code, result.center.latitude, result.center.longitude);
        //将当前拿到的区域边界的坐标，存入字典
        [self.districtOutlineInfoDict setObject:result.paths.lastObject forKey:result.name];
    }
    
    if (self.searchDistrictTimes == DISTRICT_NUM) {
        //当存满5个(不同区域)时，写入到沙盒中对应的plist里
        if (self.districtOutlineInfoDict.count == DISTRICT_NUM) {
            //更新沙盒数据，存入plist
            NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
            NSLog(@"写入路径%@", path);
            NSString *fileName = [path stringByAppendingPathComponent:@"districtOutlineInfo.plist"];
            if ([self.districtOutlineInfoDict writeToFile:fileName atomically:YES]) {
                self.successBlk();
            } else{
                NSError *err = [NSError errorWithDomain:@"write to plist in sandbox error" code:0 userInfo:nil];
                self.failBlk(err);
            }
        } else {
            NSError *err = [NSError errorWithDomain:@"get some district info error" code:1 userInfo:nil];
            self.failBlk(err);
        }
    }
}

//根据polygone设置地图范围
- (void)mapViewFitPolygon:(BMKPolygon *) polygon {
    CGFloat ltX, ltY, rbX, rbY;
    if (polygon.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polygon.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polygon.pointCount; i++) {
        BMKMapPoint pt = polygon.points[i];
        if (pt.x < ltX) {
            ltX = pt.x;
        }
        if (pt.x > rbX) {
            rbX = pt.x;
        }
        if (pt.y > ltY) {
            ltY = pt.y;
        }
        if (pt.y < rbY) {
            rbY = pt.y;
        }
    }
    BMKMapRect rect;
    rect.origin = BMKMapPointMake(ltX , ltY);
    rect.size = BMKMapSizeMake(rbX - ltX, rbY - ltY);
    [self.mapView setVisibleMapRect:rect];
    self.mapView.zoomLevel = self.mapView.zoomLevel - 0.3;
}

- (BMKPolygon*)transferPathStringToPolygon:(NSString*) path {
    if (path == nil || path.length < 1) {
        return nil;
    }
    NSArray *pts = [path componentsSeparatedByString:@";"];
    if (pts == nil || pts.count < 1) {
        return nil;
    }
    BMKMapPoint *points = new BMKMapPoint[pts.count];
    NSInteger index = 0;
    for (NSString *ptStr in pts) {
        if (ptStr && [ptStr rangeOfString:@","].location != NSNotFound) {
            NSRange range = [ptStr rangeOfString:@","];
            NSString *xStr = [ptStr substringWithRange:NSMakeRange(0, range.location)];
            NSString *yStr = [ptStr substringWithRange:NSMakeRange(range.location + range.length, ptStr.length - range.location - range.length)];
            if (xStr && xStr.length > 0 && [xStr respondsToSelector:@selector(doubleValue)]
                && yStr && yStr.length > 0 && [yStr respondsToSelector:@selector(doubleValue)]) {
                points[index] = BMKMapPointMake(xStr.doubleValue, yStr.doubleValue);
                index++;
            }
        }
    }
    BMKPolygon *polygon = nil;
    if (index > 0) {
        polygon = [BMKPolygon polygonWithPoints:points count:index];
    }
    delete [] points;
    return polygon;
}

#pragma mark 释放/创建代理开关
-(void)DistrictDelegateSwitch:(NSNotification*)delegateSwitch {
    NSString *switchInfo = (NSString*)delegateSwitch.object;
    NSLog(@"区域功能 = %@",switchInfo);
    if ([switchInfo isEqualToString:DELEGATE_ON]) {
        self.districtSearch.delegate = self;
    } else if ([switchInfo isEqualToString:DELEGATE_OFF]) {
        self.districtSearch.delegate = nil;
    }
}
@end
