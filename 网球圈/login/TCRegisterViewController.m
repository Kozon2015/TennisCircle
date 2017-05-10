//
//  TCRegisterViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/14.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCRegisterViewController.h"
#import "TCCheckUtil.h"
#import "TCLogonViewController.h"
#import "TCInformationViewController.h"


@interface TCRegisterViewController ()<UITextFieldDelegate>

@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UITextField *verifyPasswordTf;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property (strong, nonatomic) NSString *userId;
@end

@implementation TCRegisterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountTf.layer.cornerRadius = 3.0;
    self.passwordTf.layer.cornerRadius = 3.0;
    self.verifyPasswordTf.layer.cornerRadius = 3.0;
    self.registerBtn.layer.cornerRadius = 3.0;
    self.indicator.hidden = YES;
    [self.indicator startAnimating];
    self.accountTf.tintColor = [UIColor lightGrayColor];
    self.passwordTf.tintColor = [UIColor lightGrayColor];
    self.verifyPasswordTf.tintColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view.
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.accountTf resignFirstResponder];
    [self.passwordTf resignFirstResponder];
    [self.verifyPasswordTf resignFirstResponder];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)registerBtn:(UIButton *)sender {
    if ([TCCheckUtil isStrEmpty:self.accountTf.text] ||
        [TCCheckUtil isStrEmpty:self.passwordTf.text]||
        [TCCheckUtil isStrEmpty:self.verifyPasswordTf.text]) {
        [TCCheckUtil showAlertWithMessage:@"输入不能为空" delegate:self];
    } else if (![self.passwordTf.text isEqualToString:self.verifyPasswordTf.text]){
        [TCCheckUtil showAlertWithMessage:@"两次输入密码不相同" delegate:self];
    } else if (self.accountTf.text.length < 7) {
        [TCCheckUtil showAlertWithMessage:@"请输入至少7位数字！" delegate:self];
        
    } else if (self.passwordTf.text.length < 6) {
        [TCCheckUtil showAlertWithMessage:@"请输入至少6个字符！" delegate:self];
    } else {
        self.indicator.hidden = NO;
        BmobUser *user = [[BmobUser alloc] init];
        user.username = self.accountTf.text;
        user.password = self.passwordTf.text;
        [user signUpInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册成功,请继续完善个人资料！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //跳转
                    TCInformationViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCInformationViewController"];
                    TCIVC.userId = user.objectId;
                    TCIVC.username = user.username;
                    [self presentViewController:TCIVC animated:YES completion:nil];
                }];
                //添加按钮
                [alert addAction:ok];
                //以modal的方式来弹出
                [self presentViewController:alert animated:YES completion:nil];
                
            } else {
                self.indicator.hidden = YES;
                if (error.code == 202) {
                    [TCCheckUtil showAlertWithMessage:@"该账号已被注册，请重新注册一个！" delegate:self];
                } else if (error.code == 20002) {
                    [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
                } else {
                    [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
                }
                
            }
        }];
    }
}

- (IBAction)logonBtn:(UIButton *)sender {
    TCLogonViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCLogonViewController"];
    [self presentViewController:TCIVC animated:YES completion:nil];
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
