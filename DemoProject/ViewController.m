//
//  ViewController.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "ViewController.h"
#import "OrderListViewController.h"
#import "WelcomeViewController.h"
#import "SetupViewController.h"
#import "AccountingListViewController.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ObjectiveDropboxOfficial.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *fbProfileView;
@property (weak, nonatomic) IBOutlet UILabel *fbProfileName;
@property (strong, nonatomic) IBOutletCollection(UIButton) NSArray *nineButton;
@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //放廣告 storyboard統一設定
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.automaticallyAdjustsScrollViewInsets = NO;
    self.navigationController.navigationBar.translucent = NO;
    //一開始先藏 怕還沒登入時被偷看到
    self.view.hidden=YES;
    //設定九個按鈕UI
    for (UIButton *btn in self.nineButton)
    {
        btn.layer.borderWidth = 1;
        btn.layer.borderColor = self.view.tintColor.CGColor;
        btn.layer.cornerRadius = 20;
    }
    //沒登入的話 秀登入畫面
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDLG.isLogin != YES)
    {
        WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeNC"];
        [self presentViewController:wvc animated:YES completion:nil];
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    if (appDLG.isLogin == YES)
    {
        [self.view setHidden:NO];
    }
    [FBSDKAppEvents activateApp];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    //已登入狀態 重啟APP 狀態不改 但還是要更新
    self.fbProfileView.profileID = [FBSDKProfile currentProfile].userID;
    self.fbProfileName.text = [FBSDKProfile currentProfile].name;
    //一登入 狀態改變 所以更新 不然這頁早已Appear 那時還沒登入 頭像名稱已固定
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(updateProfile) name:FBSDKProfileDidChangeNotification object:nil];
}

-(void)updateProfile
{
    self.fbProfileView.profileID = [FBSDKProfile currentProfile].userID;
    self.fbProfileName.text = [FBSDKProfile currentProfile].name;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"pSegue"])
    {
        OrderListViewController *olvc = segue.destinationViewController;
        olvc.whereFrom = @"pSegue";
    }
    else if ([segue.identifier isEqualToString:@"sSegue"])
    {
        OrderListViewController *olvc = segue.destinationViewController;
        olvc.whereFrom = @"sSegue";
    }
    else if ([segue.identifier isEqualToString:@"apSegue"])
    {
        AccountingListViewController *alvc = segue.destinationViewController;
        alvc.whereFrom = @"apSegue";
    }
    else if ([segue.identifier isEqualToString:@"arSegue"])
    {
        AccountingListViewController *alvc = segue.destinationViewController;
        alvc.whereFrom = @"arSegue";
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
