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
#import "Member.h"
#import "DataBaseManager.h"
#import "SignupViewController.h"

@interface SetupViewController () <UITableViewDelegate,UITableViewDataSource,FBSDKLoginButtonDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *steupTableView;
@property (weak, nonatomic) IBOutlet UIPickerView *dbRestorePicker;
@property (nonatomic) NSMutableArray *dbRestoreList;
@property DropboxClient *dbClient;
@property NSString *dbSelectedFolderName;
@property NSArray *fileNameArray;
@property NSString *dbAction;
@property AppDelegate *appDLG;
@end

@implementation SetupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    self.title = @"系統設定";
    self.fileNameArray = @[@"System.sqlite",@"System.sqlite-shm",@"System.sqlite-wal"];
    self.steupTableView.delegate = self;
    self.steupTableView.dataSource = self;
    self.dbRestorePicker.delegate = self;
    self.dbRestorePicker.dataSource = self;
    [self.dbRestorePicker setHidden:YES];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(userShouldLogout) name:@"userShouldLogoutYes" object:nil];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(transferWVC) name:FBSDKProfileDidChangeNotification object:nil];
    
    //1.
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(dbBackupOrRestore) name:@"dbLoginSuccess" object:nil];
    
    __weak SetupViewController *weakSelf = self;
    
    //2.1
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbBackupYes" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note)
     {
         //9.1
         NSDateFormatter *df = [[NSDateFormatter alloc]init];
         [df setDateFormat:@"yyMMdd_HHmmss"];
         NSString *backupDateString = [df stringFromDate:[NSDate date]];
         NSArray *dataArray = @[
         [NSData dataWithContentsOfFile:[weakSelf getLocalDBArray][0]],
         [NSData dataWithContentsOfFile:[weakSelf getLocalDBArray][1]],
         [NSData dataWithContentsOfFile:[weakSelf getLocalDBArray][2]],
         ];
         
         for (NSString *fileName in weakSelf.fileNameArray)
         {
             NSInteger index = [weakSelf.fileNameArray indexOfObject:fileName];
              NSString *uploadPath = [NSString stringWithFormat:@"/%@/%@",backupDateString,fileName];
              DBUploadTask *task = [weakSelf.dbClient.filesRoutes uploadData:uploadPath inputData:dataArray[index]];
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
    
    //2.2
    [[NSNotificationCenter defaultCenter]addObserverForName:@"dbRestoreSelectedYes" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note)
    {
        //7.2
        [weakSelf deleteLocalDB];
        for (NSString *fileName in weakSelf.fileNameArray)
        {
            NSString *dbRestorePath = [NSString stringWithFormat:@"/%@/%@",weakSelf.dbSelectedFolderName,fileName];
            DBDownloadDataTask *task = [weakSelf.dbClient.filesRoutes downloadData:dbRestorePath];
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
                         NSLog(@"%ld.create success",[weakSelf.fileNameArray indexOfObject:fileName]);
                     }
                     else
                     {
                         NSLog(@"%ld.create fail",[weakSelf.fileNameArray indexOfObject:fileName]);
                     }
                 }
            }];
         }
    }];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(showDBRestorePicker) name:@"dbDownloadOver" object:nil];
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
        WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeNC"];
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
    switch (section)
    {
        case 0:
            return 1;
            break;
        case 1:
            return 1;
            break;
        case 2:
            return 3;
            break;
        default:
            break;
    }
    return 0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.section)
    {
        case 0:
        {
            if ([self.appDLG.loginType isEqualToString:@"inside"])
            {
                UserCell *userCell = [tableView dequeueReusableCellWithIdentifier:@"userlogoutCell"];
                [userCell.userLogoutButton addTarget:self action:@selector(askUserLogOut) forControlEvents:UIControlEventTouchUpInside];
                return userCell;
                break;
            }
            else if ([self.appDLG.loginType isEqualToString:@"FaceBook"])
            {
                FBLogoutCell *fbLogoutCell = [tableView dequeueReusableCellWithIdentifier:@"fbCell"];
                [fbLogoutCell.fbLogoutButton addTarget:self action:@selector(loginButtonDidLogOut:) forControlEvents:UIControlEventTouchUpInside];
                return fbLogoutCell;
                break;
            }
        }
        case 1:
        {
            DropBoxCell *dropboxCell = [tableView dequeueReusableCellWithIdentifier:@"dbCell"];
            [dropboxCell.dbBackupIcon addTarget:self action:@selector(dropboxBackupButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbBackupButton addTarget:self action:@selector(dropboxBackupButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreIcon addTarget:self action:@selector(dropboxRestoreButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbRestoreButton addTarget:self action:@selector(dropboxRestoreButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbLogoutIcon addTarget:self action:@selector(dropboxLogoutButton) forControlEvents:UIControlEventTouchUpInside];
            [dropboxCell.dbLogoutButton addTarget:self action:@selector(dropboxLogoutButton) forControlEvents:UIControlEventTouchUpInside];
            return dropboxCell;
            break;
        }
        case 2:
        {
            switch (indexPath.row)
            {
                case 0:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"membersCell"];
                    cell.textLabel.text = @"   使用者管理";
                    cell.textLabel.textColor = self.view.tintColor;
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    return cell;
                    break;
                }
                case 1:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"profileCell"];
                    cell.textLabel.text = @"   個人資料";
                    cell.textLabel.textColor = self.view.tintColor;
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    return cell;
                    break;
                }
                case 2:
                {
                    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"signupCell"];
                    cell.textLabel.text = @"   新增使用者";
                    cell.textLabel.textColor = self.view.tintColor;
                    cell.textLabel.textAlignment = UITextAlignmentCenter;
                    return cell;
                    break;
                }
                default:
                    break;
            }
        }
        default:
            break;
    }
    return nil;
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    Member *member = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.appDLG.currentUserID][0];
    if ([segue.identifier isEqualToString:@"membersSegue"])
    {
        if (![member.memberClass isEqualToString:@"admin"])
        {
            [AlertManager alert:@"需有管理員權限才可執行" controller:self];
            return;
        }
    }
    else if ([segue.identifier isEqualToString:@"profileSegue"])
    {
        if (![self.appDLG.loginType isEqualToString:@"inside"])
        {
            [AlertManager alert:@"一般會員登入才可執行" controller:self];
            return;
        }
        else
        {
            SignupViewController *svc = segue.destinationViewController;
            svc.currentMember = member;
        }
    }
}

