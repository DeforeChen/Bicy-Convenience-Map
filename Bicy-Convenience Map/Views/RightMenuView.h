//
//  RightMenuView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/18.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "AboutView.h"

@protocol RightViewInteractionDelegate <NSObject>
/**
 当移除当前菜单栏时的回调，通知主页的controller将TopView的按钮恢复原状
 */
-(void)finishedRemoveRightView;
// 插入关于
-(void)insertAboutView;
@end

@interface RightMenuView : UIView
@property (nonatomic,weak) id<RightViewInteractionDelegate> delegate;

-(instancetype)initMyView;
@end
