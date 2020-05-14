//
//  ELCallButton.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/23.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface ELCallButtonState : NSObject
@property (nonatomic, strong) NSString *title;
@property (nonatomic, strong) UIColor *titleColor;
@property (nonatomic, strong) UIImage *image;
@end


@interface ELCallButton : UIControl

@property (nonatomic, strong) UILabel *titleLabel;

- (instancetype)initWithTitle:(NSString *)aTitle
                       target:(id)aTarget
                       action:(SEL)aAction;

- (void)setTitle:(NSString *)title
        forState:(UIControlState)state;

- (void)setTitleColor:(UIColor *)color
             forState:(UIControlState)state;

- (void)setImage:(UIImage *)image
        forState:(UIControlState)state;

@end
