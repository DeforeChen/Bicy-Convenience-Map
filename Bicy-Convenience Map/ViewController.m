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

@interface ViewController ()<BMKMapViewDelegate>
@property (nonatomic,strong) BMKMapView *mapView;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _mapView = [[BMKMapView alloc]initWithFrame:self.view.bounds];
    _mapView.mapType = BMKMapTypeStandard;
    _mapView.trafficEnabled = YES;
    _mapView.delegate = self; // 此处记得不用的时候需要置nil，否则影响内存的释放
    self.view = _mapView;
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)viewWillAppear:(BOOL)animated {
    [_mapView viewWillAppear];
    
    // 添加一个PointAnnotation
    BMKPointAnnotation* annotationA = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coor;
    coor.latitude = 39.915;
    coor.longitude = 116.404;
    annotationA.coordinate = coor;
    annotationA.title = @"这里是北京";
    [_mapView addAnnotation:annotationA];
    [_mapView selectAnnotation:annotationA animated:YES];
    
    BMKPointAnnotation* annotationB = [[BMKPointAnnotation alloc]init];
    CLLocationCoordinate2D coorB;
    coorB.latitude = 39.945;
    coorB.longitude = 116.444;
    annotationB.coordinate = coorB;
    annotationB.title = @"不知在哪里";
    [_mapView addAnnotation:annotationB];
    [_mapView selectAnnotation:annotationB animated:YES];
//    NSArray *array = [NSArray arrayWithObjects:annotationB,annotationA, nil];
//    [_mapView addAnnotations:array];
}

-(void)viewWillDisappear:(BOOL)animated {
    [_mapView viewWillDisappear];
    _mapView.delegate = nil; // 不用时，置nil
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

@end
