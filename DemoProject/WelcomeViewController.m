//
//  WelcomeViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/25.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "WelcomeViewController.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "ViewController.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "AlertManager.h"
#import "Member.h"

@interface WelcomeViewController () <FBSDKLoginButtonDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UITextField *userIDInput;
@property (weak, nonatomic) IBOutlet UITextField *userPWInput;
@property (nonatomic) AppDelegate *appDLG;
@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.fbLoginButton.delegate = self;
    self.userIDInput.delegate = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    if([FBSDKAccessToken currentAccessToken])
    {
        //這時還抓不到ID是嗎.....
        self.appDLG.currentUserID = [FBSDKProfile currentProfile].userID;
        self.appDLG.currentUserName = [FBSDKProfile currentProfile].name;
        self.appDLG.loginType = @"FaceBook";
        [self login];
    }
}

-(void)login
{
    self.appDLG.isLogin = YES;
    if ([self isSignup] == YES)
    {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

-(BOOL)isSignup
{
    //檢查有無user資料
    if ([DataBaseManager queryFromCoreData:@"MemberEntity" sortBy:@"memberID"].count == 0)
    {
        //寫資料
        if([self addMember:@"first"]==YES)
        {
            [self dismissViewControllerAnimated:YES completion:nil];
            [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為管理員\n若使用上有任何問題請來信lawmark33699@gmail.com\n謝謝" controller:self];
        }
        else
        {
            [AlertManager alert:@"無法註冊\n請聯絡系統管理員" controller:self];
        }
    }
    else
    {
        NSArray *memberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.appDLG.currentUserID];
        //檢查這個User有無註冊過了
        if (memberArray.count == 0)
        {
            if([self addMember:@"other"]==YES)
            {
                [self dismissViewControllerAnimated:YES completion:nil];
                [AlertManager alert:@"歡迎使用店店三碗公\n已幫您註冊為會員\n請待管理員審核後登入\n若使用上有任何問題請來信lawmark33699@gmail.com\n謝謝" controller:self];
            }
            else
            {
                [AlertManager alert:@"無法註冊\n請聯絡系統管理員" controller:self];
            }
        }
        else
        {
            Member *getMember = memberArray[0];
            //再檢查審核過了沒？
            if (getMember.memberApproved != YES)
            {
                [AlertManager alert:@"您的帳號尚未審核\n請通知管理員\n謝謝" controller:self];
            }
            //註冊通過
            else
            {
                self.appDLG.isSignup = YES;
                return YES;
            }
        }
    }
    return NO;
}

//已經先確認沒有找到ID(就代表沒有重複)才來執行這個方法
-(BOOL)addMember:(NSString*)type
{
    if (self.appDLG.currentUserID != nil)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Member *addMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberEntity" inManagedObjectContext:helper.managedObjectContext];
        addMember.memberID = self.appDLG.currentUserID;
        addMember.memberName = self.appDLG.currentUserName;
        addMember.memberType = self.appDLG.loginType;
        if ([type isEqualToString:@"first"])
        {
            addMember.memberApproved = YES;
        }
        [DataBaseManager updateToCoreData];
        return YES;
    }
    return NO;
}

- (IBAction)userLoginButton:(id)sender
{
    NSArray *memberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.userIDInput.text];
    if (memberArray.count == 0)
    {
        [AlertManager alert:@"查無帳號\n請重新輸入" controller:self];
        [self cleanTextFeild];
    }
    else
    {
        Member *checkMember = memberArray[0];
        if (checkMember.memberID==self.userIDInput.text && checkMember.memberPW==self.userPWInput.text)
        {
            if (checkMember.memberApproved != YES)
            {
                [AlertManager alert:@"您的帳號尚未審核\n請通知管理員\n謝謝" controller:self];
                [self cleanTextFeild];
            }
            else
            {
                self.appDLG.isLogin = YES;
                self.appDLG.isSignup = YES;
                self.appDLG.loginType = @"inside";
                self.appDLG.currentUserID = checkMember.memberID;
                self.appDLG.currentUserName = checkMember.memberName;
                self.appDLG.currentUserImg = [UIImage imageWithData:checkMember.memberImg];
                [self dismissViewControllerAnimated:YES completion:nil];
            }
        }
        else
        {
            [AlertManager alert:@"帳號密碼錯誤\n請重新輸入" controller:self];
            [self cleanTextFeild];
        }
    }
    
}

-(void)cleanTextFeild
{
    self.userIDInput.text = @"";
    self.userPWInput.text = @"";
    [self.userIDInput becomeFirstResponder];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
