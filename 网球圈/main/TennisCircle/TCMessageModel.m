//
//  TCMessageModel.m
//  网球圈
//
//  Created by kozon on 2017/5/3.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMessageModel.h"

@implementation TCMessageModel

- (void)initWithObject:(BmobObject *)obj {
    self.userId = [obj objectForKey:@"userId"];
    self.messageId = [obj objectForKey:@"messageId"];
    self.content = [obj objectForKey:@"message"];
    self.date = [obj objectForKey:@"createdAt"];
}

@end
