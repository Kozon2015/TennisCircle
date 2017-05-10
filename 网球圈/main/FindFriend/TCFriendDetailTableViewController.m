//
//  TCFriendDetailTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCFriendDetailTableViewController.h"
#import "TCFriendDetailTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "TCFriendDetailModel.h"
#import "MJRefresh.h"
#import "TCCheckUtil.h"

@interface TCFriendDetailTableViewController ()

@property TCFriendDetailTableViewCell *cell;
@property (nonatomic, strong) BmobObject *object;

@end

@implementation TCFriendDetailTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    [self.tableView.mj_header beginRefreshing];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refreshData {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCFriend"];
    [query getObjectInBackgroundWithId:self.objectId block:^(BmobObject *object, NSError *error) {
        if (error) {
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            self.object = object;
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
    }];
//    [query whereKey:@"objectId" equalTo:self.objectId];
//    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
//        if (error) {
//            if (error.code == 20002) {
//                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
//            } else {
//                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
//            }
//        } else {
//            self.object = array[0];
//            [self.tableView reloadData];
//            [self.tableView.mj_header endRefreshing];
//        }
//    }];
}

- (IBAction)phone:(UIButton *)sender {
    NSLog(@"%@",self.cell.phoneButton.titleLabel.text);
    [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[@"tel://" stringByAppendingString:self.cell.phoneButton.titleLabel.text]]];
}

- (IBAction)wechat:(UIButton *)sender {
    UIPasteboard *pab = [UIPasteboard generalPasteboard];
    [pab setString:self.cell.wechatButton.titleLabel.text];
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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
    TCFriendDetailModel *info = [[TCFriendDetailModel alloc]init];
    [info setCellInfo:self.object];
    [self.cell setCellInfo:info];
    return self.cell;
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
