//
//  MySettingViewController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/4.
//
//

#import "MySettingViewController.h"
#import <CoreGraphics/CoreGraphics.h>
#import <objc/runtime.h>
#import <objc/message.h>
#import "RedPluginViewController.h"
#import "StepCountViewController.h"
#import "BackgroundViewController.h"

@interface MySettingViewController ()

@end

@implementation MySettingViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
}


- (NSArray *)titleArray{
    return @[
            @"开启永久后台",
            @"群发助手",
            @"红包插件",
            @"修改微信步数",
            @"微信虚拟聊天",
    ];
}

#pragma mark - UITableViewDelegate


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self titleArray].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"mySetting"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mySetting"];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    }
    
    cell.textLabel.text = [self titleArray][indexPath.row];
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    UIBarButtonItem *item = [[UIBarButtonItem alloc] initWithTitle:@"  " style:UIBarButtonItemStylePlain target:nil action:nil];
    self.navigationItem.backBarButtonItem = item;
    self.navigationController.navigationBar.tintColor = [UIColor whiteColor];
    if (indexPath.row == 0){
        [self wechatBackground];
    }else if (indexPath.row == 1){
        [self qunfa];
    }else if (indexPath.row == 2){
        [self redPlugin:indexPath];
    }else if (indexPath.row == 3){
        [self stepCount:indexPath];
    }else if (indexPath.row == 4){
        [self wechat:indexPath];
    }
    
}

- (void)wechatBackground{
    BackgroundViewController * vc = [BackgroundViewController new];
    [self.navigationController pushViewController: vc animated:YES];
}

- (void)wechat:(NSIndexPath *)indexPath{
    
    //MMMassSendContactSelectorViewController
    id obj = objc_msgSend(objc_msgSend(objc_getClass("MMMassSendContactSelectorViewController"), @selector(alloc)), @selector(init));
    
    [self.navigationController pushViewController:obj animated:YES];
    
    MMMassSendContactSelectorViewController_hook();
}

//微信步数

- (void)stepCount:(NSIndexPath *)indexPath{
    StepCountViewController * vc = [[StepCountViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = [self titleArray][indexPath.row];
}

//红包插件

- (void)redPlugin:(NSIndexPath *)indexPath{
    RedPluginViewController * vc = [[RedPluginViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
    vc.title = [self titleArray][indexPath.row];
}

//群发助手
- (void)qunfa{
    
    id server = objc_msgSend(objc_getClass("MMServiceCenter"), sel_registerName("defaultCenter"));
    //CContactMgr
    id contactMgr = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("CContactMgr"));
    
    id contact = ((id (*)(id, SEL, NSString*))objc_msgSend)(contactMgr, @selector(getContactByName:), @"masssendapp");
    
    id manager = ((id (*)(id, SEL, Class))objc_msgSend)(server, @selector(getService:),objc_getClass("MMMsgLogicManager"));
    
    ((id (*)(id, SEL, id, id, BOOL))objc_msgSend)(manager, @selector(PushOtherBaseMsgControllerByContact: navigationController: animated:),contact, self.navigationController, YES);
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self.tableView deselectRowAtIndexPath:self.tableView.indexPathForSelectedRow animated:YES];
    
}

- (void)dealloc{
    WeixinContentLogicController_unHook();
    MMMassSendContactSelectorViewController_unhook();
}


@end







