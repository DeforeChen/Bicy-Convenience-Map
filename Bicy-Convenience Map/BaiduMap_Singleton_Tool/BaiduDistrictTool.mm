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
@property (nonatomic,strong) NSMutableArray *districtPolyganArray;
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

-(NSMutableArray *)districtPolyganArray {
    if (_districtPolyganArray == nil) {
        _districtPolyganArray = [[NSMutableArray alloc] init];
    }
    return _districtPolyganArray;
}

#pragma mark 实例化方法
-(void)showDistrictWithName:(NSString*)districtName {
    plistManager *manager = [[plistManager alloc] initWithPlistName:PLIST_NAME];
    NSDictionary *districtOutlineDict = [manager readPlist];
    //1.初始化保存行政区域多边形的数组
    if (self.districtPolyganArray.count == 0) {
//        NSDictionary *districtOutlineDict = [manager readPlist];
        NSArray *keysArray = [districtOutlineDict allKeys];
        for (NSString* key in keysArray) {
            [self.districtPolyganArray addObject:[self transferPathStringToPolygon:districtOutlineDict[key]]];
        }
    }
    
    if ([districtName isEqualToString:ALL_CITY]) {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlays:self.districtPolyganArray];
    } else {
        [self.mapView removeOverlays:self.mapView.overlays];
        [self.mapView addOverlay:[self transferPathStringToPolygon:districtOutlineDict[districtName]]];
        [self mapViewFitPolygon:[self transferPathStringToPolygon:districtOutlineDict[districtName]]];
    }
        
//        BMKPolygon* polygon = [self transferPathStringToPolygon:path];
//        if (polygon) {
//            [self.mapView addOverlay:polygon]; // 添加overlay
//            if (flag) {
//                [self mapViewFitPolygon:polygon];
//                flag = NO;
//            }
//        }
    
}

- (void)updateDistrictOutlineInfoWithSuccessBlk:(districtSucBlk)sucBlk
                                        FailBlk:(districtFailBlk)failBlk {
    [self resetDistrictParams];
    //放入通知
    self.successBlk = sucBlk;
    self.failBlk    = failBlk;
    
    [self searchDistrictOuntlineWithName:GULOU];
}

-(void)resetDistrictParams {
    //更新之前先将字典和计数器置空
    self.districtOutlineInfoDict = nil;
    self.searchDistrictTimes     = 0;
    NSMutableArray *array        = [NSMutableArray arrayWithObjects:GULOU,TAIJIANG,JINAN,CANGSHAN,MAWEI, nil];
    self.districtNameArray       = array;
    [self.districtPolyganArray removeAllObjects];
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
