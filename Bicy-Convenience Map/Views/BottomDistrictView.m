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

@interface BottomDistrictView()<UITableViewDelegate,UITableViewDataSource>
@property(nonatomic) BOOL isSelected;
@property (nonatomic,strong) NSArray<StationInfo*>* stationInfoArray;
@end

@implementation BottomDistrictView
- (void)setup {
    self.opaque      = NO;//不透明
    self.contentMode = UIViewContentModeRedraw;//如果bounds变化了，就要重新绘制它
} //通常是里面放的是当前UIView是否要透明，透明度多少等等的optimize选项
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

- (IBAction)selectRelatedDistrict:(DistrictButton *)sender {
    if (sender.isSelected == NO) {
        [sender switchToSelectedState];
        sender.isSelected = YES;
        
        
        [[NSNotificationCenter defaultCenter] postNotificationName:DISTRICT_BTN_SEL_RADIO
                                                            object:[sender restorationIdentifier]];
        [self.delegate startMapviewTransform];
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
        infoB.stationName = @"东街口站";
        infoB.stationAddress = @"八一七北路78号闽辉大厦东门";
        
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
