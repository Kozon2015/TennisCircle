//
//  TCMessageTableViewCell.h
//  网球圈
//
//  Created by kozon on 2017/5/3.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "TCMessageModel.h"

@interface TCMessageTableViewCell : UITableViewCell

@property (strong, nonatomic) TCMessageModel *message;
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UILabel *dateLabel;
@property (weak, nonatomic) IBOutlet UILabel *contentLabel;
@property (strong, nonatomic) NSString *messageId;
@property (strong, nonatomic) NSString *userId;
-(void)setCellInfo:(TCMessageModel *)info;

@end
