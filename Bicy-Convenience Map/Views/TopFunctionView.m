//
//  TopFunctionView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/17.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "TopFunctionView.h"
#define START_HOLD_TEXT @"选中标注为起点"
#define END_HOLD_TEXT @"选中标注为终点"
@interface TopFunctionView()
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *resetStartStationBtn;
@property (weak, nonatomic) IBOutlet UIImageView *initialMaskTipImg;//初始启动时的遮挡图片，在选中搜索模式后移除

@end

@implementation TopFunctionView
- (void)drawRect:(CGRect)rect {
    // Drawing code
}

+(instancetype)initMyView {
    TopFunctionView *view = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                          owner:self
                                                        options:nil].lastObject;
    view.buttonState = bothBtnDeselected;
    [[NSNotificationCenter defaultCenter] addObserver:view
                                             selector:@selector(heardFromGuideMode:)
                                                 name:GUIDE_MODE_RADIO
                                               object:nil];
    return view;
}

-(void)setFunctionBtnDeselectedState {
    [self.searchButton setImage:[UIImage imageNamed:@"搜索模式"]
                                 forState:UIControlStateNormal];
    [self.settingButton setImage:[UIImage imageNamed:@"设置"]
                        forState:UIControlStateNormal];
    self.buttonState = bothBtnDeselected;
}

#pragma mark Interaction
- (IBAction)SelectSearchMode:(UIButton *)sender {
    if (self.buttonState == bothBtnDeselected) {
        [sender setImage:[UIImage imageNamed:@"左取消按键"]
                forState:UIControlStateNormal];
        self.buttonState = searchModeBtnSelected;
        [self.delegate addLeftMenuView];
    } else if (self.buttonState == searchModeBtnSelected) {
        [sender setImage:[UIImage imageNamed:@"搜索模式"]
                forState:UIControlStateNormal];
        self.buttonState = bothBtnDeselected;
        [self.delegate removeLeftMenuView];
    }
}

- (IBAction)MySettings:(UIButton *)sender {
    if (self.buttonState == bothBtnDeselected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"右取消按键"]
                          forState:UIControlStateNormal];
        self.buttonState = searchModeBtnSelected;
        [self.delegate addRightSettingView];
    } else if (self.buttonState == settingBtnSelected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"设置"]
                          forState:UIControlStateNormal];
        self.buttonState = bothBtnDeselected;
        [self.delegate removeRightSettingView];
    }
}


/**
 清空起始站点信息
 */
- (IBAction)resetStartStation:(id)sender {
    if (self.buttonState == bothBtnDeselected && ![self.startStation.text isEqualToString:START_HOLD_TEXT]) {
        self.startStation.text = START_HOLD_TEXT;
        [self.delegate resetStartStationInfo];
    }
}

/**
 清空终点站点信息
 */
- (IBAction)resetEndStation:(UIButton *)sender {
    if (self.buttonState == bothBtnDeselected && ![self.endStation.text isEqualToString:END_HOLD_TEXT]) {
        self.endStation.text = END_HOLD_TEXT;
        [self.delegate resetEndStationInfo];
    }
}

#pragma mark 收听到导航模式变更
-(void)heardFromGuideMode:(NSNotification*)info {
    NSNumber* modeObject = (NSNumber*)info.object;
    NSInteger mode = [modeObject integerValue];
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        [self.initialMaskTipImg removeFromSuperview];
    });
    switch (mode) {
        case STATION_TO_STATION_MODE: {
            self.startStation.text = START_HOLD_TEXT;
            self.endStation.text   = END_HOLD_TEXT;
            [self.resetStartStationBtn setHidden:NO];
        }
            break;
        case NEARBY_GUIDE_MODE: {
            self.startStation.text = @"我的位置";
            self.endStation.text   = END_HOLD_TEXT;
            [self.resetStartStationBtn setHidden:YES];
        }
            break;
        default:
            break;
    }
}
@end
