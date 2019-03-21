//
//  autoGetRedEnv.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/6.
//

#import "CaptainHook.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import <CoreGraphics/CoreGraphics.h>
#import <UIKit/UIKit.h>
#import <Foundation/Foundation.h>
#import "RunInBackground.h"
#import "MySettingViewController.h"

/*
 0x100068000 - 0x103987fff WeChat arm64  <cf496c98a43437569f1db6e9bd52b058> /var/mobile/Containers/Bundle/Application/EF6C3F7E-A1BF-4393-9D89-75EA71F2C4F5/WeChat.app/WeChat
 
 StackSymbols= (
 0   libautoGetRedEnv.dylib              0x0000000104a128e4 _ZL55$WCRedEnvelopesLogicMgr_OpenRedEnvelopesRequest$_methodP22WCRedEnvelopesLogicMgrP13objc_selectorP11objc_object + 92
 1   WeChat                              0x000000010180d9e0 _Z18_mcwxh_dydx33_8to8P11_VDecStructPhS1_jjjj + 11406836
 ---------------
 0x17A59E0
 [WCRedEnvelopesReceiveControlLogic WCRedEnvelopesReceiveHomeViewOpenRedEnvelopes]
 ---------------
 2   WeChat                              0x00000001014dab38 _Z18_mcwxh_dydx33_8to8P11_VDecStructPhS1_jjjj + 8052556
 ---------------
 0x1472B38
 -[WCPayLogicMgr checkHongbaoOpenLicense:acceptCallback:denyCallback:]
 ---------------
 3   WeChat                              0x000000010180d8d0 _Z18_mcwxh_dydx33_8to8P11_VDecStructPhS1_jjjj + 11406564
 ---------------
 0x17A58D0
 [WCRedEnvelopesReceiveControlLogic WCRedEnvelopesReceiveHomeViewOpenRedEnvelopes]
 ---------------
 4   WeChat                              0x00000001014a095c _Z18_mcwxh_dydx33_8to8P11_VDecStructPhS1_jjjj + 7814512
 
 ------------
 0x143895C
[WCRedEnvelopesReceiveHomeView OnOpenRedEnvelopes]
 ------------
 5   UIKit                               0x000000018ab59404 <redacted> + 96
 6   UIKit                               0x000000018ab424e0 <redacted> + 612
 7   UIKit                               0x000000018ab58da0 <redacted> + 592
 8   UIKit                               0x000000018ab58a2c <redacted> + 700
 9   UIKit                               0x000000018ab51f68 <redacted> + 684
 10  UIKit                               0x000000018ab2518c <redacted> + 264
 11  UIKit                               0x000000018adc6324 <redacted> + 15424
 12  UIKit                               0x000000018ab236a0 <redacted> + 1716
 13  CoreFoundation                      0x000000018609c240 <redacted> + 24
 14  CoreFoundation                      0x000000018609b4e4 <redacted> + 264
 15  CoreFoundation                      0x0000000186099594 <redacted> + 712
 16  CoreFoundation                      0x0000000185fc52d4 CFRunLoopRunSpecific + 396
 17  GraphicsServices                    0x000000018f7db6fc GSEventRunModal + 168
 18  UIKit                               0x000000018ab8afac UIApplicationMain + 1488
 19  WeChat                              0x000000010012cdb4 WeChat + 806324
 20  libdyld.dylib                       0x0000000197f86a08 <redacted> + 4
	)
 
 
 timingIdentifier = BAFB28D18CD7AB7DF155F394BD5BB24C;
 */


static inline void config();

/**
 *  插件功能
 */
static int const kCloseRedEnvPlugin = 0;
static int const kOpenRedEnvPlugin = 1;
static int const kCloseRedEnvPluginForMyself = 2;
static int const kCloseRedEnvPluginForMyselfFromChatroom = 3;

//0：关闭红包插件
//1：打开红包插件
//2: 不抢自己的红包
//3: 不抢群里自己发的红包
static int HBPliginType = 1;

NSMutableDictionary *params;


