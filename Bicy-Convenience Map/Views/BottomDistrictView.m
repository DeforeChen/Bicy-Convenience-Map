//
//  BottomDistrictView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/20.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "BottomDistrictView.h"
#import "StattionsTableViewCell.h"

@interface BottomDistrictView()
@property(nonatomic) BOOL isSelected;
@property (nonatomic,strong) NSArray<StationInfo*>* stationInfoArray;
@end

@implementation BottomDistrictView
- (IBAction)showDistrictTableview:(UIButton *)sender {
    if (_isSelected != YES) {
        sender.frame = CGRectMake(0, -4, sender.bounds.size.width, sender.bounds.size.height+4);
        [sender setImage:[UIImage imageNamed:@"鼓楼_select"]
                forState:UIControlStateNormal];
        _isSelected = YES;
        
        //填一段假数据用来调试
        StationInfo *infoA = [[StationInfo alloc] init];
        infoA.stationName = @"象峰一路站";
        infoA.stationAddress = @"秀峰支路XX号";
        
        StationInfo *infoB = [[StationInfo alloc] init];
        infoB.stationName = @"信和广场站";
        infoB.stationAddress = @"五四路xx前xx号";
        
        self.stationInfoArray = [NSArray arrayWithObjects:infoA,infoB, nil];
        [self.stationList reloadData];
    }
}

- (void)setup {
    self.opaque      = NO;//不透明
    self.contentMode = UIViewContentModeRedraw;//如果bounds变化了，就要重新绘制它
} //通常是里面放的是当前UIView是否要透明，透明度多少等等的optimize选项
- (void)awakeFromNib {
    [super awakeFromNib];
    [self setup];
}

+ (instancetype) initMyViewWithOwner:(UIViewController*)viewCtrl {
    BottomDistrictView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                             owner:viewCtrl
                                                           options:nil].lastObject;

    return view;
}

//#pragma mark tableview delegate
//-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
//    return 2;//self.stationInfoArray.count;
//}
//
//-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
//    return 60.0;
//}
//
//-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
//    static  NSString *const OptionTableReuseID = @"reuseID";        //设立reuse池的标签名（或者说池子的名称）
//    //表示从现有的池子（标签已指定）取出排在队列最前面的那个 cell
//    UITableViewCell* cell = [tableView dequeueReusableCellWithIdentifier:OptionTableReuseID];
//    NSLog(@"reuseid = %@,RestorationIdentifier = %@",cell.reuseIdentifier,cell.restorationIdentifier);
//    
//    
//    if (cell == nil) {
//        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault
//                                      reuseIdentifier:OptionTableReuseID];
//        cell.textLabel.text = @"new";
////        cell = [StattionsTableViewCell initMyCellWithStationName:self.stationInfoArray[indexPath.row].stationName
////                                                  StationAddress:self.stationInfoArray[indexPath.row].stationAddress];
//        
//    } else{
//        NSLog(@"Reused cell = %@",cell.textLabel.text);//为了调试好看，正常并不需要else
//    }
//    
//    //从数组中取出对应的文本，贴给当前的这个cell，index是随着回滚事件代理调用的对应路径
//    return cell;
//}
@end
