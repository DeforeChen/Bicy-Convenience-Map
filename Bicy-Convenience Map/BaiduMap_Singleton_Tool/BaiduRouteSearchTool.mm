//
//  BaiduRouteSearchTool.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/22.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "BaiduRouteSearchTool.h"
#import "RouteAnnotation.h"
#import <BaiduMapAPI_Utils/BMKUtilsComponent.h>

#define SELFCLASS_NAME BaiduRouteSearchTool
#define SELFCLASS_NAME_STR @"BaiduRouteSearchTool"
static BaiduRouteSearchTool *center = nil;//定义一个全局的静态变量，满足静态分析器的要求

@interface BaiduRouteSearchTool()<BMKRouteSearchDelegate>
@property (nonatomic,strong) BMKRouteSearch *routeSearch;
@property (nonatomic,strong) BMKPolyline* previousPolyLine;
@property (nonatomic,strong) NSMutableArray<RouteAnnotation*> *directionAnnotations;
@property (nonatomic) CLLocationCoordinate2D startPoint;
@property (nonatomic) CLLocationCoordinate2D endPoint;
@end


@implementation BaiduRouteSearchTool
#pragma mark 单例初始化
+ (instancetype)initInstanceWithMapView:(BMKMapView*)mapView {
    static dispatch_once_t predicate;
    //线程安全
    dispatch_once(&predicate, ^{
        center = (SELFCLASS_NAME *)SELFCLASS_NAME_STR;
        center = [[SELFCLASS_NAME alloc] init];
        center.mapView = mapView;
        center.routeSearch = [[BMKRouteSearch alloc] init];
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

-(NSMutableArray<RouteAnnotation *> *)directionAnnotations {
    if (_directionAnnotations == nil) {
        _directionAnnotations = [NSMutableArray new];
    }
    return _directionAnnotations;
}

#pragma mark 实例方法
- (void)pathGuideWithStart:(CLLocationCoordinate2D)startPoint end:(CLLocationCoordinate2D)endPoint {
    if ([self isSamePointWith:startPoint PointB:self.startPoint] && [self isSamePointWith:endPoint PointB:self.endPoint]) {
        [self.mapView addOverlay:self.previousPolyLine];
        [self mapViewFitPolyLine:self.previousPolyLine];
    } else {
        self.startPoint = startPoint;
        self.endPoint   = endPoint;
        
        BMKPlanNode *start = [[BMKPlanNode alloc] init];
        start.pt           = startPoint;
        BMKPlanNode *end  = [[BMKPlanNode alloc] init];
        end.pt            = endPoint;
        
        BMKWalkingRoutePlanOption *walkingRouteSearchOption = [[BMKWalkingRoutePlanOption alloc]init];
        walkingRouteSearchOption.from = start;
        walkingRouteSearchOption.to = end;
        BOOL flag = [_routeSearch walkingSearch:walkingRouteSearchOption];
        if(flag)
            XLog(@"walk检索发送成功");
        else
            XLog(@"walk检索发送失败");
    }
}

-(BOOL)isSamePointWith:(CLLocationCoordinate2D)PointA PointB:(CLLocationCoordinate2D)PointB {
    if (PointA.latitude == PointB.latitude && PointA.longitude == PointB.longitude) {
        return YES;
    } else
        return NO;
}

#pragma mark BMKRouteSearchDelegate
/**
 *返回骑行搜索结果
 *@param searcher 搜索对象
 *@param result 搜索结果，类型为BMKRidingRouteResult
 *@param error 错误号，@see BMKSearchErrorCode
 */
- (void)onGetWalkingRouteResult:(BMKRouteSearch*)searcher result:(BMKWalkingRouteResult*)result errorCode:(BMKSearchErrorCode)error {
    if (error == BMK_SEARCH_NO_ERROR) {
        BMKRidingRouteLine* plan = (BMKRidingRouteLine*)[result.routes objectAtIndex:0];
        NSInteger size = [plan.steps count];
        int planPointCounts = 0;
        // ---------------------- 处理标注 ---------------
        if (self.directionAnnotations.count != 0) {
            [self.mapView removeAnnotations:self.directionAnnotations];
            [self.directionAnnotations removeAllObjects];// 清空标注数组，等待下面操作中按条件添加标注
        }
        
        for (int i = 0; i < size; i++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:i];

            //添加annotation节点
            RouteAnnotation* item = [[RouteAnnotation alloc]init];
            item.coordinate = transitStep.entrace.location;
            item.title = transitStep.instruction;
            item.degree = (int)transitStep.direction * 30;
            item.type = 4;
            [self.directionAnnotations addObject:item];
            //轨迹点总数累计
            planPointCounts += transitStep.pointsCount;
        }
        [self.mapView addAnnotations:self.directionAnnotations];
        
        //轨迹点
        BMKMapPoint * temppoints = new BMKMapPoint[planPointCounts];
        int i = 0;
        for (int j = 0; j < size; j++) {
            BMKRidingStep* transitStep = [plan.steps objectAtIndex:j];
            int k=0;
            for(k=0;k<transitStep.pointsCount;k++) {
                temppoints[i].x = transitStep.points[k].x;
                temppoints[i].y = transitStep.points[k].y;
                i++;
            }
            
        }
        // ---------- 处理覆盖物 ---------------
        // 非空情况下，每次都要移除上一次创建的polygon
        if (self.previousPolyLine != nil) {
            [self.mapView removeOverlay:self.previousPolyLine];
        }

        self.previousPolyLine = [BMKPolyline polylineWithPoints:temppoints count:planPointCounts];
        [self.mapView addOverlay:self.previousPolyLine]; // 添加路线overlay
        delete []temppoints;
        [self mapViewFitPolyLine:self.previousPolyLine];
    }
}

//根据polyline设置地图范围
- (void)mapViewFitPolyLine:(BMKPolyline *) polyLine {
    CGFloat ltX, ltY, rbX, rbY;
    if (polyLine.pointCount < 1) {
        return;
    }
    BMKMapPoint pt = polyLine.points[0];
    ltX = pt.x, ltY = pt.y;
    rbX = pt.x, rbY = pt.y;
    for (int i = 1; i < polyLine.pointCount; i++) {
        BMKMapPoint pt = polyLine.points[i];
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

#pragma mark 广播接收释放/设置代理
-(void)LocationDelegateSwitch:(NSNotification*)delegateSwitch {
    NSString *switchInfo = (NSString*)delegateSwitch.object;
    XLog(@"导航功能 = %@",switchInfo);
    if ([switchInfo isEqualToString:DELEGATE_ON]) {
        self.routeSearch.delegate = self;
        //        self.mapView.delegate    = self;
    } else if ([switchInfo isEqualToString:DELEGATE_OFF]) {
        self.routeSearch.delegate = nil;
    }
}
@end
