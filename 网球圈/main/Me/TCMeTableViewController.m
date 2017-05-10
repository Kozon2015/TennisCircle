//
//  TCMeTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/3/29.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCMeTableViewController.h"
#import <BmobSDK/Bmob.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ActionSheetPicker.h"
#import <MJExtension.h>
#import "TCCheckUtil.h"
#import "MJRefresh.h"
#import "TCPersonInfoTableViewController.h"

@interface TCMeTableViewController ()<UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UIImageView *userImage;
@property (weak, nonatomic) IBOutlet UILabel *accountLabel;
@property (weak, nonatomic) IBOutlet UITextField *nameTf;
@property (weak, nonatomic) IBOutlet UITextField *ageTf;
@property (weak, nonatomic) IBOutlet UITextField *sexTf;
@property (weak, nonatomic) IBOutlet UITextField *cityTf;
@property (weak, nonatomic) IBOutlet UITextField *ballAgeTf;
@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, strong) NSArray *sexArray;
@property (nonatomic, strong) NSArray *ageArray;
@property (nonatomic, strong) NSArray *ballAgeArray;
@property (nonatomic,strong) NSArray *addressArr; // 解析出来的最外层数组
@property (nonatomic,strong) NSArray *provinceArr; // 省
@property (nonatomic,strong) NSArray *countryArr; // 市
@property (nonatomic,strong) NSArray *districtArr; // 区
@property (nonatomic,assign) NSInteger index1; // 省下标
@property (nonatomic,assign) NSInteger index2; // 市下标
@property (nonatomic,assign) NSInteger index3; // 区下标
@property (nonatomic,strong) ActionSheetCustomPicker *picker; // 选择器
@property (nonatomic,strong) NSArray *selections; // 选择的三个下标
@property (nonatomic,copy) NSString *pushAddress; // 展示的地址
@property (nonatomic,copy) NSString *objectId;

@end

@implementation TCMeTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.nameTf.delegate = self;
    self.ageTf.delegate = self;
    self.sexTf.delegate = self;
    self.cityTf.delegate = self;
    self.ballAgeTf.delegate = self;
    
    self.ageTf.userInteractionEnabled = NO;
    self.sexTf.userInteractionEnabled = NO;
    self.cityTf.userInteractionEnabled = NO;
    self.ballAgeTf.userInteractionEnabled = NO;
    
    self.nameTf.tintColor = [UIColor lightGrayColor];

    self.sexArray = [NSArray arrayWithObjects:@"♂",@"♀", nil];
    self.ageArray = [NSArray arrayWithObjects:@"20岁以下",@"20~25岁",@"26~30岁",@"31~35岁",@"36~40岁",@"41~45岁",@"45岁以上", nil];
    self.ballAgeArray = [NSArray arrayWithObjects:@"1年以下", @"1~2年",@"2~3年",@"3~4年",@"4~5年",@"5~6年",@"6~7年",@"7~8年",@"8年以上",nil];
    
    if (self.pushAddress) {
        [self.cityTf setText:self.pushAddress];
    }
    if (self.selections.count) {
        self.index1 = [self.selections[0] integerValue];
        self.index2 = [self.selections[1] integerValue];
        self.index3 = [self.selections[2] integerValue];
    }
    // 一定要先加载出这三个数组，不然就蹦了
    [self calculateFirstData];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    
    self.tableView.mj_header = [MJRefreshNormalHeader headerWithRefreshingTarget:self refreshingAction:@selector(refreshData)];
    [self.tableView.mj_header beginRefreshing];
}

- (void)refreshData{
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
        }else{
            if (array.count > 0) {
                BmobObject *object = array[0];
                [self setHeadImage:[object objectForKey:@"image"]];
                self.objectId = [object objectForKey:@"objectId"];
                self.accountLabel.text = [object objectForKey:@"username"];
                self.nameTf.text = [object objectForKey:@"name"];
                self.ageTf.text = [object objectForKey:@"age"];
                self.sexTf.text = [object objectForKey:@"sex"];
                self.cityTf.text = [object objectForKey:@"city"];
                self.ballAgeTf.text = [object objectForKey:@"ballAge"];
                [object saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                    if (isSuccessful) {
                        
                    }
                }];
                [self.tableView reloadData];
                [self.tableView.mj_header endRefreshing];
            }
        }
    }];
}

