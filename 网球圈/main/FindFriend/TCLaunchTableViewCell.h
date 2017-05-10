//
//  TCLaunchTableViewCell.h
//  网球圈
//
//  Created by kozon on 2017/4/21.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>

@interface TCLaunchTableViewCell : UITableViewCell

@property (weak, nonatomic) IBOutlet UIImageView *userIcon;
-(void)setCellInfo;

@end