//#define LOADSETTINGS(key) ({ \
//NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES); \
//NSString *docDir = [paths objectAtIndex:0]; \
//if (!docDir){ return} \
//NSString *path = [docDir stringByAppendingPathComponent:@"HBPluginSettings.txt"]; \
//NSDictionary *dict = [[NSDictionary alloc] initWithContentsOfFile:path]; \
//if(!dict){ return} \
//NSNumber *number = [dict objectForKey:key]; \
//0
//})

CHDeclareClass(CMessageMgr);
CHDeclareClass(WCRedEnvelopesLogicMgr)



/*
 0x00000001000e4000
 send
 [CMessageMgr AddMsg:MsgWrap:]
 [WeixinContentLogicController AddMsg:MsgWrap:]
 [BaseMsgContentLogicController SendTextMessage:]
 [BaseMsgContentViewController AsyncSendMessage:]
 [SafePerformObject doPerformSelector:]
 
 recv
 [CMessageMgr MessageReturn:MessageInfo:Event:]
 [CAppObserverCenter NotifyFromMainCtrl:MessageInfo:Event:]
 [CMainControll TimerCheckEvent]
 [MMNoRetainTimerTarget onNoRetainTimer:]
 */


CHMethod(2, void, CMessageMgr, AsyncOnAddMsg, id, arg1, MsgWrap, id, arg2)
{
    CHSuper(2, CMessageMgr, AsyncOnAddMsg, arg1, MsgWrap, arg2);
    
    Ivar uiMessageTypeIvar = class_getInstanceVariable(objc_getClass("CMessageWrap"), "m_uiMessageType");
    ptrdiff_t offset = ivar_getOffset(uiMessageTypeIvar);
    unsigned char *stuffBytes = (unsigned char *)(__bridge void *)arg2;
    NSUInteger m_uiMessageType = * ((NSUInteger *)(stuffBytes + offset));
    
    Ivar nsFromUsrIvar = class_getInstanceVariable(objc_getClass("CMessageWrap"), "m_nsFromUsr");
    id m_nsFromUsr = object_getIvar(arg2, nsFromUsrIvar);
    
    Ivar nsContentIvar = class_getInstanceVariable(objc_getClass("CMessageWrap"), "m_nsContent");
    id m_nsContent = object_getIvar(arg2, nsContentIvar);
    
    //NSLog(@"```%@```%@``%@``%@", [arg1 class], [arg1 class], arg1, arg2);
   // NSLog(@"`````````````````````%lu```````",(unsigned long)m_uiMessageType);
    
    switch(m_uiMessageType) {
        case 1:
        {
            //普通消息
            //红包插件功能
            //0：关闭红包插件
            //1：打开红包插件
            //2: 不抢自己的红包
            //3: 不抢群里自己发的红包
            //微信的服务中心
            Method methodMMServiceCenter = class_getClassMethod(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
            IMP impMMSC = method_getImplementation(methodMMServiceCenter);
            id MMServiceCenter = impMMSC(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
            
            //通讯录管理器
            id contactManager = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:),objc_getClass("CContactMgr"));
            id selfContact = objc_msgSend(contactManager, @selector(getSelfContact));
            
            Ivar nsUsrNameIvar = class_getInstanceVariable([selfContact class], "m_nsUsrName");
            id m_nsUsrName = object_getIvar(selfContact, nsUsrNameIvar);
            BOOL isMesasgeFromMe = NO;
            if ([m_nsFromUsr isEqualToString:m_nsUsrName]) {
                //发给自己的消息
                isMesasgeFromMe = YES;
            }
            
            if (isMesasgeFromMe)
            {
                //NSLog(@"```````````````````````````yes````");
                
                if ([m_nsContent rangeOfString:@"打开红包插件"].location != NSNotFound)
                {
                    HBPliginType = kOpenRedEnvPlugin;
                }
                else if ([m_nsContent rangeOfString:@"关闭红包插件"].location != NSNotFound)
                {
                    HBPliginType = kCloseRedEnvPlugin;
                }
                else if ([m_nsContent rangeOfString:@"关闭抢自己红包"].location != NSNotFound)
                {
                    HBPliginType = kCloseRedEnvPluginForMyself;
                }
                else if ([m_nsContent rangeOfString:@"关闭抢自己群红包"].location != NSNotFound)
                {
                    HBPliginType = kCloseRedEnvPluginForMyselfFromChatroom;
                }
                
            }
        }
            break;
        case 49: {
            // 49=红包
            
            //微信的服务中心
            Method methodMMServiceCenter = class_getClassMethod(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
            IMP impMMSC = method_getImplementation(methodMMServiceCenter);
            id MMServiceCenter = impMMSC(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
            //红包控制器
            id logicMgr = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:),objc_getClass("WCRedEnvelopesLogicMgr"));
            //通讯录管理器
            id contactManager = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:),objc_getClass("CContactMgr"));
            
            Method methodGetSelfContact = class_getInstanceMethod(objc_getClass("CContactMgr"), @selector(getSelfContact));
            IMP impGS = method_getImplementation(methodGetSelfContact);
            id selfContact = impGS(contactManager, @selector(getSelfContact));
            
            Ivar nsUsrNameIvar = class_getInstanceVariable([selfContact class], "m_nsUsrName");
            id m_nsUsrName = object_getIvar(selfContact, nsUsrNameIvar);
            BOOL isMesasgeFromMe = NO;
            BOOL isChatroom = NO;
            if ([m_nsFromUsr isEqualToString:m_nsUsrName]) {
                isMesasgeFromMe = YES;
            }
            if ([m_nsFromUsr rangeOfString:@"@chatroom"].location != NSNotFound)
            {
                isChatroom = YES;
            }
            if (isMesasgeFromMe && kCloseRedEnvPluginForMyself == [SettingConfig defaults].redPliginType && !isChatroom) {
                //不抢自己的红包
                break;
            }
            else if(isMesasgeFromMe && kCloseRedEnvPluginForMyselfFromChatroom == [SettingConfig defaults].redPliginType && isChatroom)
            {
                //不抢群里自己的红包
                break;
            }
            
            if ([m_nsContent rangeOfString:@"wxpay://"].location != NSNotFound)
            {
                //NSLog(@"``````````%@",m_nsContent);
                
                NSString *nativeUrl = m_nsContent;
                NSRange rangeStart = [m_nsContent rangeOfString:@"wxpay://c2cbizmessagehandler/hongbao"];
                if (rangeStart.location != NSNotFound)
                {
                    NSUInteger locationStart = rangeStart.location;
                    nativeUrl = [nativeUrl substringFromIndex:locationStart];
                }
                
                NSRange rangeEnd = [nativeUrl rangeOfString:@"]]"];
                if (rangeEnd.location != NSNotFound)
                {
                    NSUInteger locationEnd = rangeEnd.location;
                    nativeUrl = [nativeUrl substringToIndex:locationEnd];
                }
                
                NSString *naUrl = [nativeUrl substringFromIndex:[@"wxpay://c2cbizmessagehandler/hongbao/receivehongbao?" length]];
                
                NSArray *parameterPairs =[naUrl componentsSeparatedByString:@"&"];
                
                NSMutableDictionary *parameters = [NSMutableDictionary dictionaryWithCapacity:[parameterPairs count]];
                for (NSString *currentPair in parameterPairs) {
                    NSRange range = [currentPair rangeOfString:@"="];
                    if(range.location == NSNotFound)
                        continue;
                    NSString *key = [currentPair substringToIndex:range.location];
                    NSString *value =[currentPair substringFromIndex:range.location + 1];
                    [parameters setObject:value forKey:key];
                }
                
                //红包参数
                params = [@{} mutableCopy];
                
                [params setObject:parameters[@"msgtype"]?:@"null" forKey:@"msgType"];
                [params setObject:parameters[@"sendid"]?:@"null" forKey:@"sendId"];
                [params setObject:parameters[@"channelid"]?:@"null" forKey:@"channelId"];
                
                id getContactDisplayName = objc_msgSend(selfContact, @selector(getContactDisplayName));
                id m_nsHeadImgUrl = objc_msgSend(selfContact, @selector(m_nsHeadImgUrl));
                
                [params setObject:getContactDisplayName forKey:@"nickName"];
                [params setObject:m_nsHeadImgUrl forKey:@"headImg"];
                [params setObject:[NSString stringWithFormat:@"%@", nativeUrl]?:@"null" forKey:@"nativeUrl"];
                [params setObject:m_nsFromUsr?:@"null" forKey:@"sessionUserName"];
                
                //NSLog(@"``````````````%@",params);
                
                if (kCloseRedEnvPlugin != [SettingConfig defaults].redPliginType) {
                    
                    NSMutableDictionary * dic = [NSMutableDictionary dictionary];
                    [dic setObject:@"0" forKey:@"agreeDuty"];
                    [dic setObject:@"0" forKey:@"inWay"];
                    [dic setObject:parameters[@"msgtype"]?:@"null" forKey:@"msgType"];
                    [dic setObject:parameters[@"sendid"]?:@"null" forKey:@"sendId"];
                    [dic setObject:parameters[@"channelid"]?:@"null" forKey:@"channelId"];
                    [dic setObject:[NSString stringWithFormat:@"%@", nativeUrl]?:@"null" forKey:@"nativeUrl"];
                    
                    ((void (*)(id, SEL, NSMutableDictionary*))objc_msgSend)(logicMgr, @selector(ReceiverQueryRedEnvelopesRequest:), dic);
                    
                }
                return;
            }
            
            break;
        }
        default:
            break;
    }
}


