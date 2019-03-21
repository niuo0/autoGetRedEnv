//
//  Hook_MMMassSendContactSelectorViewController.mm
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/14.
//
//

#import "CaptainHook.h"
#import <objc/message.h>
#import <UIKit/UIKit.h>
#import "SettingConfig.h"
#import "Hook_WeixinContentLogicController.mm"


CHDeclareClass(MMMassSendContactSelectorViewController);


CHMethod(1, void, MMMassSendContactSelectorViewController, onDone, id, arg1)
{
    
    if (![SettingConfig defaults].noWrite_Hook_MMMassSendContactSelectorViewController){
        CHSuper(1, MMMassSendContactSelectorViewController, onDone, arg1);
        return;
    }
    
    NSMutableSet * set = objc_msgSend(self, @selector(setSelectedContacts));
    
    id obj = [set anyObject];
    
    id nav = objc_msgSend(self, @selector(navigationController));
    
    ((void(*)(id, SEL, BOOL))objc_msgSend)(nav, @selector(popViewControllerAnimated:), NO);
    
    id server = objc_msgSend(objc_getClass("MMServiceCenter"), sel_registerName("defaultCenter"));
    //CContactMgr
    id contactMgr = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("CContactMgr"));
    
    id contact = ((id (*)(id, SEL))objc_msgSend)(contactMgr, @selector(getSelfContact));
    
    id manager = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("MMMsgLogicManager"));
    
    //WeixinContentLogicController
    Class _class = ((id (*)(id, SEL, id))objc_msgSend)(manager, @selector(GetLogicClassByContact:),contact);
    
    WeixinContentLogicController_hook();
    
    id vclogic = objc_msgSend(objc_msgSend(_class, @selector(alloc)), @selector(init));
    
    ((id (*)(id, SEL, id))objc_msgSend)(vclogic, @selector(setM_contact:), contact);
    
    objc_msgSend(vclogic, @selector(onWillEnterRoom));
    
    UIViewController * vc = objc_msgSend(vclogic, @selector(getViewController));
    
    [vc setHidesBottomBarWhenPushed:YES];
    
    ((void(*)(id, SEL, id, BOOL))objc_msgSend)(nav, @selector(pushViewController:animated:), vc, YES);
    
    NSString * _name = objc_msgSend(obj, @selector(m_nsRemark));
    
    if (!_name.length) _name = objc_msgSend(obj, @selector(m_nsNickName));
    
    [SettingConfig defaults].noWriteContact = obj;
    [SettingConfig defaults].noWriteIsSelf = NO;
    ((id (*)(id, SEL, NSString *))objc_msgSend)(contact, @selector(setM_nsNickName:), _name);

}

//去掉全选按钮
CHMethod(0, void, MMMassSendContactSelectorViewController, initView)
{
    CHSuper(0, MMMassSendContactSelectorViewController, initView);
    
    if (![SettingConfig defaults].noWrite_Hook_MMMassSendContactSelectorViewController) return;
    
    id item = objc_msgSend(self, @selector(navigationItem));
    ((void(*)(id, SEL, id))objc_msgSend)(item, @selector(setRightBarButtonItem:), nil);
    
}

//多选改单选
CHMethod(2, void, MMMassSendContactSelectorViewController, tableView, id, arg1, didSelectRowAtIndexPath, NSIndexPath *, arg2)
{
    
    if ([SettingConfig defaults].noWrite_Hook_MMMassSendContactSelectorViewController){
        
        NSMutableSet * set = objc_msgSend(self, @selector(setSelectedContacts));
        
        id contact = [set anyObject];
        
        if (contact){
            [set removeAllObjects];
            [arg1 reloadRowsAtIndexPaths:@[objc_getAssociatedObject(self, "m_selectIndexPath")] withRowAnimation:UITableViewRowAnimationNone];
        }
        
        objc_setAssociatedObject(self, "m_selectIndexPath", arg2, OBJC_ASSOCIATION_RETAIN_NONATOMIC);
    }
    
    CHSuper(2, MMMassSendContactSelectorViewController, tableView, arg1, didSelectRowAtIndexPath, arg2);
}







static void MMMassSendContactSelectorViewController_hook(){
    [SettingConfig defaults].noWrite_Hook_MMMassSendContactSelectorViewController = YES;
}

static void MMMassSendContactSelectorViewController_unhook(){
    [SettingConfig defaults].noWrite_Hook_MMMassSendContactSelectorViewController = NO;
}

static void MMMassSendContactSelectorViewController_enter(){
    
    CHLoadLateClass(MMMassSendContactSelectorViewController);
    
    CHHook(1, MMMassSendContactSelectorViewController, onDone);
    
    CHHook(0, MMMassSendContactSelectorViewController, initView);
    
    CHHook(2, MMMassSendContactSelectorViewController, tableView, didSelectRowAtIndexPath);
    
}
