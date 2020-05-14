//
//  NSString+Emoji.m
//  ELKeyboard
//
//  Created by 樊小聪 on 2020/4/16.
//  Copyright © 2020 Parkin. All rights reserved.
//

#import "NSString+Emoji.h"

#define EmojiCodeToSymbol(c) ((((0x808080F0 | (c & 0x3F000) >> 4) | (c & 0xFC0) << 10) | (c & 0x1C0000) << 18) | (c & 0x3F) << 24)


@implementation NSString (Emoji)

- (NSString *)emoji
{
    char *charCode = (char *)self.UTF8String;
    long intCode = strtol(charCode, NULL, 16);
    
    int symbol = EmojiCodeToSymbol((int)intCode);
    NSString *string = [[NSString alloc] initWithBytes:&symbol length:sizeof(symbol) encoding:NSUTF8StringEncoding];
    if (string == nil) { // 新版Emoji
        string = [NSString stringWithFormat:@"%C", (unichar)intCode];
    }
    return string;
}

@end
