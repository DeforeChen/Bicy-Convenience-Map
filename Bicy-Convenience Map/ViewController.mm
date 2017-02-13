//
//  ViewController.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/13.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "ViewController.h"
#import <BaiduMapAPI_Base/BMKMapManager.h>
#import <BaiduMapAPI_Map/BMKMapView.h>
#import <BaiduMapAPI_Map/BMKAnnotationView.h>
#import <BaiduMapAPI_Map/BMKMapComponent.h>
#import <BaiduMapAPI_Search/BMKDistrictSearch.h>

#import <SVProgressHUD/SVProgressHUD.h>
// 上下左右四个view
#import "BottomDistrictView.h"
#import "TopFunctionView.h"
#import "LeftMenuView.h"

#import "StattionsTableViewCell.h"
#import "plistManager.h"
#import "RouteAnnotation.h"

@interface ViewController ()<BMKMapViewDelegate,BottomViewInteractionDelegate,TopViewInteractionDelegate,LeftViewInteractionDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *BaseBaiduMapView;
@property (nonatomic) BOOL isAccess;//百度授权/联网完成与否
@property (strong,nonatomic) BottomDistrictView *bottomView;
@property (strong,nonatomic) TopFunctionView *topView;
//防止底栏的列表被二次选中造成死循环
/*
 本类中选中annotation时，会在annotation didselect代理中去选中底栏list中对应的cell.
 也需要在 BottomDistrictView中加一个标志位，防止死循环发生
 
 底栏通过代理将索引传给本类，本类选中annotation，在annotaion didselect代理中会再去回选底栏的列表，造成死循环。
 这里通过一个标志位，如果是底栏发起的选中annotation，那么在annotation didselect代理中就不再去选中底栏。
 */
@property (nonatomic) BOOL noNeedToSelectStationList;
@property (nonatomic) NSInteger previousAnnotationIndex;
@property (weak, nonatomic) IBOutlet UIButton *researchPathBtn;
@property (weak, nonatomic) IBOutlet UIButton *nearbyStationBtn;

@end

@implementation guideStartStationInfo

@end

@implementation guideEndStationInfo

