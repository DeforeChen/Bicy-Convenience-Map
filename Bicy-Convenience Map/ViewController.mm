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
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.isAccess = NO;
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
                // 3.2 已经读到正确的信息，就将这组数据转换为覆盖物
            } else {
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
    
    
    //    // 添加一个PointAnnotation
    //    BMKPointAnnotation* annotationA = [[BMKPointAnnotation alloc]init];
    //    CLLocationCoordinate2D coor;
    //    coor.latitude = 39.915;
    //    coor.longitude = 116.404;
    //    annotationA.coordinate = coor;
    //    annotationA.title = @"这里是北京";
    //
    //    BMKPointAnnotation* annotationB = [[BMKPointAnnotation alloc]init];
    //    CLLocationCoordinate2D coorB;
    //    coorB.latitude = 39.945;
    //    coorB.longitude = 116.444;
    //    annotationB.coordinate = coorB;
    //    annotationB.title = @"不知在哪里";
    //    NSArray *array = [NSArray arrayWithObjects:annotationB,annotationA, nil];
    //    [self.BaseBaiduMapView addAnnotations:array];
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
    NSLog(@"标记名 = %@",annotation.title);
    if ([annotation isKindOfClass:[BMKPointAnnotation class]] && [annotation.title isEqualToString:@"这里是北京"]) {
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"myAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorPurple;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    } else if([annotation isKindOfClass:[BMKPointAnnotation class]]){
        BMKPinAnnotationView *newAnnotationView = [[BMKPinAnnotationView alloc] initWithAnnotation:annotation reuseIdentifier:@"newAnnotation"];
        newAnnotationView.pinColor = BMKPinAnnotationColorRed;
        newAnnotationView.animatesDrop = YES;// 设置该标注点动画显示
        return newAnnotationView;
    }
    return nil;
}

// 根据overlay生成对应的View
- (BMKOverlayView*)mapView:(BMKMapView *)map viewForOverlay:(id<BMKOverlay>)overlay {
    if ([overlay isKindOfClass:[BMKPolygon class]]) {
        BMKPolygonView *polygonView = [[BMKPolygonView alloc] initWithOverlay:overlay];
        polygonView.strokeColor     = [UIColor colorWithRed:1 green:0 blue:0 alpha:0.6];
        polygonView.fillColor       = [UIColor colorWithRed:1 green:1 blue:0 alpha:0.4];
        polygonView.lineWidth       = 1;
        polygonView.lineDash        = YES;
        return polygonView;
    }
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

#pragma mark stationInteractionDelegate
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

-(void)selDistrictWithName:(NSString *)districtName {
    [[BaiduDistrictTool shareInstance] showDistrictWithName:districtName];
    //    [[BaiduDistrictTool shareInstance] searchDistrictWithName:districtName];
}
@end
