//
//  TCLaunchTableViewController.m
//  网球圈
//
//  Created by kozon on 2017/4/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCLaunchTableViewController.h"
#import <BmobSDK/Bmob.h>
#import "ActionSheetPicker.h"
#import "TCCheckUtil.h"
#import <MJExtension.h>

@interface TCLaunchTableViewController ()<UITextFieldDelegate,UITextViewDelegate,ActionSheetCustomPickerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *cityTf;
@property (weak, nonatomic) IBOutlet UITextView *contentTv;
@property (weak, nonatomic) IBOutlet UITextField *levelTf;
@property (weak, nonatomic) IBOutlet UITextField *playingstyleTf;
@property (weak, nonatomic) IBOutlet UITextField *ballTimeTF;
@property (weak, nonatomic) IBOutlet UITextField *ballPlaceTf;
@property (weak, nonatomic) IBOutlet UITextField *costTf;
@property (weak, nonatomic) IBOutlet UITextField *phoneTf;
@property (weak, nonatomic) IBOutlet UITextField *wechatTf;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *launchBtn;

@property (nonatomic, strong) NSArray *levelArray;
@property (nonatomic, strong) NSArray *playingStyleArray;
@property (nonatomic, strong) NSArray *ballTimeArray;
@property (nonatomic, strong) NSArray *costArray;

@property (nonatomic, strong) NSMutableString *detailAddress;

@property (nonatomic,strong) NSArray *addressArr; // 解析出来的最外层数组
@property (nonatomic,strong) NSArray *provinceArr; // 省
@property (nonatomic,strong) NSArray *countryArr; // 市
@property (nonatomic,assign) NSInteger index1; // 省下标
@property (nonatomic,assign) NSInteger index2; // 市下标
@property (nonatomic,strong) ActionSheetCustomPicker *picker; // 选择器
@property (nonatomic,strong) NSArray *selections; // 选择的三个下标
@property (nonatomic,copy) NSString *pushAddress; // 展示的地址

@end