-(BOOL)isDropboxDidLogin
{
    //先確認是否已登入,auth==nil就是沒認證
    if ([DropboxClientsManager authorizedClient] == nil)
    {
        //4.A
        [DropboxClientsManager authorizeFromController:[UIApplication sharedApplication] controller:self openURL:^(NSURL * _Nonnull url)
         {
             //5.輸完帳密先跑這邊
             [[UIApplication sharedApplication] openURL:url options:@{} completionHandler:nil];
         } browserAuth:NO];
        return NO;
    }
    else
    {
        //4.B
        //有認證就拿來用
        self.dbClient = [DropboxClientsManager authorizedClient];
        return YES;
    }
    return nil;
}

//7.成功才會跑這邊
-(void)dbBackupOrRestore
{
    self.dbClient = [DropboxClientsManager authorizedClient];
    if ([self.dbAction isEqualToString:@"Backup"])
    {
        [self dropboxBackupAction];
    }
    else if ([self.dbAction isEqualToString:@"Restore"])
    {
        [self dropboxRestoreAction];
    }
}

//3.1
-(void)dropboxBackupButton
{
    self.dbAction = @"Backup";
    if ([self isDropboxDidLogin])
    {
        [self dropboxBackupAction];
    }
}

//8.1
-(void)dropboxBackupAction
{
    [AlertManager alertYesAndNo:@"請確認是否備份至Dropbox\n產生新的資料紀錄？" yes:@"是" no:@"否" controller:self postNotificationName:@"dbBackup"];
}

//3.2
-(void)dropboxRestoreButton
{
    self.dbAction = @"Restore";
    if ([self isDropboxDidLogin])
    {
        [self dropboxRestoreAction];
    }
}

//6.2
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
    NSString *message = [NSString stringWithFormat:@"您選擇的檔案為：%@\n請確認是否從Dropbox還原\n覆蓋現有資料",self.dbSelectedFolderName];
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

-(void)askUserLogOut
{
    [AlertManager alertYesAndNo:@"是否確定登出" yes:@"是" no:@"否" controller:self postNotificationName:@"userShouldLogout"];
}

-(void)userShouldLogout
{
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    appDLG.isLogin = NO;
    appDLG.isSignup = NO;
    appDLG.loginType = @"";
    appDLG.currentUserID = @"";
    appDLG.currentUserName = @"";
    appDLG.currentUserImg = nil;
    appDLG.currentMember = nil;
    WelcomeViewController *wvc = [self.storyboard instantiateViewControllerWithIdentifier:@"welcomeVC"];
    [self presentViewController:wvc animated:YES completion:nil];
    [self.navigationController popViewControllerAnimated:NO];
}


- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
