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
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <ObjectiveDropboxOfficial.h>

@interface ViewController ()

@property (weak, nonatomic) IBOutlet FBSDKProfilePictureView *fbProfileView;
@property (weak, nonatomic) IBOutlet UILabel *fbProfileName;

@property (weak, nonatomic) IBOutlet UIButton *basicDataButton;
@property (weak, nonatomic) IBOutlet UIButton *inventoryButton;
@property (weak, nonatomic) IBOutlet UIButton *purchaseButton;
@property (weak, nonatomic) IBOutlet UIButton *saleButton;
@property (weak, nonatomic) IBOutlet UIButton *setupButton;

@end

@implementation ViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.basicDataButton.layer.borderWidth = 1;
    self.inventoryButton.layer.borderWidth = 1;
    self.purchaseButton.layer.borderWidth = 1;
    self.saleButton.layer.borderWidth = 1;
    self.setupButton.layer.borderWidth = 1;
    
    self.basicDataButton.layer.borderColor = self.view.tintColor.CGColor;
    self.inventoryButton.layer.borderColor = self.view.tintColor.CGColor;
    self.purchaseButton.layer.borderColor = self.view.tintColor.CGColor;
    self.saleButton.layer.borderColor = self.view.tintColor.CGColor;
    self.setupButton.layer.borderColor = self.view.tintColor.CGColor;
    
    self.basicDataButton.layer.cornerRadius = 20;
    self.inventoryButton.layer.cornerRadius = 20;
    self.purchaseButton.layer.cornerRadius = 20;
    self.saleButton.layer.cornerRadius = 20;
    self.setupButton.layer.cornerRadius = 20;
    
    dispatch_async(dispatch_get_main_queue(),
    ^{
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        if (appDLG.isLogin != YES)
        {
            WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
            [self presentViewController:wvc animated:YES completion:nil];
        }
    });
}

-(void)viewWillAppear:(BOOL)animated
{
    [FBSDKAppEvents activateApp];
    [FBSDKProfile enableUpdatesOnAccessTokenChange:YES];
    NSLog(@"===========%@",[FBSDKProfile currentProfile]);
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
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
}


@end
