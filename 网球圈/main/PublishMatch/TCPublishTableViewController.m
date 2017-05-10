//
//  TCPublishTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/1.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCPublishTableViewController.h"
#import <BmobSDK/Bmob.h>
#import <SDWebImage/UIImageView+WebCache.h>
#import "ActionSheetPicker.h"
#import <MJExtension.h>
#import "TCCheckUtil.h"

@interface TCPublishTableViewController ()<UITextFieldDelegate,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *titleTf;
@property (weak, nonatomic) IBOutlet UITextField *cityTf;
@property (weak, nonatomic) IBOutlet UIImageView *matchImage;
@property (weak, nonatomic) IBOutlet UITextField *kindTf;
@property (weak, nonatomic) IBOutlet UITextField *institutionTf;
@property (weak, nonatomic) IBOutlet UITextField *placeTf;
@property (weak, nonatomic) IBOutlet UITextField *matchTimeTf;
@property (weak, nonatomic) IBOutlet UITextField *limitTf;
@property (weak, nonatomic) IBOutlet UITextField *demandTf;
@property (weak, nonatomic) IBOutlet UITextField *costTf;
@property (weak, nonatomic) IBOutlet UITextField *wechatTf;
@property (weak, nonatomic) IBOutlet UITextField *alipayTf;
@property (weak, nonatomic) IBOutlet UITextField *deadlineTf;
@property (weak, nonatomic) IBOutlet UITextField *awardTf;
@property (weak, nonatomic) IBOutlet UILabel *organizerLb;
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property BOOL hasImage;

@property (nonatomic, strong) NSData *imageData;

@property (nonatomic, strong) NSArray *kindArray;
@property (nonatomic, strong) NSArray *institutionArray;
@property (nonatomic, strong) NSArray *limitArray;
@property (nonatomic, strong) NSArray *demandArray;

@property (nonatomic,strong) NSArray *addressArr; // 解析出来的最外层数组
@property (nonatomic,strong) NSArray *provinceArr; // 省
@property (nonatomic,strong) NSArray *countryArr; // 市
@property (nonatomic,assign) NSInteger index1; // 省下标
@property (nonatomic,assign) NSInteger index2; // 市下标
@property (nonatomic,strong) ActionSheetCustomPicker *picker; // 选择器
@property (nonatomic,strong) NSArray *selections; // 选择的三个下标
@property (nonatomic,copy) NSString *pushAddress; // 展示的地址
@end

@implementation TCPublishTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.titleTf.delegate = self;
    self.kindTf.delegate = self;
    self.institutionTf.delegate = self;
    self.cityTf.delegate = self;
    self.placeTf.delegate = self;
    self.matchTimeTf.delegate = self;
    self.limitTf.delegate = self;
    self.demandTf.delegate = self;
    self.costTf.delegate = self;
    self.wechatTf.delegate = self;
    self.alipayTf.delegate = self;
    self.deadlineTf.delegate = self;
    self.awardTf.delegate = self;
    
    self.hasImage = NO;
    self.indicator.hidden = YES;
    [self.indicator startAnimating];
    
    self.kindTf.userInteractionEnabled = NO;
    self.institutionTf.userInteractionEnabled = NO;
    self.cityTf.userInteractionEnabled = NO;
    self.matchTimeTf.userInteractionEnabled = NO;
    self.limitTf.userInteractionEnabled = NO;
    self.demandTf.userInteractionEnabled = NO;
    self.deadlineTf.userInteractionEnabled = NO;
    self.matchImage.userInteractionEnabled = NO;
    
    self.titleTf.tintColor = [UIColor lightGrayColor];
    self.placeTf.tintColor = [UIColor lightGrayColor];
    self.costTf.tintColor = [UIColor lightGrayColor];
    self.wechatTf.tintColor = [UIColor lightGrayColor];
    self.alipayTf.tintColor = [UIColor lightGrayColor];
    self.awardTf.tintColor = [UIColor lightGrayColor];
    
    self.kindArray = [NSArray arrayWithObjects:@"男子单打",@"女子单打", @"男子双打",@"女子双打",@"混合双打",@"团体赛",nil];
    self.institutionArray = [NSArray arrayWithObjects:@"单淘汰一盘6局无占先",@"单淘汰一盘6局有占先",@"小组循环赛一盘4局有占先",@"小组循环赛一盘6局无占先", nil];
    self.limitArray = [NSArray arrayWithObjects:@"无限制",@"10岁以下", @"10~12岁",@"13~15岁",@"16~19岁",@"20~34岁",@"35~44岁",@"45~54岁",@"55~64岁",@"65岁以上",nil];
    self.demandArray = [NSArray arrayWithObjects:@"无限制",@"单打5.0以下",@"单打5.0以上",@"双打4.0~6.0",@"双打6.0~10.0",@"双打10.0以上", nil];
    
    if (self.pushAddress) {
        self.cityTf.text = self.pushAddress;
    }
    if (self.selections.count) {
        self.index1 = [self.selections[0] integerValue];
        self.index2 = [self.selections[1] integerValue];
    }
    // 一定要先加载出这三个数组，不然就蹦了
    [self calculateFirstData];
    
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
                self.organizerLb.text = [object objectForKey:@"name"];
                
            }
        }
    }];
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

