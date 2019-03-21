//
//  Hook_WCPayLogicMgr.mm
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/14.
//
//

#import "CaptainHook.h"

CHDeclareClass(WCPayLogicMgr);

CHMethod1(void, WCPayLogicMgr, GetTransferPrepayRequest, id, arg1)
{
    //WCPayTransferMessageViewModel
    //WCPayC2CMessageViewModel
    
//    id trans = objc_msgSend(objc_getClass("WCPayTransferMessageViewModel"), @selector(alloc));
//    id pay = objc_msgSend(objc_getClass("WCPayC2CMessageViewModel"), @selector(alloc));
    
    CHSuper1(WCPayLogicMgr, GetTransferPrepayRequest, arg1);
}





















static void WCPayLogicMgr_Enter(){
    
    CHLoadLateClass(WCPayLogicMgr);
    CHClassHook1(WCPayLogicMgr, GetTransferPrepayRequest);
    
}


