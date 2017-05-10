//
//  TCMatchListTableViewCell.m
//  网球圈
//
//  Created by kozon on 2017/4/20.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMatchListTableViewCell.h"
#import <SDWebImage/UIImageView+WebCache.h>

@implementation TCMatchListTableViewCell

-(void)setHeadImage:(NSString *)url {
    [self.imageLabel sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)setCellInfo:(BmobObject *)obj {
    self.objectId = [obj objectForKey:@"objectId"];
    self.matchId = [obj objectForKey:@"matchId"];
    [self setHeadImage:[obj objectForKey:@"image"]];
    self.nameLabel.text = [obj objectForKey:@"title"];
    self.placeLabel.text = [obj objectForKey:@"place"];
    self.timeLabel.text = [obj objectForKey:@"matchTime"];
    
}


@end
