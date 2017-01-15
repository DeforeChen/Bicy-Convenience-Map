//
//  GotoView.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/12.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface GotoView : UIView
@property (weak, nonatomic) IBOutlet UIImageView *wheel;
+(instancetype)initMyView;
-(void)rotate360DegreeWithImageView;
@end
