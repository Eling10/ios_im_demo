//
//  ELCoreTextView.m
//  ELIMDemo
//
//  Created by 樊小聪 on 2020/4/8.
//  Copyright © 2020 樊小聪. All rights reserved.
//

#import "ELCoreTextView.h"
#import "ELCoreTextConst.h"
#import <XCMacros/XCMacros.h>

@interface ELCoreTextView ()

/// 文本view
@property (nonatomic, strong) UITextView *contentTextView;
/// 所有的可点击链接模型
@property (nonatomic, strong) NSMutableArray<ELCoreTextLink *> *links;
/// 所有结果集
@property (nonatomic, strong) NSMutableArray<ELCoreTextResult *> *allResults;
/// 点击链接回调
@property (nonatomic, copy) void(^clickLinkCallBack)(NSString *linkText);
/// 记录当前手指所在链接模型
@property (nonatomic, strong) ELCoreTextLink *currentTouchLink;
/// 常规链接模型临时存储 (缓存的目的在于,点击时查询相应模型)
@property (nonatomic, strong) NSMutableArray<ELCoreTextLink *> *clickLinksCache;

@end


@implementation ELCoreTextView

#pragma mark - 💤 👀 LazyLoad Method 👀

LazyLoadMethod(clickLinksCache)

- (UITextView *)contentTextView
{
    if (!_contentTextView) {
        _contentTextView                        = [[UITextView alloc] init];
        _contentTextView.textContainerInset     = UIEdgeInsetsMake(1, 1, 1, 1);
        _contentTextView.editable               = NO;
        _contentTextView.userInteractionEnabled = NO;
        _contentTextView.scrollEnabled          = NO;
        _contentTextView.backgroundColor        = [UIColor clearColor];
    }
    return _contentTextView;
}

/// 所有结果集
- (NSMutableArray<ELCoreTextResult *> *)allResults
{
    if (!_allResults) {
        /// 剪切表情,获得表情以及链接结果集
        _allResults = [ELCoreTextResultHelper resultsWithText:self.text];
    }
    return _allResults;
}

- (NSMutableArray<ELCoreTextLink *> *)links
{
    if (!_links) {
        _links = [NSMutableArray array];
        /// 重新生成可点击链接模型,进一步处理,完善包裹区域
        @weakify(self);
        [self.contentTextView.attributedText enumerateAttribute:ELCoreTextLinkAttributeKey inRange:NSMakeRange(0, self.contentTextView.attributedText.length) options:0 usingBlock:^(id  _Nullable value, NSRange range, BOOL * _Nonnull stop) {
            @strongify(self);
            NSString *linkString = value;
            if (!linkString.length) return ;// 过滤空字符
                
            ELCoreTextLink *link = [ELCoreTextLink new];
            link.range           = range;
            link.content         = linkString;
            //链接类型整理
            NSPredicate *predicate   = [NSPredicate predicateWithFormat:@"linkText = %@",linkString];
            NSArray * norResults     = [self.clickLinksCache filteredArrayUsingPredicate:predicate];
            ELCoreTextLink *cachelink = norResults.firstObject;
            if (cachelink) {
                link.linkType = cachelink.linkType;
                switch (link.linkType) {
                    case ELCoreTextLinkTypeWebsite:
                        link.clickBackgroundColor = _websiteColor;
                        link.clickFont = _websiteFont;
                        break;
                    case ELCoreTextLinkTypeEmail:
                        link.clickBackgroundColor = _emailSelectedBackgroundColor;
                        link.clickFont = _emailFont;
                        break;
                    case ELCoreTextLinkTypeMobile:
                        link.clickBackgroundColor = _mobileSelectedBackgroundColor;
                        link.clickFont = _mobileFont;
                        break;
                    default:
                        break;
                }
            }
            self.contentTextView.selectedRange = range;
            NSArray *selectedRects = [self.contentTextView selectionRectsForRange:self.contentTextView.selectedTextRange];
            NSMutableArray *rects  = [NSMutableArray array];
            for (UITextSelectionRect *rect  in selectedRects) {
                if (!rect.rect.size.width || !rect.rect.size.height) continue;
                [rects addObject:rect];
            }
            link.rects = rects;
            [_links addObject:link];
        }];
    }
    return _links;
}

