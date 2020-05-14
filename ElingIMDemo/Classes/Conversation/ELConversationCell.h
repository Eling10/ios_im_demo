//
//  ELConversationCell.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/21.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import <UIKit/UIKit.h>

@class ELConversation;
@interface ELConversationCell : UITableViewCell

/// 会话数据
@property (strong, nonatomic) ELConversation *model;

@end
