//
//  TCFriendDetailTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/4/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCFriendDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TCFriendDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2;
    // Initialization code
}

-(void)setHeadImage:(NSString *)url {
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo:(TCFriendDetailModel *)info {
    self.objectId = info.objectId;
    self.friendId = info.friendId;
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCUserInfo" ];
    [query whereKey:@"userId" equalTo:self.friendId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
            NSLog(@"错误信息：%@",error);
        }else{
            if (array.count > 0) {
                BmobObject *object = array[0];
                [self setHeadImage:[object objectForKey:@"image"]];
                self.nameLabel.text = [object objectForKey:@"name"];
                self.sexLabel.text = [object objectForKey:@"sex"];
            }
        }
    }];
    self.cityLabel.text = info.city;
    self.levelLabel.text = info.level;
    self.typeLabel.text = info.type;
    self.timeLabel.text = info.time;
    self.messageLabel.text = info.message;
    self.appointTimeLabel.text = info.appointTime;
    self.appointPlaceLabel.text = info.appointPlace;
    self.chargeLabel.text = info.charge;
    [self.phoneButton setTitle:info.phone forState:UIControlStateNormal];
    [self.wechatButton setTitle:info.wechat forState:UIControlStateNormal];
}

@end
