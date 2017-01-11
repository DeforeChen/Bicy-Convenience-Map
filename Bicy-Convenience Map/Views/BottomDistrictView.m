//
//  BottomDistrictView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/20.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BottomDistrictView.h"
#import "StattionsTableViewCell.h"
#import "config.h"
#import "StationInfo.h"

@interface BottomDistrictView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic) BOOL isSelected;
@property (nonatomic,strong) NSArray<id<stationProtocol>>* stationInfoArray;
@property (nonatomic) BOOL needReload;
//防止底栏的列表被二次选中造成死循环
/*
 本类中选中annotation时，会在annotation didselect代理中去选中底栏list中对应的cell.
 也需要在 BottomDistrictView中加一个标志位，防止死循环发生
 
 底栏通过代理将索引传给本类，本类选中annotation，在annotaion didselect代理中会再去回选底栏的列表，造成死循环。
 这里通过一个标志位，如果是底栏发起的选中annotation，那么在annotation didselect代理中就不再去选中底栏。
 */
@property (nonatomic) BOOL noNeedToSelectAnnotation;
@end

@implementation BottomDistrictView
- (void)setup {
    self.noNeedToSelectAnnotation = NO;
    self.needReload               = NO;
    self.opaque      = NO;//不透明
    self.contentMode = UIViewContentModeRedraw;//如果bounds变化了，就要重新绘制它
} //通常是里面放的是当前UIView是否要透明，透明度多少等等的optimize选项
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
    // 启动页面的时候去更新一次站点信息数据
    [[StationInfo shareInstance]updateAllStationsInfoWithSuccessBlk:^{
        
    } FailBlk:^(NSError *err) {
        NSLog(@"错误信息 = %@",err.description);
    }];
}

- (IBAction)selectRelatedDistrict:(DistrictButton *)sender {
    if (sender.isSelected == NO) {
        [sender switchToSelectedState];
        sender.isSelected = YES;
        NSString *districtName = [sender restorationIdentifier];

        self.stationInfoArray    = [[StationInfo shareInstance] fetchDistrictStationsInfoWithName:districtName];
        NSArray *annotationArray = [[StationInfo shareInstance] fetchDistrictStationAnnotationWithArray:self.stationInfoArray];
        self.needReload = YES;
        [self.stationList reloadData];

        [[NSNotificationCenter defaultCenter] postNotificationName:DISTRICT_BTN_SEL_RADIO
                                                            object:districtName];
        [self.delegate startMapviewTransform];
        [self.delegate addOverlaysToDistrictWithName:districtName];
        [self.delegate addAnnotationPointInDistrict:annotationArray];
    }
}

- (IBAction)startDownAnimation:(UIButton *)sender {
    [self.delegate stopMapviewTransform];
}

+ (instancetype) initMyView {
    BottomDistrictView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                             owner:nil
                                                           options:nil].lastObject;

    return view;
}

-(void)selectCorrespondingCellInStationList:(NSInteger)listIndex {
    self.noNeedToSelectAnnotation = YES;
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:listIndex
                                                inSection:0];
    [self.stationList scrollToRowAtIndexPath:indexpath
                            atScrollPosition:UITableViewScrollPositionMiddle
                                    animated:YES];  //滚动到第5行
    [self.stationList selectRowAtIndexPath:indexpath
                                  animated:YES
                            scrollPosition:UITableViewScrollPositionMiddle];  //选中第n行
    [self tableView:self.stationList didSelectRowAtIndexPath:indexpath];
}

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stationInfoArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return BTN_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static  NSString *const OptionTableReuseID = @"reuseID";        //设立reuse池的标签名（或者说池子的名称）
    //表示从现有的池子（标签已指定）取出排在队列最前面的那个 cell
    StattionsTableViewCell* cell = (StattionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:OptionTableReuseID];
    if (cell == nil) {
        cell = [StattionsTableViewCell initMyCell];
    } else{
        
    }
    cell.stationAddress.text = [self.stationInfoArray[indexPath.row] stationAddress];
    cell.stationName.text    = [self.stationInfoArray[indexPath.row] stationName];
    //从数组中取出对应的文本，贴给当前的这个cell，index是随着回滚事件代理调用的对应路径
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"XUANZHONG");
    StattionsTableViewCell *cell = (StattionsTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.stationBgImage.image = [UIImage imageNamed:@"站点单元栏_selected"];
    [cell.gotoBtn setHidden:NO];
    if (self.noNeedToSelectAnnotation == YES) {
        self.noNeedToSelectAnnotation = NO;
    } else {
        [self.delegate selectCorrespondingAnnotation:indexPath.row];
    }
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"FEI____XUANZHONG");
}
@end