@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAccess                          = NO;
    self.noNeedToSelectStationList         = NO;
    self.BaseBaiduMapView.logoPosition     = BMKLogoPositionLeftTop;
    self.BaseBaiduMapView.centerCoordinate = FUZHOU_CENTER_POINT;
    self.guideMode                         = NON_SELECT_MODE;
    self.previousAnnotationIndex           = UNREACHABLE_INDEX;

    BMKLocationViewDisplayParam *displayParam = [[BMKLocationViewDisplayParam alloc]init];
    displayParam.isRotateAngleValid = true;//跟随态旋转角度是否生效
    displayParam.isAccuracyCircleShow = false;//精度圈是否显示
    [self.BaseBaiduMapView updateLocationViewWithParam:displayParam];
    
    //1. 初次启动，等待百度的授权和联网完成，否则在viewdidappear中持续放HUD
    AppDelegate *app = (AppDelegate*)[UIApplication sharedApplication].delegate;
    app.accessCompleteBlk = ^(BOOL result){
        self.isAccess = result;
        if (result == YES) {
            [self setBaiduRelatedDelegate];
            plistManager *manager = [[plistManager alloc] initWithPlistName:PLIST_NAME];
            //1.1.从沙盒中取出行政区域边界信息plist用于绘制。如果plist不存在，就创建一个
            if ([manager ifPlistExist] == NO)
                [manager createPlist];
            
            //1.2读取这个plist文件
            NSDictionary *dict = [manager readPlist];
            if (dict.count == 0) {
                [[BaiduDistrictTool shareInstance] updateDistrictPlistWithSuccessBlk:^{
                    //调试用,读plist
                    NSDictionary *dict = [manager readPlist];
                    NSLog(@"空的plist重新获取数据后，读到的plist = %@",dict);
                    
                    [[BaiduDistrictTool shareInstance] generateOverlaysFromPlist];
                } FailBlk:^(NSError *err) {
                    NSLog(@"空的plist重新获取数据后，错误信息 = %@",err.domain);
                }];
            } else {// 3.2 已经读到正确的信息，就将这组数据转换为覆盖物
                [[BaiduDistrictTool shareInstance] generateOverlaysFromPlist];
            }
            [self dismissTip];
        } else {
            [self showTip];
        }
    };
    
    _BaseBaiduMapView.mapType            = BMKMapTypeStandard;
    _BaseBaiduMapView.trafficEnabled     = YES;
    
    //2. 添加底部的显示栏，用于作区域显示
    self.bottomView = [BottomDistrictView initMyView];
    self.bottomView.frame = SHOW_BOTTOM_ONLY_OPTION_RECT;
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
    [self.bottomView setHidden:YES];
    
    //3. 添加顶部的功能栏，用于定位及搜索提示
    self.topView = [TopFunctionView initMyView];
    self.topView.frame = CGRectMake(0, 20, self.topView.bounds.size.width, self.topView.bounds.size.height);
    self.topView.delegate = self;
    [self.view addSubview:self.topView];
    
    //4. 添加广播的收听，针对左侧栏选中搜索模式用
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(heardFromGuideMode:)
                                                 name:GUIDE_MODE_RADIO
                                               object:nil];
    
    //5. 添加站点的观察者。当start和end站点信息都不为空时，弹出路径规划的按钮，否则隐藏该按钮
    self.researchPathBtn.alpha = 0;
    self.researchPathBtn.userInteractionEnabled = NO;
    [self.guideEndStation addObserver:self
                           forKeyPath:@"name"
                              options:NSKeyValueObservingOptionNew
                              context:NULL];
    [self.guideStartStation addObserver:self
                             forKeyPath:@"name"
                                options:NSKeyValueObservingOptionNew
                                context:NULL];
}

-(void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary<NSKeyValueChangeKey,id> *)change context:(void *)context {
    if ([keyPath isEqualToString:@"name"]) {
        if (object == self.guideStartStation || object == self.guideEndStation) {
            if (self.guideEndStation.name != nil && self.guideStartStation.name != nil) {
                NSLog(@" ---- 触发触发 ----！！！！");
                [self animationForresearchPathBtn:YES];
            } else {
                NSLog(@"移除路线规划按键");
                [self animationForresearchPathBtn:NO];
            }
        }
    }
}

-(void)animationForresearchPathBtn:(BOOL)interactionEnabled {
    [UIView animateWithDuration:2*ANIMATION_TIME
                     animations:^{
                         if (interactionEnabled == YES) {
                             self.researchPathBtn.alpha = 1;
                         } else
                             self.researchPathBtn.alpha = 0;
                     }
                     completion:^(BOOL finished) {
                         [self.researchPathBtn setUserInteractionEnabled:interactionEnabled];
                     }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [_BaseBaiduMapView viewWillAppear];
    if (self.isAccess) {
        [self setBaiduRelatedDelegate];
    }
}

-(guideEndStationInfo *)guideEndStation {
    if (_guideEndStation == nil) {
        _guideEndStation = [[guideEndStationInfo alloc] init];
    }
    return _guideEndStation;
}

-(guideStartStationInfo *)guidStartStation {
    if (_guideStartStation == nil) {
        _guideStartStation = [[guideStartStationInfo alloc] init];
    }
    return _guideStartStation;
}

-(void)setBaiduRelatedDelegate {
    self.BaseBaiduMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    // 开启方向自动定位，设置loacation对应的delegate
    [[BaiduLocationTool initInstanceWithMapView:self.BaseBaiduMapView] startLocateWithBlk:nil];
    // 设置district对应的delegate
    [BaiduDistrictTool initInstanceWithMapView:self.BaseBaiduMapView];
    // 设置路径规划对应的delegate
    [BaiduRouteSearchTool initInstanceWithMapView:self.BaseBaiduMapView];
    
    [[NSNotificationCenter defaultCenter] postNotificationName:BAIDU_DELEGATE_CTRL_RADIO
                                                        object:DELEGATE_ON];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_BaseBaiduMapView viewWillDisappear];
    self.BaseBaiduMapView.delegate = nil; // 不用时，置nil
    [[NSNotificationCenter defaultCenter] postNotificationName:BAIDU_DELEGATE_CTRL_RADIO
                                                        object:DELEGATE_OFF];
}

