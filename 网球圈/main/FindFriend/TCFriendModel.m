//
//  TCFriendModel.m
//  网球圈
//
//  Created by kozon on 2017/5/5.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCFriendModel.h"

@implementation TCFriendModel

-(void)setCellInfo:(BmobObject *)obj {
    self.objectId = [obj objectForKey:@"objectId"];
    self.friendId = [obj objectForKey:@"friendId"];
    self.city = [obj objectForKey:@"city"];
    self.level = [obj objectForKey:@"level"];
    self.type = [obj objectForKey:@"playingstyle"];
    self.time = [obj objectForKey:@"createdAt"];
    self.message = [obj objectForKey:@"content"];
    self.appointTime = [obj objectForKey:@"ballTime"];
    self.appointPlace = [obj objectForKey:@"ballPlace"];
    self.charge = [obj objectForKey:@"cost"];
}

@end
