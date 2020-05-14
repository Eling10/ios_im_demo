//
//  ELCallButton.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELCallButton.h"
#import <Masonry/Masonry.h>

@implementation ELCallButtonState
@end


@interface ELCallButton ()

@property (nonatomic, strong) NSString *normalTitle;

@property (nonatomic, strong) UIImageView *imgView;

@property (nonatomic, strong) NSMutableDictionary *stateDict;

@end

@implementation ELCallButton

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction
{
    self = [super init];
    if (self) {
        _normalTitle = aTitle;
        _stateDict = [[NSMutableDictionary alloc] init];
        
        
        [self _setupSubviewsWithTitle:aTitle];
        
        [self addTarget:aTarget action:aAction forControlEvents:UIControlEventTouchUpInside];
        
        ELCallButtonState *buttonState = [[ELCallButtonState alloc] init];
        buttonState.title = aTitle;
        buttonState.titleColor = [UIColor blackColor];
        [self.stateDict setObject:buttonState forKey:@(UIControlStateNormal)];
    }
    
    return self;
}

- (void)_setupSubviewsWithTitle:(NSString *)aTitle
{
    self.imgView = [[UIImageView alloc] init];
    self.imgView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:self.imgView];
    [self.imgView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
        make.height.equalTo(self).multipliedBy(0.6);
    }];
    
    self.titleLabel = [[UILabel alloc] init];
    self.titleLabel.backgroundColor = [UIColor clearColor];
    self.titleLabel.textAlignment = NSTextAlignmentCenter;
    self.titleLabel.textColor = [UIColor blackColor];
    self.titleLabel.font = [UIFont systemFontOfSize:13];
    self.titleLabel.text = aTitle;
    [self addSubview:self.titleLabel];
    [self.titleLabel mas_makeConstraints:^(MASConstraintMaker *make) {
        make.top.equalTo(self.imgView.mas_bottom);
        make.bottom.equalTo(self);
        make.left.equalTo(self);
        make.right.equalTo(self);
    }];
}

#pragma mark - Private

- (ELCallButtonState *)_getButtonStateWithState:(UIControlState)aState
{
    ELCallButtonState *buttonState = [self.stateDict objectForKey:@(aState)];
    if (!buttonState) {
        buttonState = [[ELCallButtonState alloc] init];
        buttonState.title = self.normalTitle;
        buttonState.titleColor = [UIColor blackColor];
        [self.stateDict setObject:buttonState forKey:@(aState)];
    }
    
    return buttonState;
}

- (void)_reloadWithState:(UIControlState)aState
{
    ELCallButtonState *buttonState = [self.stateDict objectForKey:@(aState)];
    if (buttonState) {
        self.imgView.image = buttonState.image;
        self.titleLabel.textColor = buttonState.titleColor;
        self.titleLabel.text = buttonState.title;
    }
}

#pragma mark - Public

- (void)setSelected:(BOOL)selected
{
    [super setSelected:selected];
    
    UIControlState state = UIControlStateNormal;
    if (selected) {
        state = UIControlStateSelected;
    }
    [self _reloadWithState:state];
}

- (void)setEnabled:(BOOL)enabled
{
    [super setEnabled:enabled];
    
    UIControlState state = UIControlStateNormal;
    if (!enabled) {
        state = UIControlStateDisabled;
    }
    [self _reloadWithState:state];
}

- (void)setTitle:(nullable NSString *)title
        forState:(UIControlState)state
{
    ELCallButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.title = title;
    
    if (self.state == state) {
        self.titleLabel.text = title;
    }
}

- (void)setTitleColor:(nullable UIColor *)color
             forState:(UIControlState)state
{
    ELCallButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.titleColor = color;
    
    if (self.state == state) {
        self.titleLabel.textColor = color;
    }
}

- (void)setImage:(nullable UIImage *)image
        forState:(UIControlState)state
{
    ELCallButtonState *buttonState = [self _getButtonStateWithState:state];
    buttonState.image = image;
    
    if (self.state == state) {
        self.imgView.image = image;
    }
}

@end
