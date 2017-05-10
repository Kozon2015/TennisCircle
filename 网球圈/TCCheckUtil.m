//
//  TCCheckUtil.m
//  网球圈
//
//  Created by kozon on 2017/4/14.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCCheckUtil.h"

@implementation TCCheckUtil

+ (BOOL) isStrEmpty:(NSString*)string{
    if (!string || [string isEqualToString:@""]) {
        return YES;
    } else {
        return NO;
    }
}

+ (void) showAlertWithMessage:(NSString*)message delegate:(id)delegate{
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示" message:message delegate:delegate cancelButtonTitle:@"确定" otherButtonTitles:nil, nil];
    [alert show];
}

@end
