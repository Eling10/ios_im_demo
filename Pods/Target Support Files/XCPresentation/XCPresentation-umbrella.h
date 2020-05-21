#ifdef __OBJC__
#import <UIKit/UIKit.h>
#else
#ifndef FOUNDATION_EXPORT
#if defined(__cplusplus)
#define FOUNDATION_EXPORT extern "C"
#else
#define FOUNDATION_EXPORT extern
#endif
#endif
#endif

#import "XCPresentationAlertAnimation.h"
#import "XCPresentationAnimation.h"
#import "XCPresentationBubbleAnimation.h"
#import "XCPresentationExplodeAnimation.h"
#import "XCPresentationPanAnimation.h"
#import "XCPresentationScaleAnimation.h"
#import "XCPresentation.h"

FOUNDATION_EXPORT double XCPresentationVersionNumber;
FOUNDATION_EXPORT const unsigned char XCPresentationVersionString[];