/*
 [WCRedEnvelopesReceiveControlLogic OnReceiverQueryRedEnvelopesRequest:Error:]
 [WCRedEnvelopesLogicMgr OnWCToHongbaoCommonResponse:Request:]
 [WCRedEnvelopesNetworkHelper MessageReturnOnHongbao:Event:]
 [WCRedEnvelopesNetworkHelper MessageReturn:Event:]
 [CAppObserverCenter NotifyFromMainCtrl:Event:]
 [CMainControll TimerCheckEvent]
 [MMNoRetainTimerTarget onNoRetainTimer:]
 */


CHMethod(2, void, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, id, arg1, Request, id, arg2)
{
    
    CHSuper(2, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, arg1, Request, arg2);
    
    
    id ret = objc_msgSend(arg1, @selector(retText));
    
    NSData * data = objc_msgSend(ret, @selector(buffer));
    
    NSDictionary * dic = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    
    NSString * timing = [dic objectForKey:@"timingIdentifier"];
    
    if (timing.length && [[dic objectForKey:@"receiveStatus"] integerValue] == 0){
        
        [params setObject:timing forKey:@"timingIdentifier"];
        Method methodMMServiceCenter = class_getClassMethod(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
        IMP impMMSC = method_getImplementation(methodMMServiceCenter);
        id MMServiceCenter = impMMSC(objc_getClass("MMServiceCenter"), @selector(defaultCenter));
        //红包控制器
        id logicMgr = ((id (*)(id, SEL, Class))objc_msgSend)(MMServiceCenter, @selector(getService:),objc_getClass("WCRedEnvelopesLogicMgr"));
        //自动抢红包
        ((void (*)(id, SEL, NSMutableDictionary*))objc_msgSend)(logicMgr, @selector(OpenRedEnvelopesRequest:), params);
    }
    
}


CHDeclareClass(WCDeviceStepObject);

CHOptimizedMethod(0, self, unsigned int, WCDeviceStepObject, m7StepCount) {
    
    return [SettingConfig defaults].stepCount + CHSuper(0, WCDeviceStepObject, m7StepCount);
    
}

CHOptimizedMethod(0, self, unsigned int, WCDeviceStepObject, hkStepCount) {
    
    return [SettingConfig defaults].stepCount + CHSuper(0, WCDeviceStepObject, hkStepCount);
    
}


CHDeclareClass(MicroMessengerAppDelegate);

CHMethod(1, void, MicroMessengerAppDelegate, applicationDidEnterBackground, id, arg1)
{
    //CHSuper(1, MicroMessengerAppDelegate, applicationDidEnterBackground, arg1);
    
    if ([SettingConfig defaults].backgroundType == 0) return;
    
    MicroMessengerAppDelegate * delegate = (MicroMessengerAppDelegate *)[UIApplication sharedApplication].delegate;
    
    objc_setAssociatedObject(delegate, "isRun", @(YES), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
    [[RunInBackground sharedBg] startRunInbackGround];
    
}

CHMethod(1, void, MicroMessengerAppDelegate, applicationDidBecomeActive, id, arg1)
{
    //CHSuper(1, MicroMessengerAppDelegate, applicationDidBecomeActive, arg1);
    
    if ([SettingConfig defaults].backgroundType == 0) return;
    
    MicroMessengerAppDelegate * delegate = (MicroMessengerAppDelegate *)[UIApplication sharedApplication].delegate;
    
    BOOL isRun = [objc_getAssociatedObject(delegate, "isRun") boolValue];
    
    if (isRun) {
        objc_setAssociatedObject(delegate, "isRun", @(NO), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        [[RunInBackground sharedBg] stopAudioPlay];
    }
}


CHDeclareClass(NewMainFrameViewController);

static void buttonClickIMP(id self, SEL _cmd){
    
    MySettingViewController * vc = [MySettingViewController new];
    vc.hidesBottomBarWhenPushed = YES;
    
    ((void(*)(id, SEL, id))objc_msgSend)(self, @selector(PushViewController:), vc);
    vc.title = @"更多";
    
}

CHMethod(0, void, NewMainFrameViewController, initBarItem)
{
    
    CHSuper(0, NewMainFrameViewController, initBarItem);
    
    UIButton * button = [UIButton new];
    button.bounds = CGRectMake(0, 0, 43, 44);
    [button setTitle:@"更多" forState:UIControlStateNormal];
    [button setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    [button addTarget:self action:@selector(buttonClick) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem * item = [[UIBarButtonItem alloc] initWithCustomView:button];
    
    
    class_addMethod(objc_getClass("NewMainFrameViewController"), @selector(buttonClick), (IMP)buttonClickIMP, "v@:");
    objc_setAssociatedObject(self, "leftBarItem", item, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    
}

CHMethod(1, void, NewMainFrameViewController, viewDidAppear, BOOL, arg1)
{
    
    CHSuper(1, NewMainFrameViewController, viewDidAppear, arg1);
    
    ((void (*)(id, SEL, id))objc_msgSend)(objc_msgSend(self, @selector(navigationItem)), @selector(setLeftBarButtonItem:), objc_getAssociatedObject(self, "leftBarItem"));
    
}

CHDeclareClass(MMLocationMgr);

CHMethod(0, void, MMLocationMgr, requestForAuthorization){
    
    NSLog(@"·········请求定位");
    
    CHSuper0(MMLocationMgr, requestForAuthorization);
    
}


__attribute__((constructor)) static void entry()
{
    
    NSLog(@"````````````````````````\n\n\n\n``````````````");
    
    return;
    
    CHLoadLateClass(MMLocationMgr);
    CHClassHook(0, MMLocationMgr,requestForAuthorization);
    
    
    CHLoadLateClass(CMessageMgr);
    CHClassHook(2, CMessageMgr, AsyncOnAddMsg, MsgWrap);
    
    CHLoadLateClass(WCRedEnvelopesLogicMgr);
//    CHClassHook(1, WCRedEnvelopesLogicMgr, OpenRedEnvelopesRequest);
//    CHClassHook(1, WCRedEnvelopesLogicMgr, ReceiverQueryRedEnvelopesRequest);
    CHClassHook(2, WCRedEnvelopesLogicMgr, OnWCToHongbaoCommonResponse, Request);
    
    // 微信步数
    CHLoadLateClass(WCDeviceStepObject);
    CHHook(0, WCDeviceStepObject, m7StepCount);
    CHHook(0, WCDeviceStepObject, hkStepCount);
    
    //AppDelegate
    CHLoadLateClass(MicroMessengerAppDelegate);
    CHClassHook(1, MicroMessengerAppDelegate, applicationDidEnterBackground);
    CHClassHook(1, MicroMessengerAppDelegate, applicationDidBecomeActive);

    
    CHLoadLateClass(NewMainFrameViewController);
    CHClassHook(0, NewMainFrameViewController, initBarItem);
    CHClassHook(1, NewMainFrameViewController, viewDidAppear);
    
    config();
    WeixinContentLogicController_enter();
    MMMassSendContactSelectorViewController_enter();
}

static inline void config(){
    
    [SettingConfig defaults];
    
}







