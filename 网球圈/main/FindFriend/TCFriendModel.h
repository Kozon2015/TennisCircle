//
//  TCFriendModel.h
//  网球圈
//
//  Created by kozon on 2017/5/5.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface TCFriendModel : NSObject

@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *friendId;
@property (strong, nonatomic) NSString *city;
@property (strong, nonatomic) NSString *level;
@property (strong, nonatomic) NSString *type;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *appointTime;
@property (strong, nonatomic) NSString *appointPlace;
@property (strong, nonatomic) NSString *charge;

-(void)setCellInfo:(BmobObject *)obj;

@end
