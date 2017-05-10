//
//  TCLaunchTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/4/21.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCLaunchTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TCLaunchTableViewCell

-(void)setHeadImage:(NSString *)url {
    [self.userIcon sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo {
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCUserInfo" ];
    [query whereKey:@"userId" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
            NSLog(@"错误信息：%@",error);
        }else{
            if (array.count > 0) {
                BmobObject *object = array[0];
                [self setHeadImage:[object objectForKey:@"image"]];
            }
        }
    }];
}

@end
