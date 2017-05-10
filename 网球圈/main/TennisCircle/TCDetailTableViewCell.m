//
//  TCDetailTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/3/29.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BmobSDK/Bmob.h>

@implementation TCDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image.layer.masksToBounds = YES;
    self.image.layer.cornerRadius = self.image.frame.size.width/2;
    // Initialization code
}

-(void)setHeadImage:(NSString *)url {
    [self.image sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo:(TCCircleDetailModel *)info {
    self.objectId = info.objectId;
    self.circleId = info.circleId;
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCUserInfo" ];
    [query whereKey:@"userId" equalTo:self.circleId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            //进行错误处理
            NSLog(@"错误信息：%@",error);
        }else{
            if (array.count > 0) {
                BmobObject *object = array[0];
                [self setHeadImage:[object objectForKey:@"image"]];
                self.nameLabel.text = [object objectForKey:@"name"];
                self.placeLabel.text = [object objectForKey:@"city"];
            }
        }
    }];
    self.messageLabel.text = info.message;
    self.timeLabel.text = info.time;
    CGRect tmpRect = [self.messageLabel.text boundingRectWithSize:CGSizeMake(self.bounds.size.width - CGRectGetMaxX(self.image.frame) - 16, 1000) options:NSStringDrawingUsesLineFragmentOrigin attributes:[NSDictionary dictionaryWithObjectsAndKeys:self.messageLabel.font,NSFontAttributeName, nil] context:nil];
    if (tmpRect.size.height <= 14) {
        self.cellHeight = self.messageLabel.frame.origin.y + 14 + self.timeLabel.frame.size.height + 16;
    } else if (tmpRect.size.height <= 28) {
        self.cellHeight = self.messageLabel.frame.origin.y + 28 + self.timeLabel.frame.size.height + 16;
    } else if (tmpRect.size.height <= 42) {
        self.cellHeight = self.messageLabel.frame.origin.y + 42 + self.timeLabel.frame.size.height + 16;
    } else {
        self.messageLabel.numberOfLines = 4;
        self.messageLabel.lineBreakMode = NSLineBreakByTruncatingTail;
        self.cellHeight = self.messageLabel.frame.origin.y + 56 + self.timeLabel.frame.size.height + 16;
    }
}

@end
