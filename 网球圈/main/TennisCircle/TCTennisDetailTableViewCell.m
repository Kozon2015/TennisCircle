//
//  TCTennisDetailTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/3/30.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCTennisDetailTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BmobSDK/Bmob.h>

@implementation TCTennisDetailTableViewCell

- (void)awakeFromNib {
    [super awakeFromNib];
    self.image.layer.masksToBounds = YES;
    self.image.layer.cornerRadius = self.image.frame.size.width/2;
    // Initialization code
}

-(void)setHeadImage:(NSString *)url {
    [self.image sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo:(TCTennisDetailModel *)info {
    self.image.layer.cornerRadius = self.image.frame.size.width/2;
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
}

@end
