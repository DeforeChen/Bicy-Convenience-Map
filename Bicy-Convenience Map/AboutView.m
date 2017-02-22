//
//  AboutView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/22.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "AboutView.h"
#import "config.h"

@implementation AboutView
-(instancetype)initMyView {
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil].lastObject;
    }
    return self;
}

- (IBAction)removeCurrentView:(UIButton *)sender {
    CGRect rect = CGRectMake(-WIDTH, 0, WIDTH, HEIGHT);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = rect;
                     }
                     completion:^(BOOL finished) {
                         [self removeFromSuperview];
                     }];
}



@end
