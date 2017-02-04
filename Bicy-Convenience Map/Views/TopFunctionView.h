//
//  TopFunctionView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/17.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>
@protocol TopViewInteractionDelegate <NSObject>

-(void)addLeftMenuView;         //添加左侧菜单栏
-(void)removeLeftMenuView;      //移除左侧菜单栏
-(void)addRightSettingView;     //添加右侧设置栏
-(void)removeRightSettingView;  //移除右侧设置栏
@end

typedef enum : NSUInteger {
    bothBtnDeselected  = 0, //全不选中
    searchModeBtnSelected,// 搜索按键选中
    settingBtnSelected,   // 设置按键选中
} topButtonState;

@interface TopFunctionView : UIView
@property(nonatomic,weak) id<TopViewInteractionDelegate>delegate;
@property(nonatomic) topButtonState buttonState;

+(instancetype)initMyView;
-(void)setFunctionBtnDeselectedState;
@end
