//
//  TCCircleDetailModel.h
//  网球圈
//
//  Created by kozon on 2017/4/24.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <BmobSDK/Bmob.h>

@interface TCCircleDetailModel : NSObject

@property (strong, nonatomic) NSString *message;
@property (strong, nonatomic) NSString *time;
@property (strong, nonatomic) NSString *circleId;
@property (strong, nonatomic) NSString *objectId;

-(void)setCellInfo:(BmobObject *)obj;

@end
