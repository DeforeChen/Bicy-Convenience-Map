//
//  TopFunctionView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/17.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "TopFunctionView.h"
@interface TopFunctionView()
@property (weak, nonatomic) IBOutlet UIButton *searchButton;
@property (weak, nonatomic) IBOutlet UIButton *settingButton;
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
    } else if (self.buttonState == searchModeBtnSelected) {
        [sender setBackgroundImage:[UIImage imageNamed:@"设置"]
                          forState:UIControlStateNormal];
        self.buttonState = bothBtnDeselected;
        [self.delegate removeRightSettingView];
    }
}


@end
