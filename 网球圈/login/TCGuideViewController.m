//
//  TCGuideViewController.m
//  网球圈
//
//  Created by kozon on 2017/3/10.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "TCGuideViewController.h"
#import "TCLogonViewController.h"
#define NUM 3

@interface TCGuideViewController ()<UIScrollViewDelegate>

@property (weak, nonatomic) IBOutlet UIPageControl *pageControl;
@property (weak, nonatomic) IBOutlet UIButton *startButton;
@property (strong, nonatomic) UIScrollView *scrollView;

@end

@implementation TCGuideViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.scrollView = [[UIScrollView alloc]initWithFrame:self.view.bounds];
    [self.scrollView setPagingEnabled:YES];
    self.scrollView.showsHorizontalScrollIndicator = NO;
    self.scrollView.showsVerticalScrollIndicator = NO;
    self.scrollView.scrollsToTop = NO;
    self.scrollView.bounces = NO;
    self.scrollView.contentOffset = CGPointZero;
    
    self.scrollView.contentSize = CGSizeMake(self.view.bounds.size.width*NUM, self.view.bounds.size.height);
    self.scrollView.delegate = self;
    
    NSInteger i;
    for (i = 0; i < NUM; i++) {
        NSString *imgName = [NSString stringWithFormat:@"intro%ld", i+1];
        UIImage *image = [UIImage imageNamed:imgName];
        UIImageView *imageView = [[UIImageView alloc]initWithImage:image];
        CGRect frame = CGRectZero;
        frame.origin.x = i * self.scrollView.frame.size.width;
        frame.size = self.scrollView.frame.size;
        imageView.frame = frame;
        [self.scrollView addSubview:imageView];
    }
    [self.view insertSubview:self.scrollView atIndex:0];
    
    self.startButton.layer.cornerRadius = 15.0;
    self.startButton.alpha = 0.0;
    
    
    
    // Do any additional setup after loading the view.
}

- (BOOL)prefersStatusBarHidden {
    return YES;
}

// scrollView 已经滑动
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    CGPoint offset = self.scrollView.contentOffset;
    self.pageControl.currentPage = (int)offset.x / self.view.bounds.size.width;
    
    if (self.pageControl.currentPage == NUM - 1) {
        [UIView animateWithDuration:0.5 animations:^{
            self.startButton.alpha = 1.0;
        }];
    } else {
        [UIView animateWithDuration:0.2 animations:^{
            self.startButton.alpha = 0.0;
        }];
    }
}

- (IBAction)start:(UIButton *)sender {
    TCLogonViewController *TCIVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TCLogonViewController"];
    [self presentViewController:TCIVC animated:YES completion:nil];
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
