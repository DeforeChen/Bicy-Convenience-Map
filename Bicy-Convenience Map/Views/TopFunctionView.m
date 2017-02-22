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
#define START_IMG_SELECT   [UIImage imageNamed:@"起点地址选中"]
#define START_IMG_DESELECT [UIImage imageNamed:@"起点地址未选"]
#define END_IMG_SELECT     [UIImage imageNamed:@"终点地址选中"]
#define END_IMG_DESELECT   [UIImage imageNamed:@"终点地址未选"]

@interface TopFunctionView()
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
@property (weak, nonatomic) IBOutlet UIButton *resetStartStationBtn;


@property (weak, nonatomic) IBOutlet UIButton *startLocBtn;
@property (weak, nonatomic) IBOutlet UIImageView *startBG_ImgView;
@property (weak, nonatomic) IBOutlet UIButton *endLocBtn;
@property (weak, nonatomic) IBOutlet UIImageView *endBG_ImgView;

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
        [sender setImage:[UIImage imageNamed:@"右取消按键"]
                forState:UIControlStateNormal];
        self.buttonState = settingBtnSelected;
        [self.delegate addRightSettingView];
    } else if (self.buttonState == settingBtnSelected) {
        [sender setImage:[UIImage imageNamed:@"设置"]
                forState:UIControlStateNormal];
        self.buttonState = bothBtnDeselected;
        [self.delegate removeRightSettingView];
    }
}

- (IBAction)locateStation:(UIButton *)sender {
    [self.delegate locateWithStationID:[sender restorationIdentifier]];
}

/**
 清空起始站点信息
 */
- (IBAction)resetStartStation:(id)sender {
    if (self.buttonState == bothBtnDeselected && ![self.startLocBtn.currentTitle isEqualToString:START_HOLD_TEXT]) {
        [self.startLocBtn setTitle:START_HOLD_TEXT forState:UIControlStateNormal];
        self.startBG_ImgView.image = START_IMG_DESELECT;
        [self.delegate resetStartStationInfo];
    }
}

/**
 清空终点站点信息
 */
- (IBAction)resetEndStation:(UIButton *)sender {
    if (self.buttonState == bothBtnDeselected && ![self.endLocBtn.currentTitle isEqualToString:END_HOLD_TEXT]) {
        [self.endLocBtn setTitle:END_HOLD_TEXT forState:UIControlStateNormal];
        self.endBG_ImgView.image = END_IMG_DESELECT;
        [self.delegate resetEndStationInfo];
    }
}

#pragma mark 收听到导航模式变更
-(void)heardFromGuideMode:(NSNotification*)info {
    NSNumber* modeObject = (NSNumber*)info.object;
    NSInteger mode = [modeObject integerValue];
    self.startBG_ImgView.image       = START_IMG_DESELECT;
    self.endBG_ImgView.image         = END_IMG_DESELECT;
    [self.endLocBtn setTitle:END_HOLD_TEXT forState:UIControlStateNormal];
    switch (mode) {
        case STATION_TO_STATION_MODE: {
            [self.startLocBtn setTitle:START_HOLD_TEXT forState:UIControlStateNormal];
            [self.resetStartStationBtn setHidden:NO];
        }
            break;
        case NEARBY_GUIDE_MODE: {
            [self.startLocBtn setTitle:@"我的位置" forState:UIControlStateNormal];
            [self.resetStartStationBtn setHidden:YES];
        }
            break;
        default:
            break;
    }
}

#pragma 接口函数
-(void)setStartLocText:(NSString *)startName {
    [self.startLocBtn setTitle:startName forState:UIControlStateNormal];
    self.startBG_ImgView.image = START_IMG_SELECT;
}

-(void)setEndLocText:(NSString *)endName {
    [self.endLocBtn setTitle:endName forState:UIControlStateNormal];
    self.endBG_ImgView.image = END_IMG_SELECT;
}

@end
