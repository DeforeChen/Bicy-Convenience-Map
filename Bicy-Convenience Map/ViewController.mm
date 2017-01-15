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

#import "BaiduLocationTool.h"
#import "BaiduDistrictTool.h"
#import "AppDelegate.h"
#import <SVProgressHUD/SVProgressHUD.h>
#import "BottomDistrictView.h"
#import "StattionsTableViewCell.h"
#import "plistManager.h"

@interface ViewController ()<BMKMapViewDelegate,stationInteractionDelegate>
@property (weak, nonatomic) IBOutlet BMKMapView *BaseBaiduMapView;
@property (nonatomic) BOOL isAccess;//百度授权/联网完成与否
@property (strong,nonatomic) BottomDistrictView* bottomView;

//防止底栏的列表被二次选中造成死循环
/*
 本类中选中annotation时，会在annotation didselect代理中去选中底栏list中对应的cell.
 也需要在 BottomDistrictView中加一个标志位，防止死循环发生
 
 底栏通过代理将索引传给本类，本类选中annotation，在annotaion didselect代理中会再去回选底栏的列表，造成死循环。
 这里通过一个标志位，如果是底栏发起的选中annotation，那么在annotation didselect代理中就不再去选中底栏。
 */
@property (nonatomic) BOOL noNeedToSelectStationList;
@end

@implementation ViewController
- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAccess                  = NO;
    self.noNeedToSelectStationList = NO;
    self.BaseBaiduMapView.logoPosition = BMKLogoPositionCenterBottom;
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
        } else {
            [self showTip];
        }
    };
    
    _BaseBaiduMapView.mapType = BMKMapTypeStandard;
    _BaseBaiduMapView.trafficEnabled = YES;
    
    //2. 添加底部的显示栏，用于作区域显示
    self.bottomView = [BottomDistrictView initMyView];
    self.bottomView.frame = SHOW_BOTTOM_ONLY_OPTION_RECT;
    self.bottomView.delegate = self;
    [self.view addSubview:self.bottomView];
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

-(void)setBaiduRelatedDelegate {
    self.BaseBaiduMapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    // 开启罗盘自动定位，设置loacation对应的delegate
    [[BaiduLocationTool initInstanceWithMapView:self.BaseBaiduMapView] startLocation];
    
    
    // 默认画出鼓楼区的边界，设置district对应的delegate
    [BaiduDistrictTool initInstanceWithMapView:self.BaseBaiduMapView];
    
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
//    NSLog(@"标记名 = %@",annotation.title);
    if ([annotation isKindOfClass:[BMKPointAnnotation class]]){
        MyPinAnnotationView *newAnnotationView = [[MyPinAnnotationView alloc] initWithCustomAnotation:annotation
                                                                                          isAnimation:YES];
        NSLog(@"width = %f, height = %f",newAnnotationView.frame.size.width,newAnnotationView.frame.size.height);
        return newAnnotationView;
    } else
        NSLog(@"???????????");
    return nil;
}

//选中对应的标注时的回调
-(void)mapView:(BMKMapView *)mapView didSelectAnnotationView:(BMKAnnotationView *)view {
    view.image = [UIImage imageNamed:@"站点_selected"];
    self.BaseBaiduMapView.centerCoordinate = view.annotation.coordinate;  //userLocation.location.coordinate;
    self.BaseBaiduMapView.zoomLevel        = ZOOM_LEVEL;
    NSUInteger index = [self.BaseBaiduMapView.annotations indexOfObject:view.annotation];
    if (self.noNeedToSelectStationList == YES) {
        self.noNeedToSelectStationList = NO;
    } else
        [self.bottomView selectCorrespondingCellInStationList:index];
}

-(void)mapView:(BMKMapView *)mapView didDeselectAnnotationView:(BMKAnnotationView *)view {
    view.image = [UIImage imageNamed:@"站点_deselected"];
    NSUInteger index = [self.BaseBaiduMapView.annotations indexOfObject:view.annotation];
    [self.bottomView deselectCorrespondingCellInStationList:index];
}

// 根据overlay生成对应的View
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
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
    [SVProgressHUD showErrorWithStatus:@"网络连接失败，请重试"];
    [self performSelector:@selector(dismiss)
               withObject:nil
               afterDelay:2.0];
}

-(void)dismiss{
    [SVProgressHUD dismiss];
}

#pragma mark stationInteractionDelegate 主页和底栏View的交互代理
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

#pragma mark 点击获取坐标信息
- (IBAction)fetchPoitCoordiate:(UITapGestureRecognizer *)sender {
    CGPoint point = [sender locationInView:self.BaseBaiduMapView];
    CLLocationCoordinate2D coo = [self.BaseBaiduMapView convertPoint:point toCoordinateFromView:self.BaseBaiduMapView];
    NSLog(@"经纬度:%lf, %lf", coo.longitude,  coo.latitude);
}

@end
