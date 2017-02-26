//
//  LeftMenuView.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/1.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "LeftMenuView.h"
#import "StationInfo.h"
#import "config.h"
@interface LeftMenuView()
@property (weak, nonatomic) IBOutlet UIImageView *bgImgView;

@end

@implementation LeftMenuView
#pragma mark interaction
- (IBAction)stationToStationSearchMode:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:GUIDE_MODE_RADIO
                                                        object:[NSNumber numberWithInt:STATION_TO_STATION_MODE]];
    [self removeCurrentLeftMenu];
}


- (IBAction)nearbySearchMode:(UIButton *)sender {
    [[NSNotificationCenter defaultCenter] postNotificationName:GUIDE_MODE_RADIO
                                                        object:[NSNumber numberWithInt:NEARBY_GUIDE_MODE]];
    [self removeCurrentLeftMenu];
}



#pragma mark instance
-(instancetype)initMyView {
    self = [super init];
    if (self) {
        self = [[NSBundle mainBundle] loadNibNamed:NSStringFromClass([self class])
                                             owner:self
                                           options:nil].lastObject;
        UITapGestureRecognizer *gesture = [[UITapGestureRecognizer alloc] initWithTarget:self
                                                                            action:@selector(removeCurrentLeftMenu)];
        [self.bgImgView addGestureRecognizer:gesture];
    }
    return self;
}

-(void)removeCurrentLeftMenu {
    CGRect rect = CGRectMake(-WIDTH, TOP_OFFSET+TOP_HEIGHT, WIDTH, HEIGHT);
    [UIView animateWithDuration:0.5
                          delay:0
         usingSpringWithDamping:1
          initialSpringVelocity:0.3
                        options:UIViewAnimationOptionBeginFromCurrentState
                     animations:^{
                         self.frame = rect;
                         [self.delegate finishedRemoveLeftView];
                     }
                     completion:^(BOOL finished) {
                         self.delegate = nil;//其实delegat的属性是weak可以不用写了
                         [self removeFromSuperview];
                     }];
}

@end