#pragma mark - ⏳ 👀 LifeCycle Method 👀

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        [self addSubview:self.contentTextView];
    }
    return self;
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    self.contentTextView.frame = self.bounds;
}

- (CGSize)sizeThatFits:(CGSize)size
{
    [self setupUI];
    if (!self.contentTextView.attributedText.length) {
        return CGSizeZero;
    }
    return [self.contentTextView sizeThatFits:CGSizeMake(size.width, size.height)];
}


#pragma mark - ✏️ 🖼 SetupUI Method 🖼

- (void)setupUI
{
    // 配置默认参数
    [self setupDefaults];
    // 配置属性
    [self setupAttributes];
}

/**
 *  配置默认参数
 */
- (void)setupDefaults
{
    // 重置状态
    self.allResults = nil;
    self.links = nil;
    self.clickLinksCache = nil;
    
    if (!_text.length) {
        _text = @" ";
        return;
    }
        
    // 文本内容
    if (!_textFont)  { _textFont = [UIFont systemFontOfSize:14.f]; }
    if (!_textColor) { _textColor = [UIColor blackColor]; }
    if ((_emotionSize.width < 0.0001) ||
        (_emotionSize.height < 0.0001 )) {
        _emotionSize = CGSizeMake(_textFont.lineHeight, _textFont.lineHeight);
    }
    if (!_linkedAlpha) { _linkedAlpha = 0.5f; }

    //网址链接
    if (!_websiteFont) { _websiteFont = _textFont; }
    if (!_websiteColor) { _websiteColor = [UIColor blueColor]; }
    if (!_websiteSelectedBackgroundColor) { _websiteSelectedBackgroundColor = [UIColor blueColor]; }
    
    //手机号链接
    if (!_mobileFont) { _mobileFont = _textFont; }
    if (!_mobileColor) { _mobileColor = [UIColor blueColor]; }
    if (!_mobileSelectedBackgroundColor) { _mobileSelectedBackgroundColor = [UIColor blueColor]; }
    
    //邮箱链接
    if (!_emailFont) { _emailFont = _textFont; }
    if (!_emailColor) { _emailColor = [UIColor blueColor]; }
    if (!_emailSelectedBackgroundColor) { _emailSelectedBackgroundColor = [UIColor blueColor]; }
}

/**
 *  设置属性
 */
- (void)setupAttributes
{
    NSMutableAttributedString *attr = [NSMutableAttributedString new];
    @weakify(self);
    [self.allResults enumerateObjectsUsingBlock:^(ELCoreTextResult * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        @strongify(self);
        if (obj.isEmotion) {    // 表情
            NSTextAttachment *attachment = [NSTextAttachment new];
            UIImage *emotionImage = [UIImage imageNamed:obj.string];
            if (emotionImage) {
                attachment.image = emotionImage;
                attachment.bounds = CGRectMake(0, -3, _emotionSize.width, _emotionSize.height);
                NSAttributedString *imageString  = [NSAttributedString attributedStringWithAttachment:attachment];
                [attr appendAttributedString:imageString];
            } else {
                NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:obj.string];
                [self configureNormalAttributes:string];
                [attr appendAttributedString:string];
            }
        } else {    // 非表情
            NSMutableAttributedString *string = [[NSMutableAttributedString alloc] initWithString:obj.string];
            [self configureNormalAttributes:string];
            // 设置链接属性
            for (ELCoreTextLink *link in obj.links) {
                switch (link.linkType) {
                    case ELCoreTextLinkTypeWebsite:
                    {
                        // 网址链接属性
                        [string addAttribute:NSFontAttributeName value:_websiteFont range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:_websiteColor range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:[obj.string substringWithRange:link.range] range:link.range];
                        // 缓存常规链接
                        [self.clickLinksCache addObject:link];
                        break;
                    }
                    case ELCoreTextLinkTypeEmail:
                    {
                        // 邮箱链接设置属性
                        [string addAttribute:NSFontAttributeName value:_emailFont range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:_emailColor range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:[obj.string substringWithRange:link.range] range:link.range];
                        // 缓存常规链接
                        [self.clickLinksCache addObject:link];
                        break;
                    }
                    case ELCoreTextLinkTypeMobile:
                    {
                        // 手机链接设置属性
                        [string addAttribute:NSFontAttributeName value:_mobileFont range:link.range];
                        [string addAttribute:NSForegroundColorAttributeName value:_mobileColor range:link.range];
                        //标记手机链接
                        [string addAttribute:ELCoreTextLinkAttributeKey value:[obj.string substringWithRange:link.range] range:link.range];
                        //缓存常规链接
                        [self.clickLinksCache addObject:link];
                        break;
                    }
                }
            }
            [attr appendAttributedString:string];
        }
    }];
}

