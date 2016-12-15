//
//  AppDelegate.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AppDelegate : UIResponder <UIApplicationDelegate>
@property (strong, nonatomic) UIWindow *window;
@property BOOL isLogin;
@property BOOL isSignup;
@property NSString *loginType;
@property NSString *currentUserID;
@property NSString *currentUserName;
@property UIImage *currentUserImg;
@end

