//
//  TCTennisDetailViewController.m
//  网球圈
//
//  Created by kozon on 2017/5/3.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCTennisDetailViewController.h"
#import "TCTennisDetailTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "TCTennisDetailModel.h"
#import "MJRefresh.h"
#import "TCCheckUtil.h"
#import "TCMessageTableViewCell.h"
#import "TCMessageModel.h"
#import "TCLeaveMessageViewController.h"

@interface TCTennisDetailViewController ()<UITableViewDelegate,UITableViewDataSource,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@property (strong, nonatomic) NSMutableArray *messages;
@property TCTennisDetailTableViewCell *cell;
@property TCMessageTableViewCell *messageCell;
@property (nonatomic, strong) BmobObject *object;

@end

@implementation TCTennisDetailViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.tableView.delegate = self;
    self.tableView.dataSource = self;
    self.tableView.separatorInset = UIEdgeInsetsZero;
    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.messages = [[NSMutableArray alloc] init];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    [self.tableView.mj_header beginRefreshing];
    // Do any additional setup after loading the view.
}


-(void)refreshData {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCTennisCircle"];
    [query whereKey:@"objectId" equalTo:self.objectId];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            self.object = array[0];
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
            [self getMessage];
        }
    }];
}

- (IBAction)leave:(UIBarButtonItem *)sender {
    TCLeaveMessageViewController *sVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCLeaveMessageViewController"];
    sVC.messageId = self.objectId;
    [self.navigationController pushViewController:sVC animated:YES];
}

-(void)getMessage {
    BmobQuery *messageQuery = [BmobQuery queryWithClassName:@"TCMessage"];
    //查询结果
    [messageQuery orderByDescending:@"createdAt"];
    [messageQuery whereKey:@"messageId" equalTo:self.objectId];
    //排序后查询所有结果
    [messageQuery findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            self.messages = [array mutableCopy];
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

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 1;
    } else {
        return self.messages.count;
    }
}

- (CGFloat)tableView:(UITableView *)tableView estimatedHeightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return UITableViewAutomaticDimension;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return 0.1;
    } else {
        return 30;
    }
    
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section {
    if (section == 1) {
        UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 30)];
        headerView.backgroundColor = [UIColor colorWithRed:246.0/255.0 green:246.0/255.0 blue:247.0/255.0 alpha:1.0];
        UILabel *label = [[UILabel alloc]initWithFrame:CGRectMake(8, 0, 100, 30)];
        label.font = [UIFont systemFontOfSize:15];
        label.text = @"留言区";
        [headerView addSubview:label];
        return headerView;
    }
    return nil;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        self.cell = [tableView dequeueReusableCellWithIdentifier:@"cell" forIndexPath:indexPath];
        TCTennisDetailModel *info = [[TCTennisDetailModel alloc]init];
        [info setCellInfo:self.object];
        [self.cell setCellInfo:info];
        return self.cell;
    } else {
        self.messageCell = [tableView dequeueReusableCellWithIdentifier:@"messageCell" forIndexPath:indexPath];
        TCMessageModel *info = [[TCMessageModel alloc]init];
        [info initWithObject:self.messages[indexPath.row]];
        [self.messageCell setCellInfo:info];
        return self.messageCell;
    }
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
