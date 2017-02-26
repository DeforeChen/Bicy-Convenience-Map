//
//  RightMenuView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/18.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "RightMenuView.h"
#import "config.h"
#import "DataUtil.h"
#import <SVProgressHUD/SVProgressHUD.h>

@interface RightMenuView()
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@end


@implementation RightMenuView
#pragma mark Interaction
- (IBAction)aboutMyApp:(UIButton *)sender {
    [self removeCurrentRightMenu];
    [self.delegate insertAboutView];
}


/**
 升级站点信息
 @param sender 按键
 */
- (IBAction)updateData:(UIButton *)sender {
    [SVProgressHUD showWithStatus:@"数据更新中"];
    [[DataUtil managerCenter] updateAllInfoWithSucBlk:^{
        [SVProgressHUD dismiss];
        [SVProgressHUD showSuccessWithStatus:@"数据更新成功"];
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            [SVProgressHUD dismiss];
        });
    }
                                              failBlk:^(NSError *err) {
                                                  [SVProgressHUD dismiss];
                                                  [SVProgressHUD showErrorWithStatus:@"数据更新失败，请检查网络后充实"];
                                              }];
}

#pragma mark instance
-(instancetype)initMyView {
    self = [super init];
    if (self) {
            self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                                 owner:self
                                               options:nil].lastObject;
            UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                                      action:@selector(removeCurrentRightMenu)];
            [self.bgImgView addGestureRecognizer:gesture];
    }
    return self;
}

-(void)removeCurrentRightMenu {
    CGRect rect = CGRectMake(WIDTH, TOP_OFFSET+TOP_HEIGHT, WIDTH, HEIGHT);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = rect;
                         [self.delegate finishedRemoveRightView];
                     }
                     completion:^(BOOL finished) {
                         self.delegate = nil;//其实delegat的属性是weak可以不用写了
                         [self removeFromSuperview];
                     }];
}

@end
