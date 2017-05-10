//
//  TCFriendTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/4/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCFriendTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TCFriendTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.userImage.layer.masksToBounds = YES;
    self.userImage.layer.cornerRadius = self.userImage.frame.size.width/2;
    // Initialization code
}

-(void)setHeadImage:(NSString *)url {
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo:(TCFriendModel *)info {
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
    
    CGRect tmpRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - 16, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.messageLabel.font,NSFontAttributeName, nil] context:nil];
    
    if (tmpRect.size.height <= 16) {
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, CGRectGetMaxY(self.userImage.frame) + 8, self.bounds.size.width - 16, 16);
        self.chargeLabel.frame = CGRectMake(self.chargeLabel.frame.origin.x, self.messageLabel.frame.origin.y + 16 + self.appointTimeLabel.frame.size.height + self.appointPlaceLabel.frame.size.height + 24, self.chargeLabel.frame.size.width, self.chargeLabel.frame.size.height);
        self.cellHeight = CGRectGetMaxY(self.chargeLabel.frame) + 8;
    } else {
        self.messageLabel.numberOfLines = 2;
        self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.messageLabel.frame = CGRectMake(self.messageLabel.frame.origin.x, CGRectGetMaxY(self.userImage.frame) + 8, self.bounds.size.width - 16, 16);
        self.chargeLabel.frame = CGRectMake(self.chargeLabel.frame.origin.x, self.messageLabel.frame.origin.y + 32 + self.appointTimeLabel.frame.size.height + self.appointPlaceLabel.frame.size.height + 24, self.chargeLabel.frame.size.width, self.chargeLabel.frame.size.height);
        self.cellHeight = CGRectGetMaxY(self.chargeLabel.frame) + 8;
    }
}

@end
