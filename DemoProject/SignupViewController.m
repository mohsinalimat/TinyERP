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

@interface SignupViewController () <UIImagePickerControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *memberIDInput;
@property (weak, nonatomic) IBOutlet UITextField *memberPWInput;
@property (weak, nonatomic) IBOutlet UITextField *memberNameInput;
@property (weak, nonatomic) IBOutlet UITextField *memberBirthdayInput;
@property (weak, nonatomic) IBOutlet UIImageView *memberImgView;
@property ImageManager *imgManager;
@end

@implementation SignupViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"會員註冊";
    self.memberImgView.layer.borderWidth = 1;
    self.memberImgView.layer.borderColor =  self.view.tintColor.CGColor;
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"memberSignupYes" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Member *newMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberEntity" inManagedObjectContext:helper.managedObjectContext];
        newMember.memberID = self.memberIDInput.text;
        newMember.memberPW = self.memberPWInput.text;
        newMember.memberName = self.memberNameInput.text;
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy/MM/dd"];
        newMember.memberBirthday = [df dateFromString:self.memberBirthdayInput.text];
        newMember.memberImg = UIImagePNGRepresentation(self.memberImgView.image);
        [DataBaseManager updateToCoreData];
        [AlertManager alert:@"會員申請已完成\n請待管理員審核後登入\n謝謝" controller:self postNotificationName:@"signupOver"];
    }];
    
    [[NSNotificationCenter defaultCenter] addObserverForName:@"signupOver" object:self queue:nil usingBlock:^(NSNotification * _Nonnull note)
     {
         [self.navigationController popViewControllerAnimated:YES];
     }];
}

- (IBAction)signupButton:(id)sender
{
    [AlertManager alertYesAndNo:@"請確認資料是否正確並註冊會員" yes:@"是" no:@"否" controller:self postNotificationName:@"memberSignup"];
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


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
