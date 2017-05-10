//
//  TCInformationViewController.m
//  网球圈
//
//  Created by kozon on 2017/3/2.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCInformationViewController.h"
#import "TCLogonViewController.h"
#import "ActionSheetPicker.h"
#import <MJExtension.h>
#import "TCCheckUtil.h"

@interface TCInformationViewController ()<UIPickerViewDelegate,UIPickerViewDataSource,UIImagePickerControllerDelegate,UINavigationControllerDelegate,ActionSheetCustomPickerDelegate>

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
@property (weak, nonatomic) IBOutlet UIActivityIndicatorView *indicator;
@property BOOL hasImage;

@end

@implementation TCInformationViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.nameLabel.layer.cornerRadius = 3.0;
    self.sexButton.layer.cornerRadius = 3.0;
    self.sexButton.layer.cornerRadius = 3.0;
    self.ballAgeButton.layer.cornerRadius = 3.0;
    self.cityButton.layer.cornerRadius = 3.0;
    self.summitButton.layer.cornerRadius = 3.0;
    self.hasImage = NO;
    self.indicator.hidden = YES;
    [self.indicator startAnimating];
    self.nameLabel.tintColor = [UIColor lightGrayColor];
    self.sexArray = [NSArray arrayWithObjects:@"♂",@"♀", nil];
    self.ageArray = [NSArray arrayWithObjects:@"20岁以下",@"20~25岁",@"26~30岁",@"31~35岁",@"36~40岁",@"41~45岁",@"45岁以上", nil];
    self.ballAgeArray = [NSArray arrayWithObjects:@"1年以下", @"1~2年",@"2~3年",@"3~4年",@"4~5年",@"5~6年",@"6~7年",@"7~8年",@"8年以上",nil];
    
    if (self.pushAddress) {
        [self.cityButton.titleLabel setText:self.pushAddress];
    }
    if (self.selections.count) {
        self.index1 = [self.selections[0] integerValue];
        self.index2 = [self.selections[1] integerValue];
        self.index3 = [self.selections[2] integerValue];
    }
    // 一定要先加载出这三个数组，不然就蹦了
    [self calculateFirstData];
    
    [self.userImage setUserInteractionEnabled:YES];
    [self.userImage addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(uploadImage:)]];
    
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(keyboardHide:)];
    tapGestureRecognizer.cancelsTouchesInView = NO;
    [self.view addGestureRecognizer:tapGestureRecognizer];
    // Do any additional setup after loading the view.
}

//点击屏幕空白处去掉键盘
-(void)keyboardHide:(UITapGestureRecognizer*)tap {
    [self.nameLabel resignFirstResponder];

}

-(void)uploadImage:(UITapGestureRecognizer *)gestureRecognizer {
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
}

//完成拍照
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    UIImage *img = info[@"UIImagePickerControllerEditedImage"];
    self.imageData = UIImageJPEGRepresentation(img, .5);
    self.userImage.image = img;
    self.hasImage = YES;
    [picker dismissViewControllerAnimated:YES completion:nil];
}

//用户取消拍照
-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    [self dismissViewControllerAnimated:YES completion:nil];
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

- (IBAction)chooseSex:(UIButton *)sender {
    [ActionSheetStringPicker showPickerWithTitle:nil rows:self.sexArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.sexButton setTitle:selectedValue forState:UIControlStateNormal];
        [self.sexButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    } origin:self.sexButton.titleLabel];
    
}

- (IBAction)chooseAge:(UIButton *)sender {
    [ActionSheetStringPicker showPickerWithTitle:nil rows:self.ageArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.ageButton setTitle:selectedValue forState:UIControlStateNormal];
        [self.ageButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    } origin:self.ageButton.titleLabel];
    
}

- (IBAction)chooseBallAge:(UIButton *)sender {
    [ActionSheetStringPicker showPickerWithTitle:nil rows:self.ballAgeArray initialSelection:0 doneBlock:^(ActionSheetStringPicker *picker, NSInteger selectedIndex, id selectedValue) {
        [self.ballAgeButton setTitle:selectedValue forState:UIControlStateNormal];
        [self.ballAgeButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
    } cancelBlock:^(ActionSheetStringPicker *picker) {
        NSLog(@"Block Picker Canceled");
    } origin:self.ballAgeButton.titleLabel];
}

- (IBAction)chooseCity:(UIButton *)sender {
    // 点击的时候传三个index进去
    self.picker = [[ActionSheetCustomPicker alloc]initWithTitle:nil delegate:self showCancelButton:YES origin:self.cityButton initialSelections:@[@(self.index1),@(self.index2),@(self.index3)]];
    self.picker.tapDismissAction  = TapActionSuccess;
    [self.picker showActionSheetPicker];
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
    [self.cityButton setTitle:detailAddress forState:UIControlStateNormal];
    [self.cityButton setTitleColor:[UIColor blackColor] forState:UIControlStateNormal];
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


- (IBAction)summit:(UIButton *)sender {
    if (self.hasImage == YES && self.nameLabel.text.length != 0 && self.sexButton.titleLabel.text.length != 0 && self.ageButton.titleLabel.text.length != 0 && self.ballAgeButton.titleLabel.text.length != 0 && self.cityButton.titleLabel.text.length != 0) {
        self.indicator.hidden = NO;
        BmobObject *obj = [BmobObject objectWithClassName:@"TCUserInfo"];
        
        [obj setObject:self.userId forKey:@"userId"];
        [obj setObject:self.username forKey:@"username"];
        [obj setObject:self.nameLabel.text forKey:@"name"];
        [obj setObject:self.sexButton.titleLabel.text forKey:@"sex"];
        [obj setObject:self.ageButton.titleLabel.text forKey:@"age"];
        [obj setObject:self.ballAgeButton.titleLabel.text forKey:@"ballAge"];
        [obj setObject:self.cityButton.titleLabel.text forKey:@"city"];
        [obj saveInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
            if (isSuccessful) {
                BmobFile *file = [[BmobFile alloc] initWithFileName:@"a.jpg" withFileData:self.imageData];
                [file saveInBackground:^(BOOL isSuccessful, NSError *error) {
                    [obj setObject:file.url forKey:@"image"];
                    [obj updateInBackgroundWithResultBlock:^(BOOL isSuccessful, NSError *error) {
                        if (isSuccessful) {
                            NSLog(@"图片发送成功");
                            UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"注册成功,返回登录" message:nil preferredStyle:UIAlertControllerStyleAlert];
                            UIAlertAction *ok = [UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
                                //跳转
                                TCLogonViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCLogonViewController"];
                                [self presentViewController:TCIVC animated:YES completion:nil];
                            }];
                            //添加按钮
                            [alert addAction:ok];
                            //以modal的方式来弹出
                            [self presentViewController:alert animated:YES completion:nil];
                        }
                    }];
                }];
            } else {
                self.indicator.hidden = YES;
                NSLog(@"错误信息：%@",error);
                [TCCheckUtil showAlertWithMessage:[error description] delegate:self];
            }
        }];
    } else {
        self.indicator.hidden = YES;
        [TCCheckUtil showAlertWithMessage:@"请填写完整！" delegate:self];
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
