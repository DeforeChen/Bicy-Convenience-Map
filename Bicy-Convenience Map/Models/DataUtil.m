//
//  DataUtil.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2017/2/23.
//  Copyright © 2017年 Chen Defore. All rights reserved.
//

#import "DataUtil.h"
#import "BaiduDistrictTool.h"
#import "StationInfo.h"
#import <SVProgressHUD/SVProgressHUD.h>
#define SELFCLASS_NAME DataUtil
#define SELFCLASS_NAME_STR @"DataUtil"

@implementation DataUtil
static DataUtil *center = nil;//定义一个全局的静态变量，满足静态分析器的要求
+ (instancetype)managerCenter {
    static dispatch_once_t predicate;
    //线程安全
    dispatch_once(&predicate, ^{
        center = (SELFCLASS_NAME *)SELFCLASS_NAME_STR;
        center = [[SELFCLASS_NAME alloc] init];
    });
    
    // 防止子类使用
    NSString *classString = NSStringFromClass([self class]);
    if ([classString isEqualToString: SELFCLASS_NAME_STR] == NO)
        NSParameterAssert(nil);
    return center;
}

- (instancetype)init {
    NSString *string = (NSString *)center;
    if ([string isKindOfClass:[NSString class]] == YES && [string isEqualToString:SELFCLASS_NAME_STR]) {
        self = [super init];
        if (self) {
            // 防止子类使用
            NSString *classString = NSStringFromClass([self class]);
            if ([classString isEqualToString:SELFCLASS_NAME_STR] == NO)
                NSParameterAssert(nil);
        }
        return self;
        
    } else
        return nil;
}

#pragma mark
-(void)updateAllInfoWithSucBlk:(SucBlk)sucBlk
                       failBlk:(FailBlk)failBlk {
    plistManager *manager = [[plistManager alloc] initWithPlistName:PLIST_NAME];
    //1.1.从沙盒中取出行政区域边界信息plist用于绘制。如果plist不存在，就创建一个
    if ([manager ifPlistExist] == NO)
        [manager createPlist];
    //1.2读取这个plist文件
    NSDictionary *dict = [manager readPlist];
    if (dict.count == 0) {
        [[BaiduDistrictTool shareInstance] updateDistrictPlistWithSuccessBlk:^{
            //调试用,读plist
            NSDictionary *dict = [manager readPlist];
            NSLog(@"空的plist重新获取数据后，读到的plist = %@",dict);

            // 2.1 到这一步，说明已读到正确的信息，继续请求站点信息
            [[StationInfo shareInstance] updateAllStationsInfoWithSuccessBlk:sucBlk
                                                                     FailBlk:failBlk];
        } FailBlk:failBlk];
    } else {// 3.2 已经读到正确的信息，继续获取站点信息
        [[StationInfo shareInstance] updateAllStationsInfoWithSuccessBlk:sucBlk
                                                                 FailBlk:failBlk];
    }

}


@end


#pragma mark plist
@implementation plistManager
-(BOOL)ifPlistExist {
    return [self.fileManager fileExistsAtPath:self.filePath];
}

-(BOOL)createPlist {
    return [self.fileManager createFileAtPath:self.filePath contents:nil attributes:nil];
}

-(id)readPlist {
    if ([self ifPlistExist]) {
        NSDictionary *dict = [NSDictionary dictionaryWithContentsOfFile:self.filePath];
        return dict;
    } else {
        NSLog(@"file not exist");
        return nil;
    }
}

-(instancetype)initWithPlistName:(NSString*)plistName {
    self = [super init];
    if (self) {
        self = [[plistManager alloc] init];
        NSString *path = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES).firstObject;
        self.filePath    = [path stringByAppendingPathComponent:plistName];
        self.fileManager = [NSFileManager defaultManager];
    }
    return self;
}
@end
