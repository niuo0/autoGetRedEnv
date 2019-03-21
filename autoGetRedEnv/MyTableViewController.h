//
//  MyTableViewController.h
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/8.
//
//

#import <UIKit/UIKit.h>
#import "MyViewController.h"

@interface MyTableViewController : MyViewController <UITableViewDataSource, UITableViewDelegate>
@property (nonatomic, retain) UITableView * tableView;
@end