#pragma mark - 🔒 👀 Privite Method 👀

/**
 *  配置普通文本的属性
 */
- (void)configureNormalAttributes:(NSMutableAttributedString *)attributeStr
{
    [attributeStr addAttribute:NSFontAttributeName value:_textFont range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSForegroundColorAttributeName value:_textColor range:NSMakeRange(0, attributeStr.length)];
    NSMutableParagraphStyle *paragra = [[NSMutableParagraphStyle alloc] init];
    [paragra setLineBreakMode:NSLineBreakByCharWrapping];
    [paragra setLineSpacing:_lineSpacing];
    [attributeStr addAttribute:NSParagraphStyleAttributeName value:paragra range:NSMakeRange(0, attributeStr.length)];
    [attributeStr addAttribute:NSKernAttributeName value:@(_wordSpacing) range:NSMakeRange(0, attributeStr.length)];
}

/**
 *  返回选中的那个链接
 */
- (ELCoreTextLink *)selectedLink:(CGPoint)touchPoint
{
    ELCoreTextLink *linkModel = nil;
    for (ELCoreTextLink *link in self.links) {
        for (UITextSelectionRect *rect in link.rects) {
            if (CGRectContainsPoint(rect.rect, touchPoint)) {
                linkModel             = link;
                self.currentTouchLink = link; //记录当前点击
                //回调内容
                if (self.delegate && [self.delegate respondsToSelector:@selector(coreTextView:didClickLinkText:linkType:)]) {
                    [self.delegate coreTextView:self didClickLinkText:link.content linkType:link.linkType];
                }
                break;
            }
        }
    }
    return linkModel;
}

/**
 *  选中的动画
 */
- (void)addSelectedAnimation:(ELCoreTextLink *)linkModel
{
    [linkModel.rects enumerateObjectsUsingBlock:^(UITextSelectionRect * _Nonnull rect, NSUInteger idx, BOOL * _Nonnull stop) {
        UIView *coverView            = [[UIView alloc]init];
        coverView.backgroundColor    = linkModel.clickBackgroundColor;
        coverView.alpha              = _linkedAlpha;
        coverView.frame              = rect.rect;
        coverView.tag                = ELCoreTextLinkCoverTag;
        coverView.layer.cornerRadius = 3.f;
        coverView.clipsToBounds      = YES;
        [self insertSubview:coverView atIndex:0];
    }];
}

/**
 *  点击消失的动画
 */
- (void)dismissAnimation
{
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        for (UIView *coverView in self.subviews) {
            if (coverView.tag == ELCoreTextLinkCoverTag) {
                [coverView removeFromSuperview];
            }
        }
    });
}



#pragma mark - 👀 Touch Event 👀 💤

- (void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *touch         = [touches anyObject];
    CGPoint touchPoint     = [touch locationInView:self.contentTextView];
    ELCoreTextLink *linkModel = [self selectedLink:touchPoint];
    [self addSelectedAnimation:linkModel];
}

- (void)touchesEnded:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissAnimation];
}

- (void)touchesMoved:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    UITouch *moveTouch  = [touches anyObject];
    CGPoint movePoint   = [moveTouch locationInView:moveTouch.view];
    
    BOOL isContained    = NO;
    for (UITextSelectionRect *rect in self.currentTouchLink.rects) {
        if (CGRectContainsPoint(rect.rect, movePoint)) {
            isContained = YES;
        }
    }
    if (!isContained) {
     [self dismissAnimation];
    }
}

- (void)touchesCancelled:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self dismissAnimation];
}

#pragma mark - 🔓 👀 Public Method 👀

+ (instancetype)coreTextView
{
    return [[self alloc] init];
}

@end
