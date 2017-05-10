//
//  TCMatchDetailTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/1.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMatchDetailTableViewController.h"
#import <SDWebImage/UIImageView+WebCache.h>
#import <BmobSDK/Bmob.h>
#import "TCCheckUtil.h"

@interface TCMatchDetailTableViewController ()

@property (weak, nonatomic) IBOutlet UILabel *titleTf;
@property (weak, nonatomic) IBOutlet UILabel *cityTf;
@property (weak, nonatomic) IBOutlet UIImageView *matchImage;
@property (weak, nonatomic) IBOutlet UILabel *kindTf;
@property (weak, nonatomic) IBOutlet UILabel *institutionTf;
@property (weak, nonatomic) IBOutlet UILabel *placeTf;
@property (weak, nonatomic) IBOutlet UILabel *matchTimeTf;
@property (weak, nonatomic) IBOutlet UILabel *limitTf;
@property (weak, nonatomic) IBOutlet UILabel *demandTf;
@property (weak, nonatomic) IBOutlet UILabel *costTf;
@property (weak, nonatomic) IBOutlet UIButton *wechatBtn;
@property (weak, nonatomic) IBOutlet UIButton *alipayBtn;
@property (weak, nonatomic) IBOutlet UILabel *deadlineTf;
@property (weak, nonatomic) IBOutlet UILabel *awardTf;
@property (weak, nonatomic) IBOutlet UILabel *organizerLb;


@end

@implementation TCMatchDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCMatch"];
    [query getObjectInBackgroundWithId:self.objectId block:^(BmobObject *object,NSError *error){
        if (error) {
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            if (object) {
                self.matchId = [object objectForKey:@"matchId"];
                [self setHeadImage:[object objectForKey:@"image"]];
                self.titleTf.text = [object objectForKey:@"title"];
                self.kindTf.text = [object objectForKey:@"kind"];
                self.institutionTf.text = [object objectForKey:@"institution"];
                self.cityTf.text = [object objectForKey:@"city"];
                self.placeTf.text = [object objectForKey:@"place"];
                self.matchTimeTf.text = [object objectForKey:@"matchTime"];
                self.limitTf.text = [object objectForKey:@"limit"];
                self.demandTf.text = [object objectForKey:@"demand"];
                self.costTf.text = [object objectForKey:@"cost"];
                [self.wechatBtn setTitle:[object objectForKey:@"wechat"] forState:UIControlStateNormal];
                [self.alipayBtn setTitle:[object objectForKey:@"alipay"] forState:UIControlStateNormal];
                self.deadlineTf.text = [object objectForKey:@"deadline"];
                self.awardTf.text = [object objectForKey:@"award"];
                BmobQuery *nameQuery = [BmobQuery queryWithClassName:@"TCUserInfo" ];
                [nameQuery whereKey:@"userId" equalTo:self.matchId];
                [nameQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
                    if (error){
                        //进行错误处理
                        NSLog(@"错误信息：%@",error);
                    }else{
                        if (array.count > 0) {
                            BmobObject *object = array[0];
                            self.organizerLb.text = [object objectForKey:@"name"];
                        }
                    }
                }];
            }
        }
    }];
    
}

-(void)setHeadImage:(NSString *)url {
    [self.matchImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

- (IBAction)wechat:(UIButton *)sender {
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [pab setString:self.wechatBtn.titleLabel.text];
    if (pab == nil) {
        [TCCheckUtil showAlertWithMessage:@"复制失败" delegate:self];
        
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制成功，跳转到微信添加好友！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //跳转
            [[UIApplication sharedApplication] openURL:[NSURL URLWithString:@"weixin://"]];
        }];
        //添加按钮
        [alert addAction:ok];
        //以modal的方式来弹出
        [self presentViewController:alert animated:YES completion:nil];
    }
}

- (IBAction)alipay:(UIButton *)sender {
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [pab setString:self.alipayBtn.titleLabel.text];
    if (pab == nil) {
        [TCCheckUtil showAlertWithMessage:@"复制失败" delegate:self];
        
    }else {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"复制成功,请打开支付宝添加好友！" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //跳转
            
        }];
        //添加按钮
        [alert addAction:ok];
        //以modal的方式来弹出
        [self presentViewController:alert animated:YES completion:nil];
    }
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 15;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        return 143;
    } else {
        return UITableViewAutomaticDimension;
    }
    
}


/*
// Override to support conditional editing of the table view.
- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the specified item to be editable.
    return YES;
}
*/

/*
// Override to support editing the table view.
- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle == UITableViewCellEditingStyleDelete) {
        // Delete the row from the data source
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationFade];
    } else if (editingStyle == UITableViewCellEditingStyleInsert) {
        // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
    }   
}
*/

/*
// Override to support rearranging the table view.
- (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath {
}
*/

/*
// Override to support conditional rearranging of the table view.
- (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath {
    // Return NO if you do not want the item to be re-orderable.
    return YES;
}
*/

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
