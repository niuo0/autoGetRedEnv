//
//  Hook_WeixinContentLogicController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/9.
//
//

#import "CaptainHook.h"
#import "SettingConfig.h"
#import "Hook_BaseMsgContentViewController.mm"
#import "Hook_WCPayLogicMgr.mm"

CHDeclareClass(WeixinContentLogicController);

CHMethod(2, void, WeixinContentLogicController, AddMsg, id, arg1, MsgWrap, id, arg2)
{
    
    if (![SettingConfig defaults].noWriteHook) {
        return CHSuper(2, WeixinContentLogicController, AddMsg, arg1, MsgWrap, arg2);
    }
    
    ((void(*)(id, SEL, NSUInteger))objc_msgSend)(arg2, @selector(setM_uiStatus:), 2);
    
    CHSuper(2, WeixinContentLogicController, AddMsg, arg1, MsgWrap, arg2);

}


//发送转账
CHMethod0(void, WeixinContentLogicController, onTransferMoneyControlLogic)
{
//    id server = objc_msgSend(objc_getClass("MMServiceCenter"), sel_registerName("defaultCenter"));
//    //WCPayControlMgr
//    id payControlMgr = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("WCPayControlMgr"));
//    BOOL res = ((BOOL(*)(id, SEL))objc_msgSend)(payControlMgr, @selector(isHtml5Wallet));
//    if (!res){
//        id logic = objc_msgSend(self, @selector(getViewController));
//        id name = objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsUsrName));
//        ((int(*)(id, SEL, id, id))objc_msgSend)(payControlMgr, @selector(startTransferMoneyLogic:WithSessionUserName:),logic, name);
//        return;
//    }
    
    CHSuper0(WeixinContentLogicController, onTransferMoneyControlLogic);
}


//发送红包
CHMethod(0, void, WeixinContentLogicController, onRedEnvelopesControlLogic)
{
    CHSuper(0, WeixinContentLogicController, onRedEnvelopesControlLogic);
}


//发送自定义表情
CHMethod(1, void, WeixinContentLogicController, SendEmoticonMessage, id, arg1)
{
    CHSuper(1, WeixinContentLogicController, SendEmoticonMessage, arg1);
}


CHDeclareClass(CBaseContact);
CHMethod(0, BOOL, CBaseContact, isSelf)
{
    BOOL isSelf = CHSuper(0, CBaseContact, isSelf);
    
    return [SettingConfig defaults].noWriteHook?NO:isSelf;
}


CHDeclareClass(SendMessageMgr);
CHMethod(2, void, SendMessageMgr, AddMsgToSendTable, id, arg1, MsgWrap, id, arg2)
{
    if ([SettingConfig defaults].noWriteHook == false)
        CHSuper(2, SendMessageMgr, AddMsgToSendTable, arg1, MsgWrap, arg2);
}


static void WeixinContentLogicController_enter(){
    
    baseMsgContentViewController_Enter();
    WCPayLogicMgr_Enter();
    
    CHLoadLateClass(WeixinContentLogicController);
    CHClassHook(2, WeixinContentLogicController, AddMsg, MsgWrap);
    CHClassHook(0, WeixinContentLogicController, onRedEnvelopesControlLogic);
    CHClassHook(1, WeixinContentLogicController, SendEmoticonMessage);
    CHClassHook0(WeixinContentLogicController, onTransferMoneyControlLogic);
    
    CHLoadLateClass(CBaseContact);
    CHHook(0, CBaseContact, isSelf);
    
    CHLoadLateClass(SendMessageMgr);
    CHClassHook(2, SendMessageMgr, AddMsgToSendTable, MsgWrap);
    
}

static void WeixinContentLogicController_hook(){
    [SettingConfig defaults].noWriteHook = YES;
}

static void WeixinContentLogicController_unHook(){
    [SettingConfig defaults].noWriteHook = NO;
}