- (IBAction)save:(UIBarButtonItem *)sender {
    [self updateObject];
}

- (void)updateObject{
    BmobObject  *myObj = [BmobObject objectWithoutDataWithClassName:@"TCUserInfo" objectId:self.objectId];
    [myObj setObject:self.nameTf.text forKey:@"name"];
    [myObj setObject:self.sexTf.text forKey:@"sex"];
    [myObj setObject:self.ageTf.text forKey:@"age"];
    [myObj setObject:self.ballAgeTf.text forKey:@"ballAge"];
    [myObj setObject:self.cityTf.text forKey:@"city"];
    BmobFile *file = [[BmobFile alloc] initWithFileName:@"a.jpg" withFileData:self.imageData];
    [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
        [myObj setObject:file.url forKey:@"image"];
        [myObj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                NSLog(@"更新成功%@",myObj);
                UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"修改成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                    //跳转并传值
                    TCPersonInfoTableViewController *PITVC = [[TCPersonInfoTableViewController alloc]init];
                    PITVC.objectId = self.objectId;
                    [self.navigationController popViewControllerAnimated:YES];
                }];
                //添加按钮
                [alert addAction:ok];
                //以modal的方式来弹出
                [self presentViewController:alert animated:YES completion:nil];
            } else {
                NSLog(@"%@",error);
            }
        }];
    }];
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.nameTf resignFirstResponder];
}

-(void)setHeadImage:(NSString *)url {
    [self.userImage sd_setImageWithURL:[NSURL URLWithString:url]];
}


- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.nameTf) {
        return YES;
    } else {
        return NO;
    }
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
    //                             index1对应省的字典         市的数组 index2市的字典   对应市的数组
    // 这里的allValue是取出来的大数组，取第0个就是需要的内容
    self.districtArr = [[self.addressArr[self.index1] allValues][0][self.index2] allValues][0];
}

#pragma mark - UIPickerViewDataSource Implementation
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView {
    return 3;
}

