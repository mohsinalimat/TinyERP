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
@property (weak, nonatomic) IBOutlet UILabel *welcomeWord;
@property (nonatomic) AppDelegate *appDLG;
@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.fbLoginButton.delegate = self;
    self.userIDInput.delegate = self;
    self.userPWInput.delegate = self;
//    CGFloat h = self.welcomeWord.frame.size.height;
//    CGFloat w = self.welcomeWord.frame.size.width;
//    UILabel *appName = [[UILabel alloc]initWithFrame:CGRectMake(0, 0, w, h)];
//    appName.text = @"店店三碗公";
//    NSLayoutConstraint *xCenterConstraint = [NSLayoutConstraint constraintWithItem:appName attribute:NSLayoutAttributeCenterX relatedBy:NSLayoutRelationEqual toItem:self.welcomeWord attribute:NSLayoutAttributeCenterX multiplier:1.0 constant:0];
//    NSLayoutConstraint *yCenterConstraint = [NSLayoutConstraint constraintWithItem:appName attribute:NSLayoutAttributeCenterY relatedBy:NSLayoutRelationEqual toItem:self.welcomeWord attribute:NSLayoutAttributeCenterY multiplier:1.0 constant:0];
//    [appName addConstraints:@[xCenterConstraint,yCenterConstraint]];
//    [self.welcomeWord addSubview:appName];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(helloFB) name:FBSDKProfileDidChangeNotification object:nil];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

-(void)helloFB
{
    NSLog(@"FBSDKProfileDidChangeNotification,WelcomeVC,helloFB");
    self.appDLG.currentUserID = [FBSDKProfile currentProfile].userID;
    self.appDLG.currentUserName = [FBSDKProfile currentProfile].name;
    self.appDLG.loginType = @"FaceBook";
    if (self.appDLG.currentUserID != nil)
    {
        [self login];
    }
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
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
        [self addMember:@"first"];
        [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為管理員\n若使用上有任何問題\n請至https://www.facebook.com/mark.storeapp反應\n謝謝" controller:self command:@"dismissViewController"];
    }
    else
    {
        NSArray *memberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.appDLG.currentUserID];
        //檢查這個User有無註冊過了
        if (memberArray.count == 0)
        {
            [self addMember:@"other"];
            [AlertManager alert:@"歡迎使用店店三碗公\n已幫您註冊為會員\n請待管理員審核後登入\n若使用上有任何問題\n請至https://www.facebook.com/mark.storeapp反應\n謝謝" controller:self];
        }
        else
        {
            Member *getMember = memberArray[0];
            //再檢查審核過了沒？
            if (getMember.memberApproved != YES)
            {
                [AlertManager alert:@"您的帳號尚未審核\n請通知管理員\n謝謝" controller:self];
                self.appDLG.isSignup = NO;
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
-(void)addMember:(NSString*)type
{
    if (self.appDLG.currentUserID != nil)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Member *addMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberEntity" inManagedObjectContext:helper.managedObjectContext];
        addMember.memberID = self.appDLG.currentUserID;
        addMember.memberName = self.appDLG.currentUserName;
        addMember.memberType = self.appDLG.loginType;
        addMember.memberApproved = NO;
        addMember.memberClass = @"未分類";
        if ([type isEqualToString:@"first"])
        {
            addMember.memberApproved = YES;
            addMember.memberClass = @"admin";
        }
        [DataBaseManager updateToCoreData];
        NSArray *getMemberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.appDLG.currentUserID];
        if (getMemberArray.count != 0)
        {
            self.appDLG.currentMember = getMemberArray[0];
        }
    }
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
        NSData *plainData = [[NSData alloc] initWithBase64EncodedString:checkMember.memberPW options:0];
        NSString *plainText = [[NSString alloc] initWithData:plainData encoding:NSUTF8StringEncoding];
        if ([checkMember.memberID isEqualToString:self.userIDInput.text] && [plainText isEqualToString:self.userPWInput.text])
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
                self.appDLG.currentMember = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.appDLG.currentUserID][0];
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

//按Return縮鍵盤
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton;
{
    //沒有這個delegate method會報錯
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
