//
//  TCLeaveMessageViewController.m
//  网球圈
//
//  Created by kozon on 2017/5/4.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCLeaveMessageViewController.h"
#import "TCCheckUtil.h"
#import <BmobSDK/Bmob.h>

@interface TCLeaveMessageViewController ()<UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UIBarButtonItem *leaveBarButton;
@property (weak, nonatomic) IBOutlet UITextView *reviewTextView;
@property UILabel *placeholderLabel;

@end

@implementation TCLeaveMessageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.leaveBarButton.enabled = NO;
    
    _placeholderLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 5, CGRectGetWidth(self.self.reviewTextView.frame), 20)];
    _placeholderLabel.backgroundColor = [UIColor clearColor];
    _placeholderLabel.textColor = [UIColor colorWithRed:200.0/255.0 green:199.0/255.0 blue:205.0/255.0 alpha:1.0];
    _placeholderLabel.text = @"写留言...";
    _placeholderLabel.font = self.reviewTextView.font;
    [self.reviewTextView addSubview:_placeholderLabel];
    self.reviewTextView.tintColor = [UIColor lightGrayColor];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.reviewTextView.delegate = self;
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view, typically from a nib.
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.reviewTextView resignFirstResponder];
}

- (void)textDidChanged:(NSNotification *)notification {
    if (self.reviewTextView.text.length!=0) {
        self.leaveBarButton.enabled = YES;
    }
    else {
        self.leaveBarButton.enabled = NO;
    }
}

-(void)textViewDidChange:(UITextView *)textView {

    if (self.reviewTextView.text.length == 0) {
        _placeholderLabel.text = @"写留言...";
    }else {
        _placeholderLabel.text = @"";
    }
}

- (void)textViewDidBeginEditing:(UITextView *)textView{
    if (textView.text.length == 0) {
        _placeholderLabel.text = @"写留言...";
    }
}

- (IBAction)leaveMessage:(id)sender {
    [self.reviewTextView resignFirstResponder];
    BmobUser *user = [BmobUser currentUser];
    BmobObject *obj = [BmobObject objectWithClassName:@"TCMessage"];
    [obj setObject:self.messageId forKey:@"messageId"];
    [obj setObject:user.objectId forKey:@"userId"];
    [obj setObject:self.reviewTextView.text forKey:@"message"];
    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"留言成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                //跳转
                [self.navigationController popViewControllerAnimated:YES];
            }];
            //添加按钮
            [alert addAction:ok];
            //以modal的方式来弹出
            [self presentViewController:alert animated:YES completion:nil];
        } else if (error.code == 20002) {
            [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
        } else {
            [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
        }
    }];
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
