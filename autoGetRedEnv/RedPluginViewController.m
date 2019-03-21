//
//  RedPluginViewController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/7.
//
//

#import "RedPluginViewController.h"
#import "SettingConfig.h"

@interface RedPluginViewController ()

@end

@implementation RedPluginViewController



//0：关闭红包插件
//1：打开红包插件
//2: 不抢自己的红包
//3: 不抢群里自己发的红包
- (NSArray *)titles{
    return @[@"关闭红包插件", @"打开红包插件", @"不抢自己的红包", @"不抢群里自己发的红包"];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self titles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"mySetting"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"mySetting"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = [[self titles] objectAtIndex:indexPath.row];
    if ([SettingConfig defaults].redPliginType == indexPath.row){
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    }
    
    
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [SettingConfig defaults].redPliginType = indexPath.row;
    
    [tableView reloadData];
    
}


@end
