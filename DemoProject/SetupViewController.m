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

@interface SetupViewController () <UITableViewDelegate,UITableViewDataSource,FBSDKLoginButtonDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *steupTableView;
@property (weak, nonatomic) IBOutlet UIPickerView *dbRestorePicker;
@property (nonatomic) NSMutableArray *dbRestoreList;
@property DropboxClient *dbClient;
@end

@implementation SetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.steupTableView.delegate = self;
    self.steupTableView.dataSource = self;
    self.dbRestorePicker.delegate = self;
    self.dbRestorePicker.dataSource = self;
    [self.dbRestorePicker setHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferWVC) name:FBSDKProfileDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbBackupOK" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
     {
         NSDateFormatter *df = [[NSDateFormatter alloc]init];
         [df setDateFormat:@"yyMMdd_hhmmss"];
         NSString *backupDateString = [df stringFromDate:[NSDate date]];
         NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
         NSString *dbPath1 = [homePath stringByAppendingPathComponent:@"System.sqlite"];
         NSString *dbPath2 = [homePath stringByAppendingPathComponent:@"System.sqlite-shm"];
         NSString *dbPath3 = [homePath stringByAppendingPathComponent:@"System.sqlite-wal"];
         NSData *dbData1 = [NSData dataWithContentsOfFile:dbPath1];
         NSData *dbData2 = [NSData dataWithContentsOfFile:dbPath2];
         NSData *dbData3 = [NSData dataWithContentsOfFile:dbPath3];
         
         NSString *uploadPath1 = [NSString stringWithFormat:@"/%@/System.sqlite",backupDateString];
         DBUploadTask *task1 = [self.dbClient.filesRoutes uploadData:uploadPath1 inputData:dbData1];
         [task1 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBRequestError* _Nullable dberror)
          {
              if (md){
                  NSLog(@"1.OK");}
              else{
                  NSLog(@"1.%@%@",error,dberror);}
          }];
         NSString *uploadPath2 = [NSString stringWithFormat:@"/%@/System.sqlite-shm",backupDateString];
         DBUploadTask *task2 = [self.dbClient.filesRoutes uploadData:uploadPath2 inputData:dbData2];
         [task2 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBRequestError* _Nullable dberror)
          {
              if (md){
                  NSLog(@"2.OK");}
              else{
                  NSLog(@"2.%@%@",error,dberror);}
          }];
         NSString *uploadPath3 = [NSString stringWithFormat:@"/%@/System.sqlite-wal",backupDateString];
         DBUploadTask *task3 = [self.dbClient.filesRoutes uploadData:uploadPath3 inputData:dbData3];
         [task3 response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBRequestError* _Nullable dberror)
          {
              if (md){
                  NSLog(@"3.OK");}
              else{
                  NSLog(@"3.%@%@",error,dberror);}
          }];
     }];
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbRestoreSelected" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
    {
        NSLog(@"");
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
        [AlertManager alertYesAndNo:@"請確認是否備份至Dropbox\n產生新的資料紀錄？" yes:@"是" no:@"否" controller:self];
    }
}

-(void)dropboxRestore
{
    if ([self isDropboxDidLogin])
    {
        if (self.dbRestoreList == nil)
        {
            self.dbRestoreList = [NSMutableArray new];
        }
        else
        {
            [self.dbRestoreList removeAllObjects];
        }
        
        [[[self.dbClient.filesRoutes downloadData:@"/店店三碗公/161206_053831"]
          response:^(DBFILESFileMetadata *result, DBFILESDownloadError *routeError, DBRequestError *error, NSData *fileContents) {
              if (result) {
                  NSLog(@"%@\n", result);
                  NSString *dataStr = [[NSString alloc]initWithData:fileContents encoding:NSUTF8StringEncoding];
                  NSLog(@"%@\n", dataStr);
              } else {
                  NSLog(@"%@\n%@\n", routeError, error);
              }
          }] progress:^(int64_t bytesDownloaded, int64_t totalBytesDownloaded, int64_t totalBytesExpectedToDownload) {
              NSLog(@"%lld\n%lld\n%lld\n", bytesDownloaded, totalBytesDownloaded, totalBytesExpectedToDownload);
          }];

//        DBRpcTask *task = [self.dbClient.filesRoutes listFolder:@""];
//        [task response:^(DBFILESListFolderResult* _Nullable result, DBFILESListFolderError* _Nullable error, DBRequestError* _Nullable dberror)
//        {
//            for (DBFILESMetadata *md in result.entries)
//            {
//                NSLog(@"======%@",md.name);
//                [self.dbRestoreList addObject:md.name];
//            }
//        }];
    
        [self.dbRestorePicker setHidden:NO];
    }
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dbRestoreList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *dbRestoreName = [self.dbRestoreList objectAtIndex:row];
    return dbRestoreName;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSString *selectedName = [self.dbRestoreList objectAtIndex:row];
    NSString *message = [NSString stringWithFormat:@"您選擇的是%@的檔案\n請確認是否從Dropbox還原\n覆蓋現有資料",selectedName];
    [AlertManager alertYesAndNo:message yes:@"是" no:@"否" controller:self];
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
