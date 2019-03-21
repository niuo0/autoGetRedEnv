//
//  SettingConfig.h
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/7.
//
//

#import "RuntimeArchiver+AutoWrite.h"

@interface SettingConfig : RuntimeArchiver

@property (nonatomic, assign) BOOL noWriteHook;
@property (nonatomic, strong) id noWriteContact;
@property (nonatomic, assign) BOOL noWriteIsSelf;
@property (nonatomic, assign) BOOL noWrite_Hook_MMMassSendContactSelectorViewController;

@property (nonatomic, assign) NSInteger redPliginType;
@property (nonatomic, assign) NSInteger backgroundType;
@property (nonatomic, assign) int stepCount;

+ (instancetype)defaults;

@end
