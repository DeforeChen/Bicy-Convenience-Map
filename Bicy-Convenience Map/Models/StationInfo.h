//
//  StationInfo.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/22.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface StationInfo : NSObject
@property (nonatomic,copy) NSString *stationName;
@property (nonatomic,copy) NSString *stationAddress;
@property (nonatomic,copy) NSString *district;
@property (nonatomic,copy) NSString *latitude;
@property (nonatomic,copy) NSString *longitude;
@end
