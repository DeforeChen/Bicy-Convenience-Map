//
//  plistManager.m
//  Bicy-Convenience Map
//
//  Created by Chen Defore on 2016/12/30.
//  Copyright © 2016年 Chen Defore. All rights reserved.
//

#import "plistManager.h"
@interface plistManager()
@property (nonatomic,strong) NSString* filePath;
@property (nonatomic,strong) NSFileManager *fileManager;
@end

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
