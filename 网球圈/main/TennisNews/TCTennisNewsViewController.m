//
//  TCTennisNewsViewController.m
//  网球圈
//
//  Created by kozon on 2017/5/4.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCTennisNewsViewController.h"
#import <WebKit/WebKit.h>

@interface TCTennisNewsViewController ()<WKNavigationDelegate, WKUIDelegate>

@property (nonatomic, strong) WKWebView *webView;
//返回按钮
@property (nonatomic, strong) UIBarButtonItem *backItem;
//关闭按钮
@property (nonatomic, strong) UIBarButtonItem *closeItem;

//下面的三个属性是添加进度条的
@property (nonatomic, assign) BOOL theBool;
@property (nonatomic, strong) UIProgressView *progressView;
@property (nonatomic, strong) NSTimer *timer;

@end

@implementation TCTennisNewsViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationController.navigationBar.barTintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    
    [self.navigationController.navigationBar setTitleTextAttributes:@{NSFontAttributeName:[UIFont systemFontOfSize:17],NSForegroundColorAttributeName:[UIColor whiteColor]}];
    
    //设置tabBarItem的颜色
    self.tabBarController.tabBar.tintColor = [UIColor colorWithRed:88.0/255.0 green:86.0/255.0 blue:214.0/255.0 alpha:1.0];
    NSString *js = @"document.getElementsByClassName(\"sinaHead\")[0].style.display = 'none';document.getElementsByClassName(\"-live-page-widget\")[0].style.display = 'none';document.getElementsByClassName(\"-live-page-widget\")[1].style.display = 'none';document.getElementsByClassName(\"-live-page-widget\")[2].style.display = 'none';document.getElementsByClassName(\"-live-page-widget\")[3].style.display = 'none';document.getElementsByClassName(\"p_list_tab_li\")[3].style.display = 'none',document.getElementsByClassName(\"footer\")[0].style.display = 'none'";
    WKUserScript *script = [[WKUserScript alloc] initWithSource:js injectionTime:WKUserScriptInjectionTimeAtDocumentEnd forMainFrameOnly:YES];
    WKWebViewConfiguration *config = [[WKWebViewConfiguration alloc] init];
    [config.userContentController addUserScript:script];
    
    self.webView = [[WKWebView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, self.view.frame.size.height) configuration:config];
    self.webView.UIDelegate = self;
    self.webView.navigationDelegate = self;
    [self.webView loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:@"http://tennis.sina.cn/?vt=4&pos=10&wm=5312_0010"]]];
    [self.view addSubview:self.webView];
    [self addLeftButton];
    
    //添加进度条（如果没有需要，可以注释掉
    [self addProgressBar];
    // Do any additional setup after loading the view.
}

- (IBAction)refresh:(UIBarButtonItem *)sender {
    [self.webView reload];
}

#pragma mark - 添加关闭按钮

- (void)addLeftButton {
    self.navigationItem.leftBarButtonItem = self.backItem;
}

#pragma mark - init

- (UIBarButtonItem *)backItem {
    if (!_backItem) {
        _backItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"] style:UIBarButtonItemStylePlain target:self action:@selector(backNative)];
    }
    return _backItem;
}

//点击返回的方法
- (void)backNative {
    //判断是否有上一层H5页面
    if ([self.webView canGoBack]) {
        //如果有则返回
        [self.webView goBack];
        self.navigationItem.leftBarButtonItem = self.backItem;
    } else {
        [self closeNative];
    }
}

//关闭H5页面，直接回到原生页面
- (void)closeNative {
    [self.navigationController popViewControllerAnimated:YES];
}

#pragma mark - 下面所有的方法是添加进度条

- (void)addProgressBar {
    // 仿微信进度条
    CGFloat progressBarHeight = 5.0f;
    CGRect navigationBarBounds = self.navigationController.navigationBar.bounds;
    CGRect barFrame = CGRectMake(0, navigationBarBounds.size.height - progressBarHeight, navigationBarBounds.size.width, progressBarHeight);
    self.progressView = [[UIProgressView alloc] initWithFrame:barFrame];
    self.progressView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    self.progressView.trackTintColor = [UIColor grayColor]; //背景色
    self.progressView.progressTintColor = [UIColor redColor]; //进度色
    [self.navigationController.navigationBar addSubview:self.progressView];
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:animated];
    //移除progressView  because UINavigationBar is shared with other ViewControllers
    [self.progressView removeFromSuperview];
}

- (void)webView:(WKWebView *)webView didStartProvisionalNavigation:(WKNavigation *)navigation {
    self.progressView.progress = 0;
    self.theBool = false;
    //0.01667 is roughly 1/60, so it will update at 60 FPS
    self.timer = [NSTimer scheduledTimerWithTimeInterval:0.01667 target:self selector:@selector(timerCallback) userInfo:nil repeats:YES];
}

- (void)webView:(WKWebView *)webView didFinishNavigation:(WKNavigation *)navigation {
    self.theBool = true; //加载完毕后，进度条完成
}

- (void)timerCallback {
    if (self.theBool) {
        if (self.progressView.progress >= 1) {
            self.progressView.hidden = true;
            [self.timer invalidate];
        } else {
            self.progressView.progress += 0.1;
        }
    } else {
        self.progressView.progress += 0.1;
        if (self.progressView.progress >= 0.9) {
            self.progressView.progress = 0.9;
        }
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
