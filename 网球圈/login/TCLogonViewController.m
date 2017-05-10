//
//  TCLogonViewController.m
//  网球圈
//
//  Created by kozon on 2017/2/26.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCLogonViewController.h"
#import "TCInformationViewController.h"
#import "TCRegisterViewController.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "AFNetworking.h"
#import "WXApi.h"
#import <BmobSDK/Bmob.h>
#import "TCCheckUtil.h"


@interface TCLogonViewController ()<TencentSessionDelegate,UITextFieldDelegate> {
    TencentOAuth *tencentOAuth;
    //NSArray *permissions;
}

@property (weak, nonatomic) IBOutlet UITextField *accountTf;
@property (weak, nonatomic) IBOutlet UITextField *passwordTf;
@property (weak, nonatomic) IBOutlet UIButton *logonBtn;
@property (weak, nonatomic) IBOutlet UIButton *registerBtn;
@property (weak, nonatomic) IBOutlet UIButton *qqBtn;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;

@end

@implementation TCLogonViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.accountTf.layer.cornerRadius = 3.0;
    self.passwordTf.layer.cornerRadius = 3.0;
    self.logonBtn.layer.cornerRadius = 3.0;
    self.registerBtn.layer.cornerRadius = 3.0;
    self.qqBtn.layer.cornerRadius = self.qqBtn.frame.size.width/2;
    self.wechatBtn.layer.cornerRadius = self.wechatBtn.frame.size.width/2;
    self.indicator.hidden = YES;
    [self.indicator startAnimating];
    self.accountTf.tintColor = [UIColor lightGrayColor];
    self.passwordTf.tintColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    //初始化TencentOAuth 对象 appid来自应用宝创建的应用， deletegate设置为self  一定记得实现代理方法
    //tencentOAuth=[[TencentOAuth alloc]initWithAppId:@"1104617535" andDelegate:self];
    
    //设置需要的权限列表，此处尽量使用什么取什么。
    //permissions= [NSArray arrayWithObjects:@"get_user_info", @"get_simple_userinfo", @"add_t", nil];
    // Do any additional setup after loading the view.
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.accountTf resignFirstResponder];
    [self.passwordTf resignFirstResponder];
}

- (IBAction)loginBtn:(UIButton *)sender {
    if ([TCCheckUtil isStrEmpty:self.accountTf.text]) {
        [TCCheckUtil showAlertWithMessage:@"账号不能为空" delegate:self];
        return;
    } else if ([TCCheckUtil isStrEmpty:self.passwordTf.text]) {
        [TCCheckUtil showAlertWithMessage:@"密码不能为空" delegate:self];
        return;
    } else {
        self.indicator.hidden = NO;
        [BmobUser loginWithUsernameInBackground:self.accountTf.text password:self.passwordTf.text block:^(BmobUser *user, NSError *error) {
            if (user) {
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"登录成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //跳转
                    UIStoryboard *mainStoryBoard = [UIStoryboard storyboardWithName:@"Logon" bundle:nil];
                    UITabBarController *mainView = [mainStoryBoard instantiateViewControllerWithIdentifier:@"mainView"];
                    [self presentViewController:mainView animated:YES completion:nil];
                }];
                //添加按钮
                [alert addAction:ok];
                //以modal的方式来弹出
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                self.indicator.hidden = YES;
                if (error.code == 101){
                    [TCCheckUtil showAlertWithMessage:@"账号或密码不对，请重新输入！" delegate:self];
                } else if (error.code == 20002) {
                    [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
                } else {
                    [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
                }
            }
        }];
    }
}

- (IBAction)registerBtn:(UIButton *)sender {
    NSLog(@"abc");
    TCRegisterViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCRegisterViewController"];
    [self presentViewController:TCIVC animated:YES completion:nil];
}

- (IBAction)QQ:(id)sender {
    if ([TencentOAuth iphoneQQInstalled]) {
        //注册
        tencentOAuth = [[TencentOAuth alloc] initWithAppId:@"1104720526" andDelegate:self];
        //授权
        NSArray *permissions = [NSArray arrayWithObjects:kOPEN_PERMISSION_GET_INFO,nil];
        [tencentOAuth authorize:permissions inSafari:NO];
        //获取用户信息
        [tencentOAuth getUserInfo];
    } else {
        [TCCheckUtil showAlertWithMessage:@"没有安装qq客户端" delegate:self];
    }
    
}

#pragma mark -- TencentSessionDelegate
//登陆完成调用
- (void)tencentDidLogin {
    [TCCheckUtil showAlertWithMessage:@"登录完成" delegate:self];
    if (tencentOAuth.accessToken && 0 != [tencentOAuth.accessToken length]) {
        //  记录登录用户的OpenID、Token以及过期时间
        NSString *accessToken = tencentOAuth.accessToken;
        NSString *uid = tencentOAuth.openId;
        NSDate *expiresDate = tencentOAuth.expirationDate;
        NSLog(@"acessToken:%@",accessToken);
        NSLog(@"UserId:%@",uid);
        NSLog(@"expiresDate:%@",expiresDate);
        NSDictionary *dic = @{@"access_token":accessToken,@"uid":uid,@"expirationDate":expiresDate};
        
        //通过授权信息注册登录
        [BmobUser loginInBackgroundWithAuthorDictionary:dic platform:BmobSNSPlatformQQ block:^(BmobUser *user, NSError *error) {
            if (error) {
                NSLog(@"qq login error:%@",error);
            } else if (user){
                NSLog(@"user objectid is :%@",user.objectId);
                //跳转
                TCInformationViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCInformationViewController"];
                [self presentViewController:TCIVC animated:YES completion:nil];
            }
        }];
        
    } else {
        [TCCheckUtil showAlertWithMessage:@"登录不成功 没有获取accesstoken" delegate:self];
    }
}

//非网络错误导致登录失败：
-(void)tencentDidNotLogin:(BOOL)cancelled {
    NSLog(@"tencentDidNotLogin");
    if (cancelled) {
        [TCCheckUtil showAlertWithMessage:@"用户取消登录" delegate:self];
    } else {
        [TCCheckUtil showAlertWithMessage:@"登录失败" delegate:self];
    }
}
// 网络错误导致登录失败：
-(void)tencentDidNotNetWork {
    NSLog(@"tencentDidNotNetWork");
    [TCCheckUtil showAlertWithMessage:@"无网络连接，请设置网络" delegate:self];
}

-(void)getUserInfoResponse:(APIResponse *)response {
    NSLog(@"respons:%@",response.jsonResponse);
}

- (IBAction)wechat:(id)sender {
    if ([WXApi isWXAppInstalled]) {
        SendAuthReq *req = [[SendAuthReq alloc] init];
        req.scope = @"snsapi_userinfo";
        req.state = @"App";
        [WXApi sendReq:req];
        TCInformationViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCInformationViewController"];
        [self presentViewController:TCIVC animated:YES completion:nil];
    }
    else {
        [TCCheckUtil showAlertWithMessage:@"没有安装微信客户端" delegate:self];
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
