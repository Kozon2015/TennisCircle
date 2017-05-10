//
//  TCAlterPasswordViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/25.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCAlterPasswordViewController.h"
#import <BmobSDK/Bmob.h>
#import "TCCheckUtil.h"

@interface TCAlterPasswordViewController ()
@property (weak, nonatomic) IBOutlet UITextField *oldPasswordTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UITextField *confirmTf;
@property (weak, nonatomic) IBOutlet UIButton *confirmBtn;

@end

@implementation TCAlterPasswordViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.oldPasswordTf.layer.cornerRadius = 3.0;
    self.passwordTf.layer.cornerRadius = 3.0;
    self.confirmTf.layer.cornerRadius = 3.0;
    self.confirmBtn.layer.cornerRadius = 3.0;
    self.oldPasswordTf.tintColor = [UIColor lightGrayColor];
    self.passwordTf.tintColor = [UIColor lightGrayColor];
    self.confirmTf.tintColor = [UIColor lightGrayColor];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view.
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.oldPasswordTf resignFirstResponder];
    [self.passwordTf resignFirstResponder];
    [self.confirmTf resignFirstResponder];

}

- (IBAction)alter:(UIButton *)sender {
    if ([TCCheckUtil isStrEmpty:self.oldPasswordTf.text] ||
        [TCCheckUtil isStrEmpty:self.passwordTf.text]||
        [TCCheckUtil isStrEmpty:self.confirmTf.text]) {
        [TCCheckUtil showAlertWithMessage:@"输入不能为空" delegate:self];
    } else if (![self.passwordTf.text isEqualToString:self.confirmTf.text]){
        [TCCheckUtil showAlertWithMessage:@"两次输入密码不相同" delegate:self];
    } else if (self.passwordTf.text.length < 6) {
        [TCCheckUtil showAlertWithMessage:@"请输入至少6个字符！" delegate:self];
    } else {
        BmobUser *user = [BmobUser currentUser];
        [user updateCurrentUserPasswordWithOldPassword:self.oldPasswordTf.text newPassword:self.passwordTf.text block:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                BmobObject *obj = [BmobObject objectWithClassName:@"TCPassword"];
                [obj setObject:self.oldPasswordTf.text forKey:@"oldPassword"];
                [obj setObject:self.passwordTf.text forKey:@"newPassword"];
                [obj saveInBackground];
                //用新密码登录
                [BmobUser loginInbackgroundWithAccount:user.username andPassword:self.passwordTf.text block:^(BmobUser *user, NSError *error) {
                    if (error) {
                        NSLog(@"login error:%@",error);
                    } else {
                        NSLog(@"user:%@",user);
                        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"密码修改成功,请重新登录！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                            //跳转
                            UIStoryboard *storyBoard = [UIStoryboard storyboardWithName:@"Main" bundle:nil];
                            UIViewController *loginView = [storyBoard instantiateViewControllerWithIdentifier:@"TCLogonViewController"];
                            //[NSUserDefaults deleteAllUserDefaults];
                            //[NSUserDefaults setUserLoginStatus:NO];
                            [self presentViewController:loginView animated:YES completion:nil];
                        }];
                        //添加按钮
                        [alert addAction:ok];
                        //以modal的方式来弹出
                        [self presentViewController:alert animated:YES completion:nil];
                    }
                }];
            } else {
                if (error.code == 210){
                    [TCCheckUtil showAlertWithMessage:@"旧密码不正确！" delegate:self];
                } else if (error.code == 20002) {
                    [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
                } else {
                    [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
                }
            }
        }];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
