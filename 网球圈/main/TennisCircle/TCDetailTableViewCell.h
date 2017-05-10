//
//  TCDetailTableViewCell.h
//  网球圈
//
//  Created by kozon on 2017/3/29.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
#import "TCCircleDetailModel.h"

@interface TCDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *image;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (strong, nonatomic) NSString *circleId;
@property (strong, nonatomic) NSString *objectId;

@property CGFloat cellHeight;

-(void)setHeadImage:(NSString *)url;

-(void)setCellInfo:(TCCircleDetailModel *)info;

@end
