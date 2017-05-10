//
//  AppDelegate.m
//  网球圈
//
//  Created by kozon on 2017/2/26.
//  Copyright © 2017年 Kozon app. All rights reserved.
//

#import "AppDelegate.h"
#import <TencentOpenAPI/TencentOAuth.h>
#import "WXApi.h"
#import <BmobSDK/Bmob.h>

@interface AppDelegate ()<WXApiDelegate>

@end

@implementation AppDelegate


- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    // Override point for customization after application launch.
    
    self.window.backgroundColor = [UIColor whiteColor];
    
    [WXApi registerApp:@"wx4868b35061f87885"];
    [Bmob registerWithAppKey:@"1ff6bb83e416c1d3568297d47ee57850"];
    //1 获取当前版本号
    NSString *currentVersion = [NSBundle mainBundle].infoDictionary[@"CFBundleShortVersionString"];
    
    //2 获取上一次的版本号
    NSString *lastVersion = [[NSUserDefaults standardUserDefaults] objectForKey:@"appVersion"];
    
    if ((currentVersion != lastVersion) || lastVersion == nil) {//没有最新的版本号
        //保存当前版本号，用偏好设置
        [[NSUserDefaults standardUserDefaults] setObject:currentVersion forKey:@"appVersion"];
        [[NSUserDefaults standardUserDefaults] synchronize];
        
    }
    
    return YES;
}

//openURL:
- (BOOL)application:(UIApplication *)application openURL:(NSURL *)url sourceApplication:(NSString *)sourceApplication annotation:(id)annotation{
    return [TencentOAuth HandleOpenURL:url];
}

//handleOpenURL:
- (BOOL)application:(UIApplication *)application handleOpenURL:(NSURL *)url{
    [TencentOAuth HandleOpenURL:url];
    [WXApi handleOpenURL:url delegate:self];
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and invalidate graphics rendering callbacks. Games should use this method to pause the game.
}


- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}


- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the active state; here you can undo many of the changes made on entering the background.
}


- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}


- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}


@end
