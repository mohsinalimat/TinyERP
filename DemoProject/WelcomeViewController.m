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

@interface WelcomeViewController () <FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLoginButton;
@property (weak, nonatomic) IBOutlet UITextField *userIDInput;
@property (weak, nonatomic) IBOutlet UITextField *userPWInput;
@end

@implementation WelcomeViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.fbLoginButton.delegate = self;
}

//只要一登入 就會刷新頁面
-(void)viewWillAppear:(BOOL)animated
{
//  //取得最基本的三個權限
    //開關無法登入問題依舊
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
//
    //啟用Token更新 藉此更新個人資料 (Token為用來跟FB認證user的一串文字,但不是userID)
//    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    //這行放這邊,不放在SetupViewController,是因為這樣才會找到原本的WVC物件,不然會被navigate納入控管,又可回上頁
//    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferWVC) name:FBSDKProfileDidChangeNotification object:nil];
    
//    if ([FBSDKProfile currentProfile])
//    {
//        UINavigationController *centerNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"centerNVC"];
//        [self addChildViewController:centerNVC];
//        [self.view addSubview:centerNVC.view];
//    }
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    //再呼叫這個
    if([FBSDKAccessToken currentAccessToken])
    {
        [self didLogin];
        [self dismissViewControllerAnimated:YES completion:nil];
//        UINavigationController *centerNVC = [self.storyboard instantiateViewControllerWithIdentifier:@"centerNVC"];
//        [self addChildViewController:centerNVC];
//        [self.view addSubview:centerNVC.view];
    }
}

//-(void)transferWVC
//{
//    if ([FBSDKAccessToken currentAccessToken] == nil)
//    {
//        WelcomeViewController *welcomeVC = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
//        [self addChildViewController:welcomeVC];
//        [self.view addSubview:welcomeVC.view];
//    }
//}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
    NSLog(@"我不會在這邊登出");
}

- (IBAction)userLoginButton:(id)sender
{
    [self didLogin];
    [self dismissViewControllerAnimated:YES completion:nil];
}

- (IBAction)userSignupButton:(id)sender
{
    
}

-(void)didLogin
{
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDLG.isLogin = YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
