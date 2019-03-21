//
//  StepCountViewController.m
//  autoGetRedEnv
//
//  Created by niu_o0 on 2017/8/8.
//
//

#import "StepCountViewController.h"

@interface StepCountCell : UITableViewCell
@property (nonatomic, strong) UITextField * textField;
@end

@implementation StepCountCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier{
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]){
        
        self.textField = [UITextField new];
        self.textField.borderStyle = UITextBorderStyleNone;
        self.textField.translatesAutoresizingMaskIntoConstraints = NO;
        self.textField.placeholder = @"输入步数";
        self.textField.keyboardType = UIKeyboardTypeNumberPad;
        self.textField.textAlignment = NSTextAlignmentCenter;
        [self addSubview:self.textField];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeLeft multiplier:1.f constant:20.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeTop multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeBottom relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeBottom multiplier:1.f constant:0.f]];
        [self addConstraint:[NSLayoutConstraint constraintWithItem:self.textField attribute:NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self attribute:NSLayoutAttributeRight multiplier:1.f constant:-20.f]];
        
    }
    
    return self;
}


@end


@implementation StepCountViewController


- (NSString *)tableView:(UITableView *)tableView titleForFooterInSection:(NSInteger)section{
    
    return @"微信最大步数为98800";
    
}


- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return 1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    
    StepCountCell * cell = [tableView dequeueReusableCellWithIdentifier:@"stepcell"];
    
    if(!cell){
        cell = [[StepCountCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:@"stepcell"];
    }
    
    cell.textField.text = [NSString stringWithFormat:@"%ld",(long)[SettingConfig defaults].stepCount];
    
    return cell;
}

- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    
    StepCountCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField becomeFirstResponder];
}

- (void)viewWillDisappear:(BOOL)animated{
    [super viewWillDisappear:animated];
    
    StepCountCell * cell = [self.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]];
    [cell.textField resignFirstResponder];
    
    NSInteger count = [cell.textField.text integerValue];
    
    if (count >= 98800) count = 98800;
    
    [SettingConfig defaults].stepCount = count;
}

@end
