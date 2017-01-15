//
//  GotoView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/12.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "GotoView.h"
@interface GotoView()
@property (weak, nonatomic) IBOutlet UIButton *setPoint;
@end


@implementation GotoView
-(void)awakeFromNib {
    [super awakeFromNib];
}

+(instancetype)initMyView {
    GotoView *view = [[NSBundle mainBundle] loadNibNamed:@"GotoView"
                                                   owner:self
                                                 options:nil].lastObject;
    return view;
}

- (void)rotate360DegreeWithImageView{
    CABasicAnimation *animation = [ CABasicAnimation
                                   animationWithKeyPath: @"transform" ];
    animation.fromValue = [NSValue valueWithCATransform3D:CATransform3DIdentity];
    
    //围绕Z轴旋转，垂直与屏幕
    animation.toValue = [ NSValue valueWithCATransform3D:
                         
                         CATransform3DMakeRotation(M_PI, 0.0, 0.0, 1.0) ];
    animation.duration = 2;
    //旋转效果累计，先转180度，接着再旋转180度，从而实现360旋转
    animation.cumulative = YES;
    animation.repeatCount = 1000;
    
    
    //在图片边缘添加一个像素的透明区域，去图片锯齿
    CGRect imageRrect = CGRectMake(0, 0,self.wheel.frame.size.width, self.wheel.frame.size.height);
    UIGraphicsBeginImageContext(imageRrect.size);
    [self.wheel.image drawInRect:CGRectMake(1,1,self.wheel.frame.size.width-2,self.wheel.frame.size.height-2)];
    self.wheel.image = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    [self.wheel.layer addAnimation:animation forKey:nil];

}
@end
