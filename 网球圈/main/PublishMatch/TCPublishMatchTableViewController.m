//
//  TCPublishMatchTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/3/30.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCPublishMatchTableViewController.h"
#import "TCMatchDetailTableViewController.h"
#import "TCMatchListTableViewCell.h"
#import <BmobSDK/Bmob.h>
#import "MJRefresh.h"
#import "ActionSheetPicker.h"
#import <MJExtension.h>
#import "TCCheckUtil.h"

@interface TCPublishMatchTableViewController ()<ActionSheetCustomPickerDelegate>

@property (nonatomic, strong) NSArray *matches;
@property (nonatomic, strong) NSString *detailAddress;

@property (nonatomic,strong) NSArray *addressArr; // 解析出来的最外层数组
@property (nonatomic,strong) NSArray *provinceArr; // 省
@property (nonatomic,strong) NSArray *countryArr; // 市
@property (nonatomic,assign) NSInteger index1; // 省下标
@property (nonatomic,assign) NSInteger index2; // 市下标
@property (nonatomic,strong) ActionSheetCustomPicker *picker; // 选择器
@property (nonatomic,strong) NSArray *selections; // 选择的两个下标


@end

@implementation TCPublishMatchTableViewController

- (void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear: animated];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    self.tableView.mj_footer = [MJRefreshAutoNormalFooter footerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.tableView.mj_header beginRefreshing];
    [self.tableView.mj_header beginRefreshing];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //设置tabBarItem的颜色
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    
    [self.tableView.mj_header beginRefreshing];
    
    self.detailAddress = [[NSString alloc]init];
    if (self.selections.count) {
        self.index1 = [self.selections[0] integerValue];
        self.index2 = [self.selections[1] integerValue];
    }
    // 一定要先加载出这三个数组，不然就蹦了
    [self calculateFirstData];
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

-(void)refreshData {
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCMatch"];
    //查询结果
    [query orderByDescending:@"createdAt"];
    //排序后查询所有结果
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        if (error){
            if (error.code == 20002) {
                [TCCheckUtil showAlertWithMessage:@"网络故障，请检查一下网络！" delegate:self];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        } else {
            self.matches = array;
            NSLog(@"数据:%@",self.matches);
            [self.tableView reloadData];
            [self.tableView.mj_header endRefreshing];
            [self.tableView.mj_footer endRefreshing];
        }
    }];
}

- (IBAction)filter:(UIBarButtonItem *)sender {
    self.picker = [[ActionSheetCustomPicker alloc] initWithTitle:nil delegate:self showCancelButton:YES origin:self.view initialSelections:@[@(self.index1),@(self.index2)]];
    self.picker.tapDismissAction  = TapActionSuccess;
    [self.picker showActionSheetPicker];
}

- (void)loadFirstData {
    // 注意JSON后缀的东西和Plist不同，Plist可以直接通过contentOfFile抓取，Json要先打成字符串，然后用工具转换
    NSString *path = [[NSBundle mainBundle] pathForResource:@"address" ofType:@"json"];
    NSLog(@"%@",path);
    NSString *jsonStr = [NSString stringWithContentsOfFile:path usedEncoding:nil error:nil];
    self.addressArr = [jsonStr mj_JSONObject];
    
    NSMutableArray *firstName = [[NSMutableArray alloc] init];
    for (NSDictionary *dict in self.addressArr)
    {
        NSString *name = dict.allKeys.firstObject;
        [firstName addObject:name];
    }
    // 第一层是省份 分解出整个省份数组
    self.provinceArr = firstName;
}

// 根据传进来的下标数组计算对应的三个数组
- (void)calculateFirstData {
    // 拿出省的数组
    [self loadFirstData];
    
    NSMutableArray *cityNameArr = [[NSMutableArray alloc] init];
    // 根据省的index1，默认是0，拿出对应省下面的市
    for (NSDictionary *cityName in [self.addressArr[self.index1] allValues].firstObject) {
        
        NSString *name1 = cityName.allKeys.firstObject;
        [cityNameArr addObject:name1];
    }
    // 组装对应省下面的市
    self.countryArr = cityNameArr;
}

#pragma mark - UIPickerViewDataSource Implementation
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 2;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // Returns
    switch (component) {
        case 0: return self.provinceArr.count;
        case 1: return self.countryArr.count;
        default:break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component)
    {
        case 0: return self.provinceArr[row];break;
        case 1: return self.countryArr[row];break;
        default:break;
    }
    return nil;
}
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view {
    UILabel* label = (UILabel*)view;
    if (!label) {
        label = [[UILabel alloc] init];
        [label setFont:[UIFont systemFontOfSize:14]];
    }
    
    NSString * title = @"";
    switch (component) {
        case 0: title =   self.provinceArr[row];break;
        case 1: title =   self.countryArr[row];break;
        default:break;
    }
    label.textAlignment = NSTextAlignmentCenter;
    label.text=title;
    return label;
}

- (void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component {
    switch (component) {
        case 0:
        {
            self.index1 = row;
            self.index2 = 0;
            //            [self calculateData];
            // 滚动的时候都要进行一次数组的刷新
            [self calculateFirstData];
            [pickerView reloadComponent:1];
            [pickerView selectRow:0 inComponent:1 animated:YES];
        }
            break;
            
        case 1:
        {
            self.index2 = row;
            //            [self calculateData];
            [self calculateFirstData];
        }
            break;
        default:break;
    }
}

- (void)configurePickerView:(UIPickerView *)pickerView {
    pickerView.showsSelectionIndicator = NO;
}
// 点击done的时候回调
- (void)actionSheetPickerDidSucceed:(ActionSheetCustomPicker *)actionSheetPicker origin:(id)origin {
    NSString *firstAddress = self.provinceArr[self.index1];
    NSString *str1 = [firstAddress stringByAppendingString:@" "];
    NSString *secondAddress = self.countryArr[self.index2];
    NSString *str2 = [secondAddress stringByAppendingString:@" "];
    self.detailAddress = [str1 stringByAppendingString:str2];
    //筛选
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(getFilterData)];
    
    [self.tableView.mj_header beginRefreshing];
}

- (NSArray *)provinceArr {
    if (_provinceArr == nil) {
        _provinceArr = [[NSArray alloc] init];
    }
    return _provinceArr;
}
-(NSArray *)countryArr {
    if(_countryArr == nil) {
        _countryArr = [[NSArray alloc] init];
    }
    return _countryArr;
}

-(NSArray *)addressArr {
    if (_addressArr == nil) {
        _addressArr = [[NSArray alloc] init];
    }
    return _addressArr;
}

- (void)getFilterData {
    
    BmobQuery *query = [BmobQuery queryWithClassName:@"TCMatch"];
    //查询结果
    [query orderByDescending:@"createdAt"];
    [query whereKey:@"city" equalTo:self.detailAddress];
    [query findObjectsInBackgroundWithBlock:^(NSArray *array, NSError *error) {
        self.matches = array;
        NSLog(@"数据：%@",self.matches);
        [self.tableView reloadData];
        [self.tableView.mj_header endRefreshing];
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
