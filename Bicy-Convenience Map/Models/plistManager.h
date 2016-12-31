//
//  plistManager.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/30.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface plistManager : NSObject
-(instancetype)initWithPlistName:(NSString*)plistName;
/**
 判断文件是否存在
 */
-(BOOL)ifPlistExist;

/**
 创建plist文件
 */
-(BOOL)createPlist;

/**
 读取plist文件
 */
-(id)readPlist;
@end
