//
//  RunInBackground.m
//  audioBg
//
//  Created by coohua on 15/7/2.
//  Copyright (c) 2015年 cn.coohua. All rights reserved.
//

#import "RunInBackground.h"
#import <AVFoundation/AVFoundation.h>
#import <UIKit/UIKit.h>

@interface RunInBackground ()


@property (nonatomic, strong) AVAudioPlayer *audioPlayer;
@property (nonatomic, strong) NSTimer *audioTimer;
@property (nonatomic, strong) NSTimer *logTimer;
@end

@implementation RunInBackground{
    CFRunLoopRef _runloopRef;
    UIBackgroundTaskIdentifier _task;
    dispatch_queue_t _queue;
}

/// 提供一个单例
+ (instancetype)sharedBg {
    static dispatch_once_t onceToken;
    static id instance;
    dispatch_once(&onceToken, ^{
        instance = [[self alloc] init];
    });
    return instance;
}

/// 重写init方法，初始化音乐文件
- (instancetype)init {
    if (self = [super init]) {
        [self setUpAudioSession];
        
        _queue = dispatch_queue_create("com.audio.background", NULL);
        
        // 播放文件
        NSString *filePath = [[NSBundle mainBundle] pathForResource:@"mysong" ofType:@"mp3"];
        NSURL *fileURL = [[NSURL alloc] initFileURLWithPath:filePath];
        self.audioPlayer = [[AVAudioPlayer alloc] initWithContentsOfURL:fileURL error:nil];
        [self.audioPlayer prepareToPlay];
        // 0.0~1.0,默认为1.0
        self.audioPlayer.volume = 0.01;
        // 循环播放
        self.audioPlayer.numberOfLoops = -1;
    }
    return self;
}

- (void)startRunInbackGround {
    
    _task =[[UIApplication sharedApplication] beginBackgroundTaskWithExpirationHandler:^{
        dispatch_async(dispatch_get_main_queue(), ^{
            [[UIApplication sharedApplication] endBackgroundTask:_task];
            _task = UIBackgroundTaskInvalid;
        });
        
    }];
    
    dispatch_async(_queue, ^{
        self.audioTimer = [[NSTimer alloc] initWithFireDate:[NSDate date] interval:120.0 target:self selector:@selector(startAudioPlay) userInfo:nil repeats:YES];
        self.logTimer = [NSTimer scheduledTimerWithTimeInterval:5.f target:self selector:@selector(log) userInfo:nil repeats:YES];
        _runloopRef = CFRunLoopGetCurrent();
        [[NSRunLoop currentRunLoop] addTimer:self.audioTimer forMode:NSRunLoopCommonModes];
        CFRunLoopRun();
    });
    
    
    
}

- (void)log{
    NSLog(@"~~~~~~~~~~~~~~~~~~%.2f~~~~~~~~~~~~~~", [UIApplication sharedApplication].backgroundTimeRemaining);
}

- (void)startAudioPlay {
    // 异步执行
    [self.audioPlayer play];
    
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10.f * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [self.audioPlayer stop];
    });
    
}
- (void)stopAudioPlay {
    
    CFRunLoopStop(_runloopRef);
    
    // 关闭定时器即可
    [self.audioTimer invalidate];
    self.audioTimer = nil;
    
    [self.logTimer invalidate];
    self.logTimer = nil;
    
    //[self.audioPlayer stop];
    [[UIApplication sharedApplication] endBackgroundTask:_task];
    _task = UIBackgroundTaskInvalid;
    
//    if ([AVAudioSession sharedInstance].otherAudioPlaying){
//        [self setUpAudioSession];
//    }
    
}
- (void)setUpAudioSession {
    // 新建AudioSession会话
    AVAudioSession *audioSession = [AVAudioSession sharedInstance];
    
    // 设置后台播放
    NSError *error = nil;
    [audioSession setCategory:AVAudioSessionCategoryPlayback withOptions:AVAudioSessionCategoryOptionMixWithOthers error:&error];
    
    if (error) {
        NSLog(@"Error setCategory AVAudioSession: %@", error);
    }
    
    NSError *activeSetError = nil;
    // 启动AudioSession，如果一个前台app正在播放音频则可能启动失败
    if ([AVAudioSession sharedInstance].otherAudioPlaying == NO){
        [audioSession setActive:YES error:&activeSetError];
    }
    if (activeSetError) {
        NSLog(@"Error activating AVAudioSession: %@", activeSetError);
    }
}

@end


