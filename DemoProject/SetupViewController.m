//
//  SetupViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/28.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "SetupViewController.h"
#import "FBLogoutCell.h"
#import "DropBoxCell.h"
#import "UserCell.h"
#import "AppDelegate.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>
#import "WelcomeViewController.h"
#import <ObjectiveDropboxOfficial.h>
#import "AlertManager.h"

@interface SetupViewController () <UITableViewDelegate,UITableViewDataSource,FBSDKLoginButtonDelegate>
@property (weak, nonatomic) IBOutlet UITableView *steupTableView;
@property DropboxClient *dbClient;
@end

@implementation SetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.steupTableView.delegate = self;
    self.steupTableView.dataSource = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferWVC) name:FBSDKProfileDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbBackupOK" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
     {
         NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
         NSString *dbPath1 = [homePath stringByAppendingPathComponent:@"System.sqlite"];
         NSString *dbPath2 = [homePath stringByAppendingPathComponent:@"System.sqlite-shm"];
         NSString *dbPath3 = [homePath stringByAppendingPathComponent:@"System.sqlite-wal"];
         NSData *dbData1 = [NSData dataWithContentsOfFile:dbPath1];
         NSData *dbData2 = [NSData dataWithContentsOfFile:dbPath2];
         NSData *dbData3 = [NSData dataWithContentsOfFile:dbPath3];
         
         DBUploadTask *task1 = [self.dbClient.filesRoutes uploadData:@"/System.sqlite" inputData:dbData1];
         [task1 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBError * _Nullable dberror)
          {
              if (md){
                  NSLog(@"1.OK");}
              else{
                  NSLog(@"1.%@%@",error,dberror);}
          }];
         DBUploadTask *task2 = [self.dbClient.filesRoutes uploadData:@"/System.sqlite-shm" inputData:dbData2];
         [task2 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBError * _Nullable dberror)
          {
              if (md){
                  NSLog(@"2.OK");}
              else{
                  NSLog(@"2.%@%@",error,dberror);}
          }];
         DBUploadTask *task3 = [self.dbClient.filesRoutes uploadData:@"/System.sqlite-wal" inputData:dbData3];
         [task3 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBError * _Nullable dberror)
          {
              if (md){
                  NSLog(@"3.OK");}
              else{
                  NSLog(@"3.%@%@",error,dberror);}
          }];
     }];
}

-(void)transferWVC
{
    if(![FBSDKAccessToken currentAccessToken])
    {
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        appDLG.isLogin = NO;
        WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
        [self presentViewController:wvc animated:YES completion:nil];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return 1;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            UserCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"userCell"];
            [userCell.userLogoutButton addTarget:self action:@selector(userDidLogOut) forControlEvents:UIControlEventTouchUpInside];
            return userCell;
            break;
        }
        case 1:
        {
            FBLogoutCell *fbLogoutCell = [tableView dequeueReusableCellWithIdentifier:@"fbCell"];
            [fbLogoutCell.fbLogoutButton addTarget:self action:@selector(loginButtonDidLogOut:) forControlEvents:UIControlEventTouchUpInside];
            return fbLogoutCell;
            break;
        }
        case 2:
        {
            DropBoxCell *dropboxCell = [tableView dequeueReusableCellWithIdentifier:@"dbCell"];
            [dropboxCell.dbBackupIcon addTarget:self action:@selector(dropboxBackup) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbBackupButton addTarget:self action:@selector(dropboxBackup) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreIcon addTarget:self action:@selector(dropboxRestore) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreButton addTarget:self action:@selector(dropboxRestore) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbLogoutButton addTarget:self action:@selector(dropboxLogout) forControlEvents:UIControlEventTouchUpInside];
            return dropboxCell;
            break;
        }
        default:
            break;
    }
    return nil;
}

-(void)loginButton:(FBSDKLoginButton *)loginButton didCompleteWithResult:(FBSDKLoginManagerLoginResult *)result error:(NSError *)error
{
}

-(void)loginButtonDidLogOut:(FBSDKLoginButton *)loginButton
{
}

-(BOOL)isDropboxDidLogin
{
    //先確認是否已登入,auth==nil就是沒認證
    if ([DropboxClientsManager authorizedClient] == nil)
    {
        [DropboxClientsManager authorizeFromController:[UIApplication sharedApplication] controller:self openURL:^(NSURL * _Nonnull url)
         {
             [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
         } browserAuth:NO];
        //為何離開db登入頁面 不管登入與否 都會回到CenterViewController(把起始頁指回centerVC就好了)
        return NO;
    }
    else
    {
        //有認證就拿來用
        self.dbClient = [DropboxClientsManager authorizedClient];
        return YES;
    }
    return nil;
}

-(void)dropboxBackup
{
    if ([self isDropboxDidLogin])
    {
        [AlertManager alertYesAndNo:@"請確認是否備份至Dropbox並覆蓋舊檔？" yes:@"是" no:@"否" controller:self];
    }
}

-(void)dropboxRestore
{
    
}

-(void)dropboxLogout
{
    if ([DropboxClientsManager authorizedClient] != nil)
    {
        [DropboxClientsManager unlinkClients];
        [AlertManager alert:@"您已登出DropBox" controller:self];
    }
    else
    {
        [AlertManager alert:@"您尚未登入DropBox" controller:self];
    }
}

-(void)userDidLogOut
{
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDLG.isLogin = NO;
    WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
    [self presentViewController:wvc animated:YES completion:nil];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
