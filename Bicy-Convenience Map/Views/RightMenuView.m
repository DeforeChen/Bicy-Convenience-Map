//
//  RightMenuView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/18.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "RightMenuView.h"
#import "config.h"
@interface RightMenuView()
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;
@end


@implementation RightMenuView
#pragma mark Interaction
- (IBAction)aboutMyApp:(UIButton *)sender {
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
    CGRect rect = CGRectMake(WIDTH, 60, WIDTH, HEIGHT);
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
