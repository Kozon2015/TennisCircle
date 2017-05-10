//
//  TCInformationViewController.h
//  网球圈
//
//  Created by kozon on 2017/3/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <BmobSDK/Bmob.h>
#import <BmobSDK/BmobFile.h>

@interface TCInformationViewController : UIViewController

@property (strong, nonatomic) NSString *userId;
@property (strong, nonatomic) NSString *username;
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UITextField *nameLabel;
@property (weak, nonatomic) IBOutlet UIButton *sexButton;
@property (weak, nonatomic) IBOutlet UIButton *ageButton;
@property (weak, nonatomic) IBOutlet UIButton *ballAgeButton;
@property (weak, nonatomic) IBOutlet UIButton *cityButton;
@property (weak, nonatomic) IBOutlet UIButton *summitButton;

@end