#pragma mark BMKMapViewDelegate
-(BMKAnnotationView *)mapView:(BMKMapView *)mapView viewForAnnotation:(id<BMKAnnotation>)annotation {
    if ([annotation isKindOfClass:[RouteAnnotation class]]){
        BMKAnnotationView* view = [(RouteAnnotation*)annotation getRouteAnnotationView:mapView];
        return view;
//        NSLog(@"width = %f, height = %f",newAnnotationView.frame.size.width,newAnnotationView.frame.size.height);
        
    } else if ([annotation isKindOfClass:[BMKPointAnnotation class]]) {
        MyPinAnnotationView *newAnnotationView = [[MyPinAnnotationView alloc] initWithCustomAnotation:annotation
                                                                                          isAnimation:YES];
        return newAnnotationView;
    }
    return nil;
}

//选中对应的标注时的回调
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    switch (self.guideMode) {
        case NEARBY_GUIDE_MODE: {
            // 周边站点模式下，点击站点信息标注后，将当前的站点信息传到顶栏去
            if ([view isKindOfClass:[MyPinAnnotationView class]]) {
                view.image = [UIImage imageNamed:@"站点_selected"];
                self.guideEndStation.coordiate = view.annotation.coordinate;
                self.guideEndStation.name      = view.annotation.title;
                self.topView.endStation.text   = self.guideEndStation.name;
                self.previousAnnotationIndex   = [self.BaseBaiduMapView.annotations indexOfObject:view.annotation];
            }
        }
            break;
        case STATION_TO_STATION_MODE: {
            view.image = [UIImage imageNamed:@"站点_selected"];
            self.BaseBaiduMapView.centerCoordinate = view.annotation.coordinate;  //userLocation.location.coordinate;
            self.BaseBaiduMapView.zoomLevel        = ZOOM_LEVEL;

            if (self.noNeedToSelectStationList == YES) {
                self.noNeedToSelectStationList = NO;
                
            } else{
                self.previousAnnotationIndex   = [self.BaseBaiduMapView.annotations indexOfObject:view.annotation];
                [self.bottomView selectCorrespondingCellInStationList:self.previousAnnotationIndex];
            }
        }
            break;
        default:
            break;
    }
}

-(void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    switch (self.guideMode) {
        case NEARBY_GUIDE_MODE: {
            // 未选的标注是站点标注时，才需要去变更背景
            if ([view isKindOfClass:[MyPinAnnotationView class]]) {
                view.image = [UIImage imageNamed:@"站点_deselected"];
            }
        }
            break;
        case STATION_TO_STATION_MODE: {
            NSUInteger index = [self.BaseBaiduMapView.annotations indexOfObject:view.annotation];
            [self.bottomView deselectCorrespondingCellInStationList:index];
        }
            break;
        default:
            break;
    }
}

