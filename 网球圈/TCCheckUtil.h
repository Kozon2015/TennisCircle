//
//  TCCheckUtil.h
//  网球圈
//
//  Created by kozon on 2017/4/14.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface TCCheckUtil : NSObject

+ (BOOL) isStrEmpty:(NSString*)string;

+ (void) showAlertWithMessage:(NSString*)message delegate:(id)delegate;

@end
