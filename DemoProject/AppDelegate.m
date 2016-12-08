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
    else if ([[url scheme] isEqualToString:@"db-earyyjijj6zq965"])
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
            NSLog(@"DropBox ErrorType:%ld, Error:%@",(long)authResilt.errorType,authResilt.errorDescription);
        }
    }
    return nil;
}


//APP啟動完了呼叫
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    self.window.backgroundColor = [UIColor whiteColor];
    NSLog(@"===============\n\n\n\n\n%@\n\n\n\n\n===============",NSHomeDirectory());
    [[FBSDKApplicationDelegate sharedInstance] application:application didFinishLaunchingWithOptions:launchOptions];
    [DropboxClientsManager setupWithAppKey:@"earyyjijj6zq965"];
    [FIRApp configure];
    [Fabric with:@[[Crashlytics class]]];
    
    //啟用Token更新 藉此更新個人資料 (Token為用來跟FB認證user的一串文字,但不是userID)
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
