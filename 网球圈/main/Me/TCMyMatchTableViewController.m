//
//  TCMyMatchTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/25.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMyMatchTableViewController.h"
#import "TCMatchDetailTableViewController.h"
#import "TCMatchListTableViewCell.h"
#import "TCFriendModel.h"
#import <BmobSDK/Bmob.h>
#import "MJRefresh.h"
#import "TCCheckUtil.h"

@interface TCMyMatchTableViewController ()

@property (nonatomic, strong) NSMutableArray *matches;

@end

@implementation TCMyMatchTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.tableView.mj_header beginRefreshing];
    [self.tableView.mj_header beginRefreshing];
}


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    [self.tableView.mj_header beginRefreshing];
    
    self.matches = [[NSMutableArray alloc]init];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refreshData {
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCMatch"];
    //查询结果
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"matchId" equalTo:user.objectId];
    //排序后查询所有结果
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        }else{
            if (array.count > 0) {
                self.matches = [array mutableCopy];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return self.matches.count;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    }
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMatchListTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchCell" forIndexPath:indexPath];
    BmobObject *matchObj = self.matches[indexPath.section];
    [cell setCellInfo:matchObj];
    return cell;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    TCMatchListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
    TCMatchDetailTableViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCMatchDetailTableViewController"];
    BmobObject *matchObj = self.matches[indexPath.section];
    [cell setCellInfo:matchObj];
    sVC.objectId = cell.objectId;
    [self.navigationController pushViewController:sVC animated:YES];
}

- (BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath {
    return YES;
}

- (void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    if (editingStyle ==UITableViewCellEditingStyleDelete) {
        UIAlertController *alertController = [UIAlertController alertControllerWithTitle:@"确认删除？" message:nil preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:nil];
        UIAlertAction *defaultAction = [UIAlertAction actionWithTitle:@"确认" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
            //删除数据源
            TCMatchListTableViewCell *cell = [tableView cellForRowAtIndexPath:indexPath];
            BmobObject *object = [BmobObject objectWithoutDataWithClassName:@"TCMatch"  objectId:cell.objectId];
            [object deleteInBackgroundWithBlock:^(BOOL isSuccessful, NSError *error) {
                if (isSuccessful) {
                    //删除成功后的动作
                    NSLog(@"successful");
                    
                    [self.matches removeObjectAtIndex:indexPath.section];
                    [tableView deleteSections: [NSIndexSet indexSetWithIndex: indexPath.section] withRowAnimation:UITableViewRowAnimationBottom];
                    [tableView reloadData];
                    
                } else {
                    if (error.code == 20002) {
                        [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
                    } else {
                        [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
                    }
                }
            }];
        }];
        [alertController addAction:cancelAction];
        [alertController addAction:defaultAction];
        [self presentViewController:alertController animated:YES completion:nil];
    }
    else if (editingStyle ==UITableViewCellEditingStyleInsert) {
    }
}

- (NSString *)tableView:(UITableView *)tableView titleForDeleteConfirmationButtonForRowAtIndexPath:(NSIndexPath *)indexPath {
    return @"删除";
}
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
