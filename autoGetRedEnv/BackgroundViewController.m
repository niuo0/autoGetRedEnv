//
//  BackgroundViewController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/14.
//
//

#import "BackgroundViewController.h"

@implementation BackgroundViewController


- (NSArray *)titles{
    return @[@"关闭永久后台", @"开启永久后台"];
}



- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return [self titles].count;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:@"myBackground"];
    
    if (!cell){
        cell = [[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"myBackground"];
        //cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        cell.textLabel.textAlignment = NSTextAlignmentCenter;
    }
    
    cell.textLabel.text = [[self titles] objectAtIndex:indexPath.row];
    if ([SettingConfig defaults].backgroundType == indexPath.row){
        cell.textLabel.textColor = [UIColor redColor];
        cell.textLabel.font = [UIFont boldSystemFontOfSize:16.f];
    }else{
        cell.textLabel.textColor = [UIColor blackColor];
        cell.textLabel.font = [UIFont systemFontOfSize:16.f];
    }
    
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath{
    
    [SettingConfig defaults].backgroundType = indexPath.row;
    
    [tableView reloadData];
    
}

- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    return @"开启永久后台耗电量会略微增加";
    
}

@end