-(void)setHeadImage:(NSString *)url {
    [self.matchImage sd_setImageWithURL:[NSURL URLWithString:url]];
}

- (BOOL)textFieldShouldBeginEditing:(UITextField *)textField {
    if (textField == self.titleTf || textField == self.placeTf || textField == self.costTf ||textField == self.wechatTf || textField == self.alipayTf || textField == self.awardTf) {
        return YES;
    } else {
        return NO;
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
    return 16;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:nil preferredStyle:UIAlertControllerStyleActionSheet];
        if([[[UIDevice currentDevice] systemVersion] floatValue]>=8.0) {
            alert.popoverPresentationController.sourceView = self.matchImage;
            alert.popoverPresentationController.sourceRect = self.matchImage.bounds;
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
    } else if (indexPath.row == 2) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.kindArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.kindTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.kindTf];
    } else if (indexPath.row == 3) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.institutionArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.institutionTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.institutionTf];
    } else if (indexPath.row == 4) {
        self.picker = [[ActionSheetCustomPicker alloc] initWithTitle:nil delegate:self showCancelButton:YES origin:self.cityTf initialSelections:@[@(self.index1),@(self.index2)]];
        self.picker.tapDismissAction  = TapActionSuccess;
        [self.picker showActionSheetPicker];
    } else if (indexPath.row == 6) {
        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] minimumDate:nil maximumDate:nil target:self action:@selector(timeWasSelected:element:) origin:self.matchTimeTf];
        datePicker.minuteInterval = 5;
        [datePicker showActionSheetPicker];
    } else if (indexPath.row == 7) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.limitArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.limitTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.limitTf];
    } else if (indexPath.row == 8) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.demandArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.demandTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.demandTf];
    } else if (indexPath.row == 12) {
        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeDate selectedDate:[NSDate date] minimumDate:nil maximumDate:nil target:self action:@selector(timeWasSelected:element:) origin:self.deadlineTf];
        datePicker.minuteInterval = 5;
        [datePicker showActionSheetPicker];
    } else {
    }
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(UITextField *)element {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日"];
    [element setText:[dateFormatter stringFromDate:selectedTime]];
}

//完成拍照
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[@"UIImagePickerControllerEditedImage"];
    self.imageData = UIImageJPEGRepresentation(img, .5);
    self.matchImage.image = img;
    self.hasImage = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)summit:(UIButton *)sender {
    if (self.hasImage == YES && self.titleTf.text.length != 0 && self.cityTf.text.length != 0 && self.kindTf.text.length != 0 && self.institutionTf.text.length != 0 && self.placeTf.text.length != 0 && self.matchTimeTf.text.length != 0 && self.limitTf.text.length != 0 && self.demandTf.text.length != 0 && self.costTf.text.length != 0 && self.wechatTf.text.length != 0 && self.alipayTf.text.length != 0 && self.deadlineTf.text.length != 0 && self.awardTf.text.length != 0) {
        self.indicator.hidden = NO;
        BmobUser *user = [BmobUser currentUser];
        BmobObject *obj = [BmobObject objectWithClassName:@"TCMatch"];
        [obj setObject:user.objectId forKey:@"matchId"];
        [obj setObject:self.titleTf.text forKey:@"title"];
        [obj setObject:self.kindTf.text forKey:@"kind"];
        [obj setObject:self.institutionTf.text forKey:@"institution"];
        [obj setObject:self.cityTf.text forKey:@"city"];
        [obj setObject:self.placeTf.text forKey:@"place"];
        [obj setObject:self.matchTimeTf.text forKey:@"matchTime"];
        [obj setObject:self.limitTf.text forKey:@"limit"];
        [obj setObject:self.demandTf.text forKey:@"demand"];
        [obj setObject:self.costTf.text forKey:@"cost"];
        [obj setObject:self.wechatTf.text forKey:@"wechat"];
        [obj setObject:self.alipayTf.text forKey:@"alipay"];
        [obj setObject:self.deadlineTf.text forKey:@"deadline"];
        [obj setObject:self.awardTf.text forKey:@"award"];
        
        [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                BmobFile *file = [[BmobFile alloc] initWithFileName:@"a.jpg" withFileData:self.imageData];
                [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
                    [obj setObject:file.url forKey:@"image"];
                    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                        if (isSuccessful) {
                            NSLog(@"图片发送成功");
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发布成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                //跳转
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            //添加按钮
                            [alert addAction:ok];
                            //以modal的方式来弹出
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }];
                }];
            } else {
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        }];

    } else {
        self.indicator.hidden = YES;
        [TCCheckUtil showAlertWithMessage:@"请填写完整！" delegate:self];
    }
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
    // 此界面显示
    self.cityTf.text = detailAddress;
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
