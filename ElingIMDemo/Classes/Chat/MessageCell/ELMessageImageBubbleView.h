//
//  ELMessageImageBubbleView.h
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/20.
//  Copyright © 2020 樊小聪. All rights reserved.
//

/*
 *  备注：图片消息内容视图 🐾
 */

#import "ELMessageBubbleView.h"

@interface ELMessageImageBubbleView : ELMessageBubbleView

/**
 *  设置图片
 *
 *  @param aLocalPath 本地路径
 *  @param aRemotePath 远程路径
 *  @param aSize 图片尺寸  {"width": "200", "height": "200"}
 */
- (void)setImageWithLocalPath:(NSString *)aLocalPath
                   remotePath:(NSString *)aRemotePath
                      imgSize:(NSDictionary *)aSize;

@end
