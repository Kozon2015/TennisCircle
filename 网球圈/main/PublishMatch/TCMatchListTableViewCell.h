//
//  TCMatchListTableViewCell.h
//  网球圈
//
//  Created by kozon on 2017/4/20.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>

@interface TCMatchListTableViewCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *nameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *imageLabel;
@property (weak, nonatomic) IBOutlet UILabel *timeLabel;
@property (weak, nonatomic) IBOutlet UILabel *placeLabel;
@property (strong, nonatomic) NSString *matchId;
@property (strong, nonatomic) NSString *objectId;
-(void)setCellInfo:(BmobObject *)obj;
@end
