//
//  TCFriendDetailTableViewCell.h
//  网球圈
//
//  Created by kozon on 2017/4/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
#import "TCFriendDetailModel.h"

@interface TCFriendDetailTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userImage;

@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *sexLabel;
@property (weak, nonatomic) IBOutlet UILabel *cityLabel;
@property (weak, nonatomic) IBOutlet UILabel *levelLabel;
@property (weak, nonatomic) IBOutlet UILabel *typeLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *messageLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointTimeLabel;
@property (weak, nonatomic) IBOutlet UILabel *appointPlaceLabel;
@property (weak, nonatomic) IBOutlet UILabel *chargeLabel;
@property (weak, nonatomic) IBOutlet UILabel *contactLabel;
@property (weak, nonatomic) IBOutlet UIButton *phoneButton;
@property (weak, nonatomic) IBOutlet UIButton *wechatButton;
@property (strong, nonatomic) NSString *objectId;
@property (strong, nonatomic) NSString *friendId;
@property CGFloat cellHeight;

-(void)setHeadImage:(NSString *)url;

-(void)setCellInfo:(TCFriendDetailModel *)info;

@end
