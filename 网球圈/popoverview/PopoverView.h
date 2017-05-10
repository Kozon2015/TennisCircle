//
//  PopoverView.h
//  B-smart
//
//  Created by Albert on 15/8/10.
//  Copyright (c) 2015年 Koali Apps. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface PopoverView : UIView

-(id)initWithPoint:(CGPoint)point titles:(NSArray *)titles;
-(void)show;
-(void)dismiss;
-(void)dismiss:(BOOL)animated;

@property (nonatomic, copy) UIColor *borderColor;
@property (nonatomic, copy) void (^selectRowAtIndex)(NSInteger index);

@end
