//
//  TCPersonInfoTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/25.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCPersonInfoTableViewController.h"
#import "TCMeTableViewController.h"
#import "TCMyCircleTableViewController.h"
#import "TCMyMatchTableViewController.h"
#import "TCMyBallTableViewController.h"
#import "TCPersonInfoTableViewCell.h"
#import "MJRefresh.h"
#import <BmobSDK/Bmob.h>
#import "TCCheckUtil.h"
#import <SDWebImage/UIImageView+WebCache.h>

@interface TCPersonInfoTableViewController ()

@property TCPersonInfoTableViewCell *cell;
@end

@implementation TCPersonInfoTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //设置tabBarItem的颜色
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.tableView.mj_header beginRefreshing];
    self.tableView.separatorInset = UIEdgeInsetsZero;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section==0) {
        return 1;
    } else if (section==1) {
        return 3;
    } else {
        return 1;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section==0) {
        return 80;
    }
    return 44;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 10;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.cell = [tableView dequeueReusableCellWithIdentifier:@"infoCell" forIndexPath:indexPath];
        [self refreshData];
        return self.cell;
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"circleCell" forIndexPath:indexPath];
            return cell;
        } else if (indexPath.row == 1) {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"matchCell" forIndexPath:indexPath];
            return cell;
        } else {
            UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"appointCell" forIndexPath:indexPath];
            return cell;
        }
    } else {
        UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"settingCell" forIndexPath:indexPath];
        return cell;
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        TCMeTableViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCMeTableViewController"];
        [self.navigationController pushViewController:sVC animated:YES];
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            TCMyCircleTableViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCMyCircleTableViewController"];
            sVC.objectId = self.objectId;
            [self.navigationController pushViewController:sVC animated:YES];
        } else if (indexPath.row == 1) {
            TCMyMatchTableViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCMyMatchTableViewController"];
            sVC.objectId = self.objectId;
            [self.navigationController pushViewController:sVC animated:YES];
        } else {
            TCMyBallTableViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCMyBallTableViewController"];
            sVC.objectId = self.objectId;
            [self.navigationController pushViewController:sVC animated:YES];
        }
    } else {
        
    }
}

-(void)setHeadImage:(NSString *)url {
    [self.cell.userImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

-(void)refreshData {
    BmobUser *user = [BmobUser currentUser];
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCUserInfo"];
    [query whereKey:@"userId" equalTo:user.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            if (array.count > 0) {
                BmobObject *object = array[0];
                [self setHeadImage:[object objectForKey:@"image"]];
                self.cell.usernameLb.text = [object objectForKey:@"username"];
                self.cell.nameLb.text = [object objectForKey:@"name"];
            }
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
        }
    }];
    
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
