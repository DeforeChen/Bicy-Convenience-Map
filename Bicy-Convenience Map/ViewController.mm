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

@interface ViewController ()<BMKMapViewDelegate,UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet BMKMapView *BaseBaiduMapView;
@property (nonatomic) BOOL isAccess;//百度授权/联网完成与否
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
        } else {
            [self showTip];
        }
    };
    
    _BaseBaiduMapView.mapType = BMKMapTypeStandard;
    _BaseBaiduMapView.trafficEnabled = YES;

    //2. 添加底部的显示栏，用于作区域显示
    BottomDistrictView* vc = [BottomDistrictView initMyViewWithOwner:self];
    vc.frame = CGRectMake(0, HEIGHT-BOTTOM_OPTION_HEIGHT, WIDTH, vc.frame.size.height);
    [self.view addSubview:vc];
    
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
    [[BaiduLocationTool shareInstanceWithMapView:self.BaseBaiduMapView] startLocation];
    // 默认画出鼓楼区的边界，设置district对应的delegate
    [[BaiduDistrictTool shareInstanceWithMapView:self.BaseBaiduMapView] searchDistrictWithName:@"鼓楼"];

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

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 2;//self.stationInfoArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 42.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *const OptionTableReuseID = @"reuseID";        //设立reuse池的标签名（或者说池子的名称）
    //表示从现有的池子（标签已指定）取出排在队列最前面的那个 cell
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:OptionTableReuseID];
    NSLog(@"reuseid = %@,RestorationIdentifier = %@",cell.reuseIdentifier,cell.restorationIdentifier);
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:OptionTableReuseID];
        cell.textLabel.text = @"new";
        
        //填一段假数据用来调试
        StationInfo *infoA = [[StationInfo alloc] init];
        infoA.stationName = @"象峰一路站";
        infoA.stationAddress = @"秀峰支路XX号";
        
        StationInfo *infoB = [[StationInfo alloc] init];
        infoB.stationName = @"信和广场站";
        infoB.stationAddress = @"五四路xx前xx号";
        
        NSArray *stationInfoArray = [NSArray arrayWithObjects:infoA,infoB, nil];
                cell = [StattionsTableViewCell initMyCellWithStationName:[stationInfoArray[indexPath.row] stationName]
                                                          StationAddress:[stationInfoArray[indexPath.row] stationAddress]];
        
    } else{
        NSLog(@"Reused cell = %@",cell.textLabel.text);//为了调试好看，正常并不需要else
    }
    
    //从数组中取出对应的文本，贴给当前的这个cell，index是随着回滚事件代理调用的对应路径
    return cell;
}

@end
