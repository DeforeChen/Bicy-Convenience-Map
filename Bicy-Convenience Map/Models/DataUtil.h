//
//  DataUtil.h
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/23.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "config.h"
@class plistManager;
@interface DataUtil : NSObject
+(instancetype)managerCenter;



/**
 升级站点信息
 @param sucBlk 成功的回调
 @param failBlk 失败的回调
 */
-(void)updateAllInfoWithSucBlk:(SucBlk)sucBlk
                       failBlk:(FailBlk)failBlk;
@end




@interface plistManager : NSObject
@property (nonatomic,strong) NSString* filePath;
@property (nonatomic,strong) NSFileManager *fileManager;

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
