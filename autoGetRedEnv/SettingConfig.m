//
//  SettingConfig.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/7.
//
//

#import "SettingConfig.h"

@implementation SettingConfig

+ (instancetype)defaults{
    static SettingConfig * _config = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        _config = [[SettingConfig alloc] init];
    });
    return _config;
}

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.backgroundType = 1;
    }
    return self;
}

@end