@implementation TCLaunchTableViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.contentTv.delegate = self;
    self.levelTf.delegate = self;
    self.playingstyleTf.delegate = self;
    self.ballTimeTF.delegate = self;
    self.ballPlaceTf.delegate = self;
    self.costTf.delegate = self;
    self.phoneTf.delegate = self;
    self.wechatTf.delegate = self;
    self.cityTf.delegate = self;
    
    self.levelTf.userInteractionEnabled = NO;
    self.playingstyleTf.userInteractionEnabled = NO;
    self.ballTimeTF.userInteractionEnabled = NO;
    self.costTf.userInteractionEnabled = NO;
    self.cityTf.userInteractionEnabled = NO;
    
    self.contentTv.tintColor = [UIColor lightGrayColor];
    self.ballPlaceTf.tintColor = [UIColor lightGrayColor];
    self.phoneTf.tintColor = [UIColor lightGrayColor];
    self.wechatTf.tintColor = [UIColor lightGrayColor];
    
    self.levelArray = [NSArray arrayWithObjects:@"1.0以下",@"1.0~2.0", @"2.0~3.0",@"3.0~4.0", @"4.0~5.0",@"5.0以上",nil];
    self.playingStyleArray = [NSArray arrayWithObjects:@"底线攻击型",@"防守反击型",@"全场型",@"发球上网型",@"全能型", nil];
    self.costArray = [NSArray arrayWithObjects:@"免费",@"10元/人/小时",@"20元/人/小时", @"30元/人/小时",@"40元/人/小时",@"50元/人/小时",@"20元/对/小时", @"30元/对/小时",@"40元/对/小时",@"50元/对/小时",nil];
    
    if (self.pushAddress) {
        self.cityTf.text = self.pushAddress;
    }
    if (self.selections.count) {
        self.index1 = [self.selections[0] integerValue];
        self.index2 = [self.selections[1] integerValue];
    }
    // 一定要先加载出这三个数组，不然就蹦了
    [self calculateFirstData];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.contentTv resignFirstResponder];
    [self.ballPlaceTf resignFirstResponder];
    [self.phoneTf resignFirstResponder];
    [self.wechatTf resignFirstResponder];

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

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (IBAction)launch:(UIBarButtonItem *)sender {
    if (self.contentTv.text.length != 0 && self.levelTf.text.length != 0 && self.playingstyleTf.text.length != 0 && self.ballTimeTF.text.length != 0 && self.cityTf.text.length != 0 && self.ballPlaceTf.text.length != 0 && self.costTf.text.length != 0 && self.phoneTf.text.length != 0 && self.wechatTf.text.length != 0) {
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
                    BmobObject *obj = [BmobObject objectWithClassName:@"TCFriend"];
                    self.friendId = user.objectId;
                    [obj setObject:self.friendId forKey:@"friendId"];
                    [obj setObject:self.contentTv.text forKey:@"content"];
                    [obj setObject:self.levelTf.text forKey:@"level"];
                    [obj setObject:self.cityTf.text forKey:@"city"];
                    [obj setObject:self.playingstyleTf.text forKey:@"playingstyle"];
                    [obj setObject:self.ballTimeTF.text forKey:@"ballTime"];
                    [obj setObject:self.ballPlaceTf.text forKey:@"ballPlace"];
                    [obj setObject:self.costTf.text forKey:@"cost"];
                    [obj setObject:self.phoneTf.text forKey:@"phone"];
                    [obj setObject:self.wechatTf.text forKey:@"wechat"];
                    
                    [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                        if (isSuccessful) {
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"发布成功！" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                //跳转
                                [self.navigationController popViewControllerAnimated:YES];
                            }];
                            //添加按钮
                            [alert addAction:ok];
                            //以modal的方式来弹出
                            [self presentViewController:alert animated:YES completion:nil];
                        } else {
                            [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
                        }
                    }];
                }
            }
        }];
    } else {
        [TCCheckUtil showAlertWithMessage:@"请填写完整！" delegate:self];
    }
}

#pragma mark - Table view data source

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {

    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {

    return 9;
}

- (CGFloat)tableView:(UITableView *)tableView heightForFooterInSection:(NSInteger)section {
    return 0.1;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if (indexPath.row == 1) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.levelArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.levelTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.levelTf];
    } else if (indexPath.row == 2) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.playingStyleArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.playingstyleTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.playingstyleTf];
    } else if (indexPath.row == 3) {
        ActionSheetDatePicker *datePicker = [[ActionSheetDatePicker alloc] initWithTitle:nil datePickerMode:UIDatePickerModeDateAndTime selectedDate:[NSDate date] minimumDate:nil maximumDate:nil target:self action:@selector(timeWasSelected:element:) origin:self.ballTimeTF];
        datePicker.minuteInterval = 5;
        [datePicker showActionSheetPicker];
    } else if (indexPath.row == 4) {
        self.picker = [[ActionSheetCustomPicker alloc] initWithTitle:nil delegate:self showCancelButton:YES origin:self.cityTf initialSelections:@[@(self.index1),@(self.index2)]];
        self.picker.tapDismissAction  = TapActionSuccess;
        [self.picker showActionSheetPicker];
    } else if (indexPath.row == 6) {
        [ActionSheetStringPicker showPickerWithTitle:nil rows:self.costArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
            self.costTf.text = selectedValue;
        } cancelBlock:^(ActionSheetStringPicker *picker) {
            NSLog(@"Block Picker Canceled");
        } origin:self.costTf];
    }  else {
    }
}

-(void)timeWasSelected:(NSDate *)selectedTime element:(UITextField *)element {
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    [dateFormatter setDateFormat:@"yyyy年MM月dd日 EEEE HH:mm"];
    [element setText:[dateFormatter stringFromDate:selectedTime]];
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
