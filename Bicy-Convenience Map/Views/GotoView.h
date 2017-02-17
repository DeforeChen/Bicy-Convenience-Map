//
//  GotoView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/12.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^selectStationBlk)();

@interface GotoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *wheel;
@property (nonatomic,copy) selectStationBlk blk;

/**
 初始化View，Blk用于通知按键消息

 @param blk 通知“选中”站点消息
 */
-(instancetype)initMyViewWithBlk:(selectStationBlk)blk;
-(void)rotate360DegreeWithImageView;
@end
