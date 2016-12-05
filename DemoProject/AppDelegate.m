//
//  AppDelegate.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "AppDelegate.h"
#import "DataBaseManager.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import <ObjectiveDropboxOfficial.h>
#import <Firebase.h>
#import <Fabric/Fabric.h>
#import <Crashlytics/Crashlytics.h>

@interface AppDelegate ()

@end

@implementation AppDelegate

//外部認證回來會呼叫
 -(BOOL)application:(UIApplication *)app openURL:(NSURL *)url options:(NSDictionary<UIApplicationOpenURLOptionsKey,id> *)options
{
    if ([[url scheme] isEqualToString:@"fb371593309861775"])
    {
        return [[FBSDKApplicationDelegate sharedInstance] application:app openURL:url sourceApplication:options[UIApplicationOpenURLOptionsSourceApplicationKey] annotation:options[UIApplicationOpenURLOptionsAnnotationKey]];
    }
    else if ([[url scheme] isEqualToString:@"db-wjpf7a0wt2kjbdh"])
    {
        DBOAuthResult *authResilt = [DropboxClientsManager handleRedirectURL:url];
        if (authResilt == nil)
        {
            return NO;
        }
        if ([authResilt isSuccess])
        {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"dbLoginSuccess" object:nil];
        }
        else if ([authResilt isError])
        {
            NSLog(@"ErrorType:%ld, Error:%@",(long)authResilt.errorType,authResilt.errorDescription);
        }
    }
    return nil;
}


//APP啟動完了呼叫
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [DropboxClientsManager setupWithAppKey:@"wjpf7a0wt2kjbdh"];
    [FIRApp configure];
    [Fabric with:@[[Crashlytics class]]];
    NSLog(@"%@",NSHomeDirectory());
    
    //啟用Token更新 藉此更新個人資料 (Token為用來跟FB認證user的一串文字,但不是userID)
    //開關無法登入問題依舊
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    
    if ([FBSDKProfile currentProfile])
    {
        self.isLogin = YES;
        self.loginType = @"FaceBook";
    }
    return YES;
}


- (void)applicationWillResignActive:(UIApplication *)application
{
    
}


- (void)applicationDidEnterBackground:(UIApplication *)application
{
    
}


- (void)applicationWillEnterForeground:(UIApplication *)application
{
    
}


- (void)applicationDidBecomeActive:(UIApplication *)application
{
    [FBSDKAppEvents activateApp];
}


- (void)applicationWillTerminate:(UIApplication *)application
{
    
}


@end
