//
//  TopFunctionView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/17.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "config.h"
@protocol TopViewInteractionDelegate <NSObject>

-(void)addLeftMenuView;         //添加左侧菜单栏
-(void)removeLeftMenuView;      //移除左侧菜单栏
-(void)addRightSettingView;     //添加右侧设置栏
-(void)removeRightSettingView;  //移除右侧设置栏


/**
 下面两个函数，用于通知主页清空所持有的起止站点信息
 */
-(void)resetStartStationInfo;
-(void)resetEndStationInfo;
@end

typedef enum : NSUInteger {
    bothBtnDeselected  = 0, //全不选中
    searchModeBtnSelected,// 搜索按键选中
    settingBtnSelected,   // 设置按键选中
} topButtonState;

@interface TopFunctionView : UIView
@property(nonatomic,weak) id<TopViewInteractionDelegate>delegate;
@property(nonatomic) topButtonState buttonState;
@property (weak, nonatomic) IBOutlet UILabel *startStation;
@property (weak, nonatomic) IBOutlet UILabel *endStation;

+(instancetype)initMyView;

/**
 让顶栏的功能键全部处于未选中状态
 */
-(void)setFunctionBtnDeselectedState;
@end
