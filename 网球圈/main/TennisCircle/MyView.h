//
//  MyView.h
//  Bravo
//
//  Created by Albert on 16/8/20.
//  Copyright © 2016年 koali. All rights reserved.
//

#import <UIKit/UIKit.h>
//! Project version number for SZTextView.
FOUNDATION_EXPORT double SZTextViewVersionNumber;

//! Project version string for SZTextView.
FOUNDATION_EXPORT const unsigned char SZTextViewVersionString[];


IB_DESIGNABLE
@interface MyView : UITextView
@property (copy, nonatomic) IBInspectable NSString *placeholder;
@property (nonatomic) IBInspectable double fadeTime;
@property (copy, nonatomic) NSAttributedString *attributedPlaceholder;
@property (retain, nonatomic) UIColor *placeholderTextColor UI_APPEARANCE_SELECTOR;

@end
