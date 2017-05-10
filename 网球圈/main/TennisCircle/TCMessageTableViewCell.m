//
//  TCMessageTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/5/3.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMessageTableViewCell.h"
#import <BmobSDK/Bmob.h>


@implementation TCMessageTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    // Initialization code
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated {
    [super setSelected:selected animated:animated];

    // Configure the view for the selected state
}

-(void)setCellInfo:(TCMessageModel *)info {
    self.userId = info.userId;
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCUserInfo" ];
    [query whereKey:@"userId" equalTo:self.userId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
            NSLog(@"错误信息：%@",error);
        }else{
            if (array.count > 0) {
                BmobObject *object = array[0];
                self.nameLabel.text = [object objectForKey:@"name"];
            }
        }
    }];
    self.contentLabel.text = info.content;
    self.dateLabel.text = info.date;
}

@end
