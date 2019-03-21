//
//  MyViewController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/8.
//
//

#import "MyViewController.h"

@implementation MyViewController

- (BOOL)shouldAutorotate{
    return YES;
}

- (UIInterfaceOrientationMask)supportedInterfaceOrientations{
    return UIInterfaceOrientationMaskPortrait;
}

- (void)dealloc{
    
    NSLog(@"~~~~~~~~~~~~~~~~%@~~~~~~~~~~~~~~%s", self, __FUNCTION__);
}

@end
