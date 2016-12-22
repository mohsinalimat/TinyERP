//
//  SignupViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/13.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "SignupViewController.h"
#import "AlertManager.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "Member.h"
#import "ImageManager.h"
#import "DateManager.h"

@interface SignupViewController () <UIImagePickerControllerDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *memberIDInput;
@property (weak, nonatomic) IBOutlet UITextField *memberPWInput;
@property (weak, nonatomic) IBOutlet UITextField *memberPWCheckInput;
@property (weak, nonatomic) IBOutlet UITextField *memberNameInput;
@property (weak, nonatomic) IBOutlet UITextField *memberBirthdayInput;
@property (weak, nonatomic) IBOutlet UIImageView *memberImgView;
@property (weak, nonatomic) IBOutlet UIButton *commitButton;

@property ImageManager *imgManager;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"會員註冊";
    [self.commitButton setTitle:@"註冊" forState:UIControlStateNormal];
    if (self.currentMember != nil)
    {
        self.title = @"個人資料";
        [self.commitButton setTitle:@"修改" forState:UIControlStateNormal];
        [self.memberIDInput setEnabled:NO];
    }
    self.memberImgView.layer.borderWidth = 1;
    self.memberImgView.layer.borderColor =  self.view.tintColor.CGColor;
    
    //代理Zone
    self.memberIDInput.delegate = self;
    self.memberPWInput.delegate = self;
    self.memberPWCheckInput.delegate = self;
    self.memberNameInput.delegate = self;
    self.memberBirthdayInput.delegate = self;
    
    //初值
    self.memberIDInput.text = self.currentMember.memberID;
    self.memberNameInput.text = self.currentMember.memberName;
    self.memberPWInput.text = self.currentMember.memberPW;
    self.memberPWCheckInput.text = self.currentMember.memberPW;
    self.memberBirthdayInput.text = [DateManager getFormatedDateString:self.currentMember.memberBirthday];
    self.memberImgView.image = [UIImage imageWithData:self.currentMember.memberImg];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(signupMember) name:@"memberSignupYes" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(modifyMember) name:@"memberModifyYes" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
}

-(void)signupMember
{
    //檢查有無user資料
    if ([DataBaseManager queryFromCoreData:@"MemberEntity" sortBy:@"memberID"].count == 0)
    {
        //寫資料
        [self addMember:@"first"];
        [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為管理員\n若使用上有任何問題\n請至https://www.facebook.com/mark.storeapp反應\n謝謝" controller:self command:@"popViewController"];
    }
    else
    {
        NSArray *memberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:self.memberIDInput.text];
        //檢查這個User有無註冊過了
        if (memberArray.count == 0)
        {
            [self addMember:@"other"];
            [AlertManager alert:@"歡迎使用店店三碗公\n已幫您註冊為會員\n請待管理員審核後登入\n若使用上有任何問題\n請至https://www.facebook.com/mark.storeapp反應\n謝謝" controller:self command:@"popViewController"];
        }
        else
        {
            [AlertManager alert:@"帳號重複\n請重新輸入" controller:self];
            self.memberIDInput.text = @"";
            self.memberPWInput.text = @"";
            [self.memberIDInput becomeFirstResponder];
        }
    }
}

-(void)modifyMember
{
    self.currentMember.memberName = self.memberNameInput.text;
    self.currentMember.memberPW = self.memberPWInput.text;
    self.currentMember.memberBirthday = [DateManager getDateByString:self.memberBirthdayInput.text];
    self.currentMember.memberImg = UIImageJPEGRepresentation(self.memberImgView.image, 1);
    [DataBaseManager updateToCoreData];
    [AlertManager alertWithoutButton:@"修改完成" controller:self time:0.5 action:@"popVC"];
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)commitButton:(id)sender
{
    if (self.memberIDInput.text.length == 0 || self.memberPWInput.text.length == 0)
    {
        [AlertManager alert:@"帳號或密碼未填" controller:self];
    }
    else if (![self.memberPWInput.text isEqualToString:self.memberPWCheckInput.text])
    {
        [AlertManager alert:@"密碼輸入不一致" controller:self];
    }
    else
    {
        if (self.currentMember == nil)
        {
            [AlertManager alertYesAndNo:@"請確認是否註冊會員" yes:@"是" no:@"否" controller:self postNotificationName:@"memberSignup"];
        }
        else
        {
            [AlertManager alertYesAndNo:@"請確認是否修改會員資料" yes:@"是" no:@"否" controller:self postNotificationName:@"memberModify"];
        }
    }
}

-(void)addMember:(NSString*)type
{
    //已經先確認沒有找到ID(就代表沒有重複)才來執行這個方法
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Member *addMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberEntity" inManagedObjectContext:helper.managedObjectContext];
    addMember.memberID = self.memberIDInput.text;
    addMember.memberPW = self.memberPWInput.text;
    addMember.memberName = self.memberNameInput.text;
    addMember.memberType = @"inside";
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd"];
    addMember.memberBirthday = [df dateFromString:self.memberBirthdayInput.text];
    addMember.memberImg = UIImagePNGRepresentation(self.memberImgView.image);
    addMember.memberApproved = NO;
    addMember.memberClass = @"未分類";
    if ([type isEqualToString:@"first"])
    {
        addMember.memberApproved = YES;
        addMember.memberClass = @"admin";
    }
    [DataBaseManager updateToCoreData];
}

-(void)prepareForImage
{
    self.imgManager = [ImageManager new];
    self.imgManager.vc = self;
    self.imgManager.imageView = self.memberImgView;
}

- (IBAction)memberImg:(id)sender
{
    [self prepareForImage];
    [self.imgManager getImageByAlbum];
}

- (IBAction)memberCamera:(id)sender
{
    [self prepareForImage];
    [self.imgManager getImageByCamera];
}

-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.imgManager.imageInfo = info;
    [self.imgManager putImage];
}

- (IBAction)memberImgDelete:(id)sender
{
    self.imgManager = [ImageManager new];
    self.imgManager.vc = self;
    self.imgManager.imageView = self.memberImgView;
    [self.imgManager deleteImage];
}

//按Return縮鍵盤
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
