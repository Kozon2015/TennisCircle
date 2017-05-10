//
//  TCEditFeelingTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/3/30.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCEditFeelingTableViewController.h"
#import "TCInformationViewController.h"
#import "ACEExpandableTextCell.h"
#import <BmobSDK/Bmob.h>
#import "TCCheckUtil.h"

@interface TCEditFeelingTableViewController ()<ACEExpandableTableViewDelegate,UITextViewDelegate> {
    CGFloat cellHeight;
}
@property (strong, nonatomic)ACEExpandableTextCell *cell;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *sendBarButton;

@end

@implementation TCEditFeelingTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.sendBarButton.enabled = NO;
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(textDidChanged:) name:UITextViewTextDidChangeNotification object:nil];
    
    self.cell.textView.tintColor = [UIColor lightGrayColor];
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    // Uncomment the following line to preserve selection between presentations.
    // self.clearsSelectionOnViewWillAppear = NO;
    
    // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
    // self.navigationItem.rightBarButtonItem = self.editButtonItem;
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.cell.textView resignFirstResponder];
}

- (void)textDidChanged:(NSNotification *)notification {
    if (self.cell.textView.text.length!=0) {
        self.sendBarButton.enabled = YES;
    }
    else {
        self.sendBarButton.enabled = NO;
    }
}

- (IBAction)publish:(UIBarButtonItem *)sender {
    BmobUser *user = [BmobUser currentUser];
    self.circleId = user.objectId;
    BmobObject *obj = [BmobObject objectWithClassName:@"TCTennisCircle"];
    [obj setObject:self.circleId forKey:@"circleId"];
    [obj setObject:self.cell.textView.text forKey:@"content"];
    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
        if (isSuccessful) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发表成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
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

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section {
    return 0.1;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    self.cell = [tableView expandableTextCellWithId:@"cellId"];
    self.cell.text = @"";
    self.cell.textView.placeholder = @"分享您的心情，对网球的看法以及网球的奇闻趣事";
    return self.cell;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return MAX(36.0, cellHeight);
}

- (void)tableView:(UITableView *)tableView updatedHeight:(CGFloat)height atIndexPath:(NSIndexPath *)indexPath {
    cellHeight = height;
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
