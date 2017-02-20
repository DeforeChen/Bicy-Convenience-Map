//
//  LeftMenuView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/1.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "BaiduLocationTool.h"

@protocol LeftViewInteractionDelegate <NSObject>
/**
 当移除当前左侧菜单栏时的回调，通知主页的controller将TopView的按钮恢复原状
 */
-(void)finishedRemoveLeftView;
@end

//==========================================================================================
@interface LeftMenuView : UIView
@property (nonatomic,weak) id<LeftViewInteractionDelegate>delegate;

-(instancetype)initMyView;
@end
