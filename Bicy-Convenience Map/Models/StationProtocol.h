//
//  StationProtocol.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/1/10.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

@protocol stationProtocol<NSObject>
@required
@property (nonatomic , copy)   NSString *district;
@property (nonatomic , strong) NSNumber *latitude;
@property (nonatomic , strong) NSNumber *longtitude;
@property (nonatomic , copy)  NSString  *stationAddress;
@property (nonatomic , copy)  NSString  *stationName;
@end