// 根据overlay生成对应的View
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    // 添加行政区域多边形区域
    if ([overlay isKindOfClass:[BMKPolygon class]]) {
        NSDictionary *dict = [BaiduDistrictTool shareInstance].districtPolyganDict;
        NSArray *districtNameArray = [dict allKeys];
        UIColor *fillcolor;
        for (NSString *name in districtNameArray) {
            if (overlay == dict[name]) {
                fillcolor = [self fetchDistrictOverlayColorWithName:name];
            }
        }
        
        BMKPolygonView *polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor     = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
        polygonView.fillColor       = fillcolor;
        polygonView.lineWidth       = 2;
        polygonView.lineDash        = YES;
        return polygonView;
    }
    
    // 添加当前位置周边的圆形区域
    if ([overlay isKindOfClass:[BMKCircle class]]) {
        BMKCircleView* circleView = [[BMKCircleView alloc] initWithOverlay:overlay];
        circleView.fillColor      = NEARBY_OVERLAY_COLOR;
        circleView.strokeColor    = [UIColor colorWithRed:145/255.0 green:149/255.0 blue:240/255.0 alpha:0.8];
        circleView.lineWidth      = 3.0;
        
        return circleView;
    }
    
    // 添加路径
    if ([overlay isKindOfClass:[BMKPolyline class]]) {
        BMKPolylineView* polylineView = [[BMKPolylineView alloc] initWithOverlay:overlay];
        polylineView.fillColor   = [UIColor redColor];//[[UIColor alloc] initWithRed:0 green:1 blue:1 alpha:1];
        polylineView.strokeColor = [[UIColor alloc] initWithRed:4/255.0 green:51/255.0 blue:255/255.0 alpha:0.7];
        polylineView.lineWidth   = 8.0;
        return polylineView;
    }
    
    return nil;
}

-(UIColor*)fetchDistrictOverlayColorWithName:(NSString*)name {
    if ([name isEqualToString:GULOU]) {
        return GULOU_OVERLAY_COLOR;
    } else if([name isEqualToString:TAIJIANG]) {
        return TAIJIANG_OVERLAY_COLOR;
    } else if([name isEqualToString:JINAN]) {
        return JINAN_OVERLAY_COLOR;
    } else if([name isEqualToString:CANGSHAN]) {
        return CANGSHAN_OVERLAY_COLOR;
    } else if([name isEqualToString:MAWEI]) {
        return MAWEI_OVERLAY_COLOR;
    } else
        return nil;
}

#pragma mark SVProgressHUD
-(void)showTip{
    [SVProgressHUD showErrorWithStatus:@"尝试数据请求，请检查你的网络"];
//    [self performSelector:@selector(dismiss)
//               withObject:nil
//               afterDelay:2.0];
}

-(void)dismissTip{
    [SVProgressHUD dismiss];
}

#pragma mark BottomViewInteractionDelegate 和底栏View的交互
-(void)startMapviewTransform {
    if (self.bottomView.frame.origin.y == HEIGHT-BTN_TOP_HEIGHT) {
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:15.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.bottomView.frame       = SHOW_BOTTOM_RECT;
                             self.BaseBaiduMapView.frame = SHOW_SHORT_MAPVIEW;
                         }
                         completion:nil];
    }
}

-(void)stopMapviewTransform {
    if (self.bottomView.frame.origin.y == HEIGHT-BOTTOM_RECT_HEIGHT) {
        [UIView animateWithDuration:ANIMATION_TIME
                              delay:0.0
             usingSpringWithDamping:0.5
              initialSpringVelocity:15.0
                            options:UIViewAnimationOptionBeginFromCurrentState
                         animations:^{
                             self.bottomView.frame       = SHOW_BOTTOM_ONLY_OPTION_RECT;
                             self.BaseBaiduMapView.frame = SCREEN_RECT;
                             [self.BaseBaiduMapView mapForceRefresh];
                         }
                         completion:nil];
    }
}

-(void)addOverlaysToDistrictWithName:(NSString *)districtName {
    [[BaiduDistrictTool shareInstance] showDistrictWithName:districtName];
}

-(void)selectCorrespondingAnnotation:(NSInteger)listIndex {
    self.noNeedToSelectStationList = YES;
    [self.BaseBaiduMapView selectAnnotation:self.BaseBaiduMapView.annotations[listIndex] animated:YES];
}

