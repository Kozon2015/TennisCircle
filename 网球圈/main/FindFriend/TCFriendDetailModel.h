//
//  TCFriendDetailModel.h
//  网球圈
//
//  Created by kozon on 2017/4/24.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface TCFriendDetailModel : NSObject

@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *level;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *appointTime;
@property (strong, nonatomic) NSString *appointPlace;
@property (strong, nonatomic) NSString *charge;
@property (strong, nonatomic) NSString *contact;
@property (strong, nonatomic) NSString *phone;
@property (strong, nonatomic) NSString *wechat;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *friendId;

-(void)setCellInfo:(BmobObject *)obj;

@end
