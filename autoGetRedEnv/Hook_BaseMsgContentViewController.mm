//
//  Hook_BaseMsgContentViewController.mm
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/10.
//
//

#import "CaptainHook.h"
#import "SettingConfig.h"
#import <UIKit/UIKit.h>


CHDeclareClass(BaseMsgContentViewController);


CHMethod(3, void, BaseMsgContentViewController, addMessageNode, id, arg1, layout, BOOL, arg2, addMoreMsg, BOOL, arg3)
{
    
    CHSuper(3, BaseMsgContentViewController, addMessageNode, arg1, layout, arg2, addMoreMsg, arg3);
    
    if ([SettingConfig defaults].noWriteHook == false) return;
    
    if ([SettingConfig defaults].noWriteIsSelf) return;
    
    Ivar ivar = class_getInstanceVariable(object_getClass(self), "m_arrMessageNodeData");
    
    id obj = object_getIvar(self, ivar);
    
    obj = [obj lastObject];
    
    ivar = class_getInstanceVariable(object_getClass(obj), "m_isSender");
    
    object_setIvar(obj, ivar, NO);
    
    ((void(*)(id, SEL, id))objc_msgSend)(obj, @selector(setContact:), [SettingConfig defaults].noWriteContact);
    
    
}



CHMethod(1, void, BaseMsgContentViewController, openChatInfo, id, arg1)
{
    
    
    if ([SettingConfig defaults].noWriteHook == false) {
        CHSuper(1, BaseMsgContentViewController, openChatInfo, arg1);
        return;
    }
    
    id obj = ((id(*)(id, SEL))objc_msgSend)(self, @selector(navigationController));
    obj = ((id(*)(id, SEL))objc_msgSend)(obj, @selector(navigationBar));
    obj = ((id(*)(id, SEL))objc_msgSend)(obj, @selector(subviews));
    [obj enumerateObjectsUsingBlock:^(id  _Nonnull view, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([view isKindOfClass:objc_getClass("MMTitleView")]){
            UIView * _view = [[view subviews] firstObject];
            UILabel * label = [[_view subviews] firstObject];
            
            id server = objc_msgSend(objc_getClass("MMServiceCenter"), sel_registerName("defaultCenter"));
            //CContactMgr
            id contactMgr = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("CContactMgr"));
            id contact = ((id (*)(id, SEL))objc_msgSend)(contactMgr, @selector(getSelfContact));
            NSString * name = objc_msgSend(contact, @selector(m_nsNickName));
            
            if ([objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsRemark)) length]) {
                if ([label.text isEqualToString:objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsRemark))]){
                    label.text = name;
                    [SettingConfig defaults].noWriteIsSelf = YES;
                }else{
                    label.text = objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsRemark));
                    [SettingConfig defaults].noWriteIsSelf = NO;
                }
            }else{
                if ([label.text isEqualToString:objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsNickName))]){
                    label.text = name;
                    [SettingConfig defaults].noWriteIsSelf = YES;
                }else{
                    label.text = objc_msgSend([SettingConfig defaults].noWriteContact, @selector(m_nsNickName));
                    [SettingConfig defaults].noWriteIsSelf = NO;
                }
            }
            
            *stop = YES;
            return;
        }
    }];
}




static void baseMsgContentViewController_Enter(){
    
    CHLoadLateClass(BaseMsgContentViewController);
    CHHook(3, BaseMsgContentViewController, addMessageNode, layout, addMoreMsg);
    CHHook(1, BaseMsgContentViewController, openChatInfo);
    
}



