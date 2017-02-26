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
#import <SVProgressHUD/SVProgressHUD.h>

@interface BottomDistrictView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic) BOOL isSelected;
@property (nonatomic,strong) NSArray<id<stationProtocol>>* stationInfoArray;
@property (nonatomic) NSInteger previousSelIndex;
@property (weak, nonatomic) IBOutlet DistrictButton *allcityBtn;

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
    self.opaque      = NO;//不透明
    self.contentMode = UIViewContentModeRedraw;//如果bounds变化了，就要重新绘制它
} //通常是里面放的是当前UIView是否要透明，透明度多少等等的optimize选项
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
    // 启动页面的时候去更新一次站点信息数据
//    [[StationInfo shareInstance]updateAllStationsInfoWithSuccessBlk:^{
//        
//    } FailBlk:^(NSError *err) {
//        NSLog(@"错误信息 = %@",err.description);
//        [SVProgressHUD showErrorWithStatus:@"数据请求失败，请检查网络，并在设置中重试'更新数据'"];
//    }];
}

- (IBAction)selectRelatedDistrict:(DistrictButton *)sender {
    if (sender.isSelected == NO) {
        [sender switchToSelectedState];
        sender.isSelected = YES;
        NSString *districtName = [sender restorationIdentifier];
        
        self.stationInfoArray    = [[StationInfo shareInstance] fetchDistrictStationsInfoWithName:districtName];
        NSLog(@"%@ 的数组 %@",districtName,self.stationInfoArray);
        NSArray *annotationArray = [[StationInfo shareInstance] fetchDistrictStationAnnotationWithArray:self.stationInfoArray];
        self.previousSelIndex    = UNREACHABLE_INDEX;
        [self.stationList reloadData];

        [[NSNotificationCenter defaultCenter] postNotificationName:DISTRICT_BTN_SEL_RADIO
                                                            object:districtName];
        [self.delegate addOverlaysToDistrictWithName:districtName];
        [self.delegate addAnnotationPointInDistrict:annotationArray];
    }
    // 不论按键是否被选中，都去调用弹框的代理，由代理自行判断状态来决定是否弹出
    [self.delegate startMapviewTransform];
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
    self.previousSelIndex         = listIndex;
    NSLog(@"test 1.图标选中对应的cell索引 = %lu",(long)listIndex);
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

-(void)deselectCorrespondingCellInStationList:(NSInteger)listIndex {
    NSIndexPath *indexpath = [NSIndexPath indexPathForRow:listIndex
                                                inSection:0];
    [self tableView:self.stationList didDeselectRowAtIndexPath:indexpath];
}

-(void)switchToStationToStationGuideMode {
    [self selectRelatedDistrict:self.allcityBtn];
}

#pragma mark tableview delegate
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.stationInfoArray.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return CELL_HEIGHT;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"创建cell,索引值 = %lu,上一个索引值 = %lu",(long)indexPath.row,self.previousSelIndex);
    static  NSString *const OptionTableReuseID = @"reuseID";        //设立reuse池的标签名（或者说池子的名称）
    //表示从现有的池子（标签已指定）取出排在队列最前面的那个 cell
    StattionsTableViewCell* cell = (StattionsTableViewCell*)[tableView dequeueReusableCellWithIdentifier:OptionTableReuseID];
    if (cell == nil) {
        cell = [StattionsTableViewCell initMyCell];
    }
    
    /* 如果先选中annotation，跳转到对应的索引，此时cell是第一次创建，他的背景图也要变成选中状态
     blk表示GoToView的选中按钮 */
    if (indexPath.row == self.previousSelIndex) {
        [cell makeCellUnderSelectionModeWithBlk:^{
            [self.delegate selectCurrentStationAsTerminalStation:indexPath.row];
        }];
    } else
        [cell makeCellUnderDeselectionMode];
    
    cell.stationAddress.text = [self.stationInfoArray[indexPath.row] stationAddress];
    cell.stationName.text    = [self.stationInfoArray[indexPath.row] stationName];
    cell.districtName.text   = [self.stationInfoArray[indexPath.row] district];
    NSString *imgName = [NSString stringWithFormat:@"%@logo",cell.districtName.text];
    cell.districtImage.image       = [UIImage imageNamed:imgName];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    self.previousSelIndex = indexPath.row;
    StattionsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    if (self.noNeedToSelectAnnotation == YES) {
        self.noNeedToSelectAnnotation = NO;
    } else {
        [self.delegate selectCorrespondingAnnotation:indexPath.row];
    }

    [cell makeCellUnderSelectionModeWithBlk:^{
        [self.delegate selectCurrentStationAsTerminalStation:indexPath.row];
    }];
}

-(void)tableView:(UITableView *)tableView didDeselectRowAtIndexPath:(NSIndexPath *)indexPath {
    StattionsTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    [cell makeCellUnderDeselectionMode];
}

@end
