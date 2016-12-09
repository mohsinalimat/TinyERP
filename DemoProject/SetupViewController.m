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
@property NSString *dbSelectedFolderName;
@property NSArray *fileNameArray;
@property NSString *dbAction;
@end

@implementation SetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"系統設定";
    self.fileNameArray = @[@"System.sqlite",@"System.sqlite-shm",@"System.sqlite-wal"];
    self.steupTableView.delegate = self;
    self.steupTableView.dataSource = self;
    self.dbRestorePicker.delegate = self;
    self.dbRestorePicker.dataSource = self;
    [self.dbRestorePicker setHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferWVC) name:FBSDKProfileDidChangeNotification object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dbBackupOrRestore) name:@"dbLoginSuccess" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showDBRestorePicker) name:@"dbDownloadOver" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbBackupOK" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
     {
         NSDateFormatter *df = [[NSDateFormatter alloc]init];
         [df setDateFormat:@"yyMMdd_HHmmss"];
         NSString *backupDateString = [df stringFromDate:[NSDate date]];
         NSArray *dataArray = @[
         [NSData dataWithContentsOfFile:[self getLocalDBArray][0]],
         [NSData dataWithContentsOfFile:[self getLocalDBArray][1]],
         [NSData dataWithContentsOfFile:[self getLocalDBArray][2]],
         ];
         
         for (NSString *fileName in self.fileNameArray)
         {
             NSInteger index = [self.fileNameArray indexOfObject:fileName];
              NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@",backupDateString,fileName];
              DBUploadTask *task = [self.dbClient.filesRoutes uploadData:uploadPath inputData:dataArray[index]];
              [task response:^(DBFILESMetadata* _Nullable md, DBFILESUploadError* _Nullable error, DBRequestError* _Nullable dberror)
               {
                   if (md)
                   {
                       NSLog(@"%ld.OK",index);
                   }
                   else
                   {
                       NSLog(@"%ld.%@%@",index,error,dberror);
                   }
               }];
         }
     }];
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbRestoreSelected" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
    {
        [self deleteLocalDB];
        for (NSString *fileName in self.fileNameArray)
        {
            NSString *dbRestorePath = [NSString stringWithFormat:@"/%@/%@",self.dbSelectedFolderName,fileName];
            DBDownloadDataTask *task = [self.dbClient.filesRoutes downloadData:dbRestorePath];
            [task response:^(DBFILESMetadata* _Nullable md, DBFILESDownloadError* _Nullable dberror, DBRequestError* _Nullable error, NSData* _Nonnull data)
             {
                 if (data)
                 {
                     NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
                     NSString *filePath = [homePath stringByAppendingPathComponent:fileName];
                     NSFileManager *fileManager = [NSFileManager defaultManager];
                     BOOL isSuccess = [fileManager createFileAtPath:filePath contents:data attributes:nil];
                     if (isSuccess)
                     {
                         NSLog(@"%ld.create success",[self.fileNameArray indexOfObject:fileName]);
                     }
                     else
                     {
                         NSLog(@"%ld.create fail",[self.fileNameArray indexOfObject:fileName]);
                     }
                 }
             }];
        }
    }];
     
}

-(NSArray*)getLocalDBArray
{
    NSString *homePath = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents"];
    NSString *dbPath1 = [homePath stringByAppendingPathComponent:self.fileNameArray[0]];
    NSString *dbPath2 = [homePath stringByAppendingPathComponent:self.fileNameArray[1]];
    NSString *dbPath3 = [homePath stringByAppendingPathComponent:self.fileNameArray[2]];
    NSArray *localDBArray = @[dbPath1,dbPath2,dbPath3];
    return localDBArray;
}

-(void)deleteLocalDB
{
    NSFileManager *fileManager = [NSFileManager defaultManager];
    NSArray *localDBArray = [self getLocalDBArray];
    for (NSString *dbPath in localDBArray)
    {
        BOOL isSuccess = [fileManager removeItemAtPath:dbPath error:nil];
        if (isSuccess)
        {
            NSLog(@"%ld.delete success",[localDBArray indexOfObject:dbPath]);
        }
        else
        {
            NSLog(@"%ld.delete fail",[localDBArray indexOfObject:dbPath]);
        }
    }
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
            [dropboxCell.dbBackupIcon addTarget:self action:@selector(dropboxBackupButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbBackupButton addTarget:self action:@selector(dropboxBackupButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreIcon addTarget:self action:@selector(dropboxRestoreButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreButton addTarget:self action:@selector(dropboxRestoreButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbLogoutButton addTarget:self action:@selector(dropboxLogoutButton) forControlEvents:UIControlEventTouchUpInside];
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

-(void)dbBackupOrRestore
{
    if ([self.dbAction isEqualToString:@"Backup"])
    {
        [self dropboxBackupAction];
    }
    else if ([self.dbAction isEqualToString:@"Restore"])
    {
        [self dropboxRestoreAction];
    }
}

-(void)dropboxBackupButton
{
    self.dbAction = @"Backup";
    if ([self isDropboxDidLogin])
    {
        [self dropboxBackupAction];
    }
}

-(void)dropboxBackupAction
{
    [AlertManager alertYesAndNo:@"請確認是否備份至Dropbox\n產生新的資料紀錄？" yes:@"是" no:@"否" controller:self postNotificationName:@"dbBackupOK"];
}

-(void)dropboxRestoreButton
{
    self.dbAction = @"Restore";
    if ([self isDropboxDidLogin])
    {
        [self dropboxRestoreAction];
    }
}

-(void)dropboxRestoreAction
{
    if (self.dbRestoreList == nil)
    {
        self.dbRestoreList = [NSMutableArray new];
    }
    else
    {
        [self.dbRestoreList removeAllObjects];
    }
    
    DBRpcTask *task = [self.dbClient.filesRoutes listFolder:@""];
    [task response:^(DBFILESListFolderResult* _Nullable result, DBFILESListFolderError* _Nullable error, DBRequestError* _Nullable dberror)
     {
         for (DBFILESMetadata *md in result.entries)
         {
             NSLog(@"======%@",md.name);
             [self.dbRestoreList addObject:md.name];
         }
         [[NSNotificationCenter defaultCenter] postNotificationName:@"dbDownloadOver" object:nil];
     }];
}

-(void)showDBRestorePicker
{
    [self.dbRestorePicker setHidden:NO];
    [self.dbRestorePicker reloadAllComponents];
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
    self.dbSelectedFolderName = [self.dbRestoreList objectAtIndex:row];
    NSString *message = [NSString stringWithFormat:@"您選擇的是%@的檔案\n請確認是否從Dropbox還原\n覆蓋現有資料",self.dbSelectedFolderName];
    [AlertManager alertYesAndNo:message yes:@"是" no:@"否" controller:self postNotificationName:@"dbRestoreSelected"];
}

-(void)dropboxLogoutButton
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


- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
