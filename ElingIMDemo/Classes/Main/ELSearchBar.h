//
//  ELSearchBar.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/27.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：搜索框 🐾
 */

#import <UIKit/UIKit.h>


@class ELSearchBar;
@protocol ELSearchBarDelegate <NSObject>

@optional
/// 开始编辑
- (void)searchBarShouldBeginEditing:(ELSearchBar *)searchBar;
/// 点击了取消按钮
- (void)searchBarCancelButtonAction:(ELSearchBar *)searchBar;
/// 点击了搜索
- (void)searchBarSearchButtonClicked:(NSString *)aString;
/// 文本发送改变
- (void)searchTextDidChangeWithString:(NSString *)aString;

@end


@interface ELSearchBar : UIView

/// 占位文字
@property (copy, nonatomic) NSString *placeholder;
@property (nonatomic, strong, readonly) UITextField *textField;
@property (nonatomic, weak) id<ELSearchBarDelegate> delegate;

@end
