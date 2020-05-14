//
//  ELSearchBar.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELSearchBar.h"
#import "ELColorMacros.h"
#import <Masonry/Masonry.h>
#import <XCCategory/UIColor+XCExtension.h>

@interface ELSearchBar()<UITextFieldDelegate>

@property (nonatomic, strong) UIButton *cancelButton;

@end


@implementation ELSearchBar

- (instancetype)init
{
    self = [super init];
    if (self) {
        [self _setupSubviews];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textFieldTextDidChange) name:UITextFieldTextDidChangeNotification object:nil];
    }
    
    return self;
}

- (void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

#pragma mark - Subviews

- (void)_setupSubviews
{
    self.backgroundColor = [UIColor whiteColor];
    
    _textField = [[UITextField alloc] init];
    _textField.delegate = self;
    _textField.backgroundColor = ELVIEW_BACKGROUND_COLOR;
    _textField.textColor = [UIColor blackColor];
    _textField.font = [UIFont systemFontOfSize:16];
    _textField.clearButtonMode = UITextFieldViewModeWhileEditing;
    _textField.leftViewMode = UITextFieldViewModeAlways;
    _textField.returnKeyType = UIReturnKeySearch;
    _textField.layer.cornerRadius = 8;
    _textField.enablesReturnKeyAutomatically = YES;
    [self addSubview:_textField];
    [_textField mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.left.equalTo(self).offset(15);
        make.right.equalTo(self).offset(-15);
        make.height.equalTo(@35);
    }];
    self.placeholder = @"请输入用户名/邮箱/手机号";
    
    UIView *leftView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, 30, 15)];
    UIImageView *searchIcon = [[UIImageView alloc] initWithFrame:leftView.bounds];
    searchIcon.contentMode = UIViewContentModeScaleAspectFit;
    searchIcon.image = [UIImage imageNamed:@"search_gray"];
    [leftView addSubview:searchIcon];
    self.textField.leftView = leftView;
    
    self.cancelButton = [[UIButton alloc] init];
    self.cancelButton.titleLabel.font = [UIFont systemFontOfSize:16];
    [self.cancelButton setTitle:@"取消" forState:UIControlStateNormal];
    [self.cancelButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    [self.cancelButton addTarget:self action:@selector(searchCancelButtonClicked) forControlEvents:UIControlEventTouchUpInside];
}

- (void)setPlaceholder:(NSString *)placeholder
{
    _placeholder = [placeholder copy];
    self.textField.attributedPlaceholder = [[NSAttributedString alloc] initWithString:placeholder attributes:@{NSForegroundColorAttributeName: [UIColor colorWithHexString:@"d2d2d2"]}];
}

#pragma mark - UITextFieldDelegate

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField
{
    [self addSubview:self.cancelButton];
    [self.cancelButton mas_makeConstraints:^(MASConstraintMaker *make) {
        make.centerY.equalTo(self);
        make.right.equalTo(self).offset(-5);
        make.width.equalTo(@50);
        make.height.equalTo(self);
    }];
    
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-65);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarShouldBeginEditing:)]) {
        [self.delegate searchBarShouldBeginEditing:self];
    }
    
    return YES;
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarSearchButtonClicked:)]) {
        [self.delegate searchBarSearchButtonClicked:textField.text];
    }
    
    return YES;
}

#pragma mark - Action

- (void)textFieldTextDidChange
{
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchTextDidChangeWithString:)]) {
        [self.delegate searchTextDidChangeWithString:self.textField.text];
    }
}

- (void)searchCancelButtonClicked
{
    [self.cancelButton removeFromSuperview];
    
    [self.textField resignFirstResponder];
    self.textField.text = nil;
    [self.textField mas_updateConstraints:^(MASConstraintMaker *make) {
        make.right.equalTo(self).offset(-15);
    }];
    
    if (self.delegate && [self.delegate respondsToSelector:@selector(searchBarCancelButtonAction:)]) {
        [self.delegate searchBarCancelButtonAction:self];
    }
}

@end
