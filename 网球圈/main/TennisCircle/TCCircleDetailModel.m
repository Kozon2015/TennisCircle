//
//  TCCircleDetailModel.m
//  网球圈
//
//  Created by kozon on 2017/4/24.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCCircleDetailModel.h"

@implementation TCCircleDetailModel


-(void)setCellInfo:(BmobObject *)obj {
    self.objectId = [obj objectForKey:@"objectId"];
    self.circleId = [obj objectForKey:@"circleId"];
    self.message = [obj objectForKey:@"content"];
    self.time = [obj objectForKey:@"createdAt"];
}

@end
