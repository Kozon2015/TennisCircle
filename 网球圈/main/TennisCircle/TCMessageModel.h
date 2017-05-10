//
//  TCMessageModel.h
//  网球圈
//
//  Created by kozon on 2017/5/3.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface TCMessageModel : NSObject
@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *date;
@property (strong, nonatomic) NSString *content;

- (void)initWithObject:(BmobObject *)obj;

@end