- (NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component {
    // Returns
    switch (component) {
        case 0: return self.provinceArr.count;
        case 1: return self.countryArr.count;
        case 2:return self.districtArr.count;
        default:break;
    }
    return 0;
}

- (NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component {
    switch (component)
    {
        case 0: return self.provinceArr[row];break;
        case 1: return self.countryArr[row];break;
        case 2:return self.districtArr[row];break;
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
        case 2: title =   self.districtArr[row];break;
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
            self.index3 = 0;
            //            [self calculateData];
            // 滚动的时候都要进行一次数组的刷新
            [self calculateFirstData];
            [pickerView reloadComponent:1];
            [pickerView reloadComponent:2];
            [pickerView selectRow:0 inComponent:1 animated:YES];
            [pickerView selectRow:0 inComponent:2 animated:YES];
        }
            break;
            
        case 1:
        {
            self.index2 = row;
            self.index3 = 0;
            //            [self calculateData];
            [self calculateFirstData];
            [pickerView selectRow:0 inComponent:2 animated:YES];
            [pickerView reloadComponent:2];
        }
            break;
        case 2:
            self.index3 = row;
            break;
        default:break;
    }
}

- (void)configurePickerView:(UIPickerView *)pickerView {
    pickerView.showsSelectionIndicator = NO;
}
// 点击done的时候回调
- (void)actionSheetPickerDidSucceed:(ActionSheetCustomPicker *)actionSheetPicker origin:(id)origin {
    NSMutableString *detailAddress = [[NSMutableString alloc] init];
    if (self.index1 < self.provinceArr.count) {
        NSString *firstAddress = self.provinceArr[self.index1];
        NSString *str = [firstAddress stringByAppendingString:@" "];
        [detailAddress appendString:str];
    }
    if (self.index2 < self.countryArr.count) {
        NSString *secondAddress = self.countryArr[self.index2];
        NSString *str = [secondAddress stringByAppendingString:@" "];
        [detailAddress appendString:str];
    }
    if (self.index3 < self.districtArr.count) {
        NSString *thirfAddress = self.districtArr[self.index3];
        [detailAddress appendString:thirfAddress];
    }
    // 此界面显示
    [self.cityTf setText:detailAddress];
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

- (NSArray *)districtArr {
    if (_districtArr == nil) {
        _districtArr = [[NSArray alloc] init];
    }
    return _districtArr;
}

-(NSArray *)addressArr {
    if (_addressArr == nil) {
        _addressArr = [[NSArray alloc] init];
    }
    return _addressArr;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 2;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    if (section == 0) {
        return 4;
    } else {
        return 3;
    }
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.section == 0) {
        if (indexPath.row == 0) {
            UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
            if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
                alert.popoverPresentationController.sourceView = self.userImage;
                alert.popoverPresentationController.sourceRect = self.userImage.bounds;
            }
            [self presentViewController:alert animated:YES completion:nil];
            UIAlertAction *cameraAction = [UIAlertAction actionWithTitle:@"相机" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                UIImagePickerControllerSourceType sourceType = UIImagePickerControllerSourceTypeCamera;
                //判断是否有摄像头
                if(![UIImagePickerController isSourceTypeAvailable:sourceType]) {
                    sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
                }
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = sourceType;
                imagePickerController.allowsEditing = YES;
                [self presentViewController:imagePickerController animated:YES completion:nil];  //需要以模态的形式展示
            }];
            
            UIAlertAction *photoAction = [UIAlertAction actionWithTitle:@"相册" style:(UIAlertActionStyleDefault) handler:^(UIAlertAction *action) {
                UIImagePickerControllerSourceType pickerImage= UIImagePickerControllerSourceTypePhotoLibrary;
                if (![UIImagePickerController isSourceTypeAvailable:pickerImage]) {
                    pickerImage = UIImagePickerControllerSourceTypePhotoLibrary;
                }
                UIImagePickerController *imagePickerController = [[UIImagePickerController alloc] init];
                imagePickerController.delegate = self;
                imagePickerController.sourceType = pickerImage;
                imagePickerController.allowsEditing = YES;
                [self presentViewController:imagePickerController animated:YES completion:nil];  //需要以模态的形式展示
            }];
            
            UIAlertAction *cancelAction = [UIAlertAction actionWithTitle:@"取消" style:(UIAlertActionStyleCancel) handler:nil];
            [alert addAction:cameraAction];
            [alert addAction:photoAction];
            [alert addAction:cancelAction];
        } else if (indexPath.row == 1) {
        
        } else if (indexPath.row == 2) {
            [self.nameTf resignFirstResponder];
        } else {
            [ActionSheetStringPicker showPickerWithTitle:nil rows:self.ageArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                self.ageTf.text = selectedValue;
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            } origin:self.ageTf];
        }
    } else if (indexPath.section == 1) {
        if (indexPath.row == 0) {
            [ActionSheetStringPicker showPickerWithTitle:nil rows:self.sexArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                self.sexTf.text = selectedValue;
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            } origin:self.sexTf];
        } else if (indexPath.row == 1) {
            // 点击的时候传三个index进去
            self.picker = [[ActionSheetCustomPicker alloc]initWithTitle:@"选择地区" delegate:self showCancelButton:YES origin:self.view initialSelections:@[@(self.index1),@(self.index2),@(self.index3)]];
            self.picker.tapDismissAction  = TapActionSuccess;
            [self.picker showActionSheetPicker];
        } else {
            [ActionSheetStringPicker showPickerWithTitle:nil rows:self.ballAgeArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
                self.ballAgeTf.text = selectedValue;
            } cancelBlock:^(ActionSheetStringPicker *picker) {
                NSLog(@"Block Picker Canceled");
            } origin:self.ballAgeTf];
        }
    } else {
    
    }
}

//完成拍照
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[@"UIImagePickerControllerEditedImage"];
    self.imageData = UIImageJPEGRepresentation(img, .5);
    self.userImage.image = img;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
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