-(void)addAnnotationPointInDistrict:(NSArray<BMKPointAnnotation*>*)annotationArray {
    
    [self.BaseBaiduMapView removeAnnotations:self.BaseBaiduMapView.annotations];
    
    NSLog(@"移走标注否 = %@",self.BaseBaiduMapView.annotations);
    [self.BaseBaiduMapView addAnnotations:annotationArray];
    // 按键那边传过来当前区域，我们从字典中取出相应的annotation数组，添加到当前的页面上。
}

#pragma mark TopViewInteractionDelegate 和顶部栏的交互
-(void)addLeftMenuView {
    LeftMenuView *leftView = [[LeftMenuView alloc] initMyView];
    leftView.delegate      = self;
    leftView.frame = CGRectMake(-WIDTH, 72 , WIDTH, HEIGHT);
    [self.view addSubview:leftView];
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:0.5
          initialSpringVelocity:0.5
                        options:UIViewAnimationOptionOverrideInheritedCurve
                     animations:^{
                         leftView.frame = CGRectMake(0, 72, WIDTH, HEIGHT);
                     }
                     completion:nil];
}

-(void)removeLeftMenuView {
    for (UIView *view in self.view.subviews) {
        if ([view isKindOfClass:[LeftMenuView class]]) {
            CGRect rect = CGRectMake(-WIDTH, 60, WIDTH, HEIGHT);
            [UIView animateWithDuration:0.5
                                  delay:0
                 usingSpringWithDamping:1
                  initialSpringVelocity:0.3
                                options:UIViewAnimationOptionBeginFromCurrentState
                             animations:^{
                                 view.frame = rect;
                             }
                             completion:^(BOOL finished) {
                                 [view removeFromSuperview];
                             }];
            break;
        }
    }
}

-(void)resetStartStationInfo {

}

-(void)resetEndStationInfo {
    self.guideEndStation.name = nil;
    self.guideEndStation.coordiate = FUZHOU_CENTER_POINT;
    // 清楚annotation的选中状态，如果路径已规划好并显示，也需要一并移除
    for (id<BMKOverlay> overlay in self.BaseBaiduMapView.overlays) {
        if ([overlay isKindOfClass:[BMKPolyline class]]) {
            [self.BaseBaiduMapView removeOverlay:overlay];
            break;
        }
    }
    // 清楚路线引导类的标注
    for (id<BMKAnnotation>annotation in self.BaseBaiduMapView.annotations) {
        if ([annotation isKindOfClass:[RouteAnnotation class]]) {
            [self.BaseBaiduMapView removeAnnotation:annotation];
        }
    }

    [self.BaseBaiduMapView deselectAnnotation:self.BaseBaiduMapView.annotations[self.previousAnnotationIndex] animated:YES];
    [self reLocateMyPosition:nil];
}

#pragma mark LeftViewInteraction 和左侧栏的交互
-(void)heardFromGuideMode:(NSNotification*)info {
    NSNumber* modeObject = (NSNumber*)info.object;
    NSInteger mode = [modeObject integerValue];
    self.previousAnnotationIndex = UNREACHABLE_INDEX;//切换模式后，要清掉上一次的索引
    switch (mode) {
        case STATION_TO_STATION_MODE: {
            if (self.guideMode != STATION_TO_STATION_MODE) {
                // 0.导航模式进入站点间导航模式
                self.guideMode = STATION_TO_STATION_MODE;
                // 1.站点间搜索模式下，显示
                [self.bottomView setHidden:NO];
                [self.nearbyStationBtn setHidden:YES];
                // 2.路径规划按钮必须不显示
                self.researchPathBtn.alpha = 0;
                self.researchPathBtn.userInteractionEnabled = NO;
                
                // 先移除所有标注和覆盖物,再添加标注
                [self.BaseBaiduMapView removeAnnotations:self.BaseBaiduMapView.annotations];
                [self.BaseBaiduMapView removeOverlays:self.BaseBaiduMapView.overlays];
            }
        }
            break;
        case NEARBY_GUIDE_MODE: {
            if (self.guideMode != NEARBY_GUIDE_MODE) {
                self.guideMode = NEARBY_GUIDE_MODE;
                [self.bottomView setHidden:YES];
                [self.nearbyStationBtn setHidden:NO];
                self.researchPathBtn.alpha = 0;
                self.researchPathBtn.userInteractionEnabled = NO;
                
                [self doNearbyStationSearchActioin];
            }
        }
            break;
        default:
            break;
    }
}

