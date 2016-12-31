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
@end

@implementation BottomDistrictView
- (void)setup {
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

        self.stationInfoArray = [[StationInfo shareInstance] fetchDistrictStationsInfoWithName:[sender restorationIdentifier]];
        [self.stationList reloadData];
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISTRICT_BTN_SEL_RADIO
                                                            object:[sender restorationIdentifier]];
        [self.delegate startMapviewTransform];
        [self.delegate selDistrictWithName:[sender restorationIdentifier]];
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
    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:OptionTableReuseID];
    
    if (cell == nil) {
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
                                      reuseIdentifier:OptionTableReuseID];
        cell.textLabel.text = @"new";
        cell = [StattionsTableViewCell initMyCellWithStationName:[self.stationInfoArray[indexPath.row] stationName]
                                                  StationAddress:[self.stationInfoArray[indexPath.row] stationAddress]];
        
    } else{
        NSLog(@"Reused cell = %@",cell.textLabel.text);//为了调试好看，正常并不需要else
    }
    
    //从数组中取出对应的文本，贴给当前的这个cell，index是随着回滚事件代理调用的对应路径
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    StattionsTableViewCell *cell = (StattionsTableViewCell*)[tableView cellForRowAtIndexPath:indexPath];
    cell.stationBgImage.image = [UIImage imageNamed:@"站点单元栏_selected"];
    [cell.gotoBtn setHidden:NO];
//    [self.delegate selStationWithListIndex:indexPath.row
//                              selMyCellBlk:^(NSUInteger imgIndex) {
//                                  NSIndexPath *indexpath = [NSIndexPath indexPathForRow:imgIndex
//                                                                              inSection:0];
//                                  
//                                  [self.stationList scrollToRowAtIndexPath:indexpath
//                                                        atScrollPosition:UITableViewScrollPositionMiddle
//                                                                animated:YES];  //滚动到第5行
//                                  
//                                  [self.stationList selectRowAtIndexPath:indexpath
//                                                              animated:YES
//                                                        scrollPosition:UITableViewScrollPositionMiddle];  //选中第5行
//                              }];
}
@end
