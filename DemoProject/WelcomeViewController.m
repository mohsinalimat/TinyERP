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

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    self.fbLoginButton.readPermissions = @[@"public_profile", @"email", @"user_friends"];
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
    if([FBSDKAccessToken currentAccessToken])
    {
        [self didLogin];
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}

//-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
//{
//    NSLog(@"我不會在這邊登出");
//}

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