-(void)addNearbyStationAnnotations:(NSArray<BMKPointAnnotation *> *)stationAnnotations CircleWithRadius:(NSInteger)radius CircleWithCenter:(CLLocationCoordinate2D)center {
    // 先移除所有标注和覆盖物,再添加标注
    [self.BaseBaiduMapView removeAnnotations:self.BaseBaiduMapView.annotations];
    [self.BaseBaiduMapView removeOverlays:self.BaseBaiduMapView.overlays];
    [self.BaseBaiduMapView addAnnotations:stationAnnotations];
    
    // 添加圆形覆盖物，并将当前位置显示在区域中央
    BMKCircle* circle = [BMKCircle circleWithCenterCoordinate:center radius:radius];
    [self.BaseBaiduMapView addOverlay:circle];
    self.BaseBaiduMapView.centerCoordinate = center;
    self.BaseBaiduMapView.zoomLevel        = ZOOM_LEVEL;
    [self stopMapviewTransform];
}

-(void)finishedRemoveLeftView {
    //已移除左侧栏，通知顶部栏的两个功能键恢复原状
    [self.topView setFunctionBtnDeselectedState];
}

#pragma mark 交互
- (IBAction)ZoomCtrl:(UIButton *)sender {
    if ([[sender restorationIdentifier] isEqualToString:@"zoomin"]) {
        self.BaseBaiduMapView.zoomLevel += 0.3;
    } else if ([[sender restorationIdentifier] isEqualToString:@"zoomout"]) {
        self.BaseBaiduMapView.zoomLevel -= 0.3;
    }
}

- (IBAction)reLocateMyPosition:(UIButton *)sender {
    CLLocationCoordinate2D actualLocation = [BaiduLocationTool shareInstance].getActualLocation;
    self.BaseBaiduMapView.centerCoordinate = actualLocation;
    self.BaseBaiduMapView.zoomLevel        = ZOOM_LEVEL;
}

- (IBAction)researchPath:(UIButton *)sender {
    CLLocationCoordinate2D startPoint = [[BaiduLocationTool shareInstance] getActualLocation];
    CLLocationCoordinate2D endPoint   = self.guideEndStation.coordiate;
    [[BaiduRouteSearchTool shareInstance] pathGuideWithStart:startPoint end:endPoint];
}

- (IBAction)searchNearbyStation:(UIButton *)sender {
    [self doNearbyStationSearchActioin];
}

-(void)doNearbyStationSearchActioin {
    /*
     1. 定位到当前位置
     2. 调用BMKGeometry，组合出所有在圆形区域内的站点数组，通过代理，连同刚刚的圆形区域，这两个覆盖物，传给主页
     */
    [[BaiduLocationTool shareInstance] startLocateWithBlk:^(CLLocationCoordinate2D myLacation) {
        NSArray<BMKPointAnnotation*> *nearbyStationAnnotations = [[StationInfo shareInstance] fetchNearbyStationAnnotationWithPoint:myLacation];
        self.guidStartStation.coordiate = myLacation;
        self.guidStartStation.name      = @"我的位置";
        
        [self addNearbyStationAnnotations:nearbyStationAnnotations
                         CircleWithRadius:NEARBY_RADIUS
                         CircleWithCenter:myLacation];
    }];
}



#pragma mark 测试部分
- (IBAction)fetchPoitCoordiate:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.BaseBaiduMapView];
    CLLocationCoordinate2D coo = [self.BaseBaiduMapView convertPoint:point toCoordinateFromView:self.BaseBaiduMapView];
    NSLog(@"经纬度:%lf, %lf", coo.longitude,  coo.latitude);
}


@end
