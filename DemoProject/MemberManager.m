//
//  MemberManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/15.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "MemberManager.h"
#import "DataBaseManager.h"
#import "AlertManager.h"
#import "AppDelegate.h"
#import "Member.h"
#import "SignupViewController.h"

@implementation MemberManager

+(BOOL)isSignup:(UIViewController*)vc isInsideSingup:(BOOL)isInsideSingup
{
    //準備另一個VC備用
    SignupViewController *svc = (SignupViewController*)vc;
    //檢查有無user資料
    if ([DataBaseManager queryFromCoreData:@"MemberEntity" sortBy:@"memberID"].count == 0)
    {
        //寫資料
        [self addMember:@"first" svc:svc isInsideSingup:isInsideSingup];
        //如果這個dismiss放alert下面, 會變成dismiss alert
        if (isInsideSingup != YES)
        {
            [vc dismissViewControllerAnimated:YES completion:nil];
            [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為管理員\n若使用上有任何問題請來信lawmark33699@gmail.com\n謝謝" controller:vc];
        }
        else
        {
            [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為管理員\n若使用上有任何問題請來信lawmark33699@gmail.com\n謝謝" controller:svc];
                return YES;
        }
    }
    else
    {
        //取ID
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        NSString *memberID = appDLG.currentUserID;
        if (isInsideSingup == YES)
        {
            memberID = svc.memberIDInput.text;
        }
        NSArray *memberArray = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberID" fiterBy:memberID];
        //檢查這個User有無註冊
        if (memberArray.count == 0)
        {
            [self addMember:@"other" svc:svc isInsideSingup:isInsideSingup];
            [AlertManager alert:@"歡迎初次使用店店三碗公\n已幫您註冊為會員\n請待管理員審核後登入\n若使用上有任何問題請來信lawmark33699@gmail.com\n謝謝" controller:vc];
        }
        else
        {
            Member *getMember = memberArray[0];
            if (getMember.memberApproved != YES)
            {
                [AlertManager alert:@"您的帳號尚未審核\n請通知管理員\n謝謝" controller:vc];
            }
            else
            {
                appDLG.isSignup = YES;
                return YES;
            }
        }
    }
    return NO;
}

+(void)addMember:(NSString*)type svc:(SignupViewController*)svc isInsideSingup:(BOOL)isInsideSingup
{
    //已經先確認沒有找到ID(就代表沒有重複)才來執行這個方法
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Member *addMember = [NSEntityDescription insertNewObjectForEntityForName:@"MemberEntity" inManagedObjectContext:helper.managedObjectContext];
    if (isInsideSingup == YES)
    {
        addMember.memberID = svc.memberIDInput.text;
        addMember.memberPW = svc.memberPWInput.text;
        addMember.memberName = svc.memberNameInput.text;
        NSDateFormatter *df = [NSDateFormatter new];
        [df setDateFormat:@"yyyy/MM/dd"];
        addMember.memberBirthday = [df dateFromString:svc.memberBirthdayInput.text];
        addMember.memberImg = UIImagePNGRepresentation(svc.memberImgView.image);
        if ([type isEqualToString:@"first"])
        {
            addMember.memberApproved = YES;
            addMember.memberClass = @"admin";
            addMember.memberType = @"inside";
        }
    }
    else
    {
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        addMember.memberID = appDLG.currentUserID;
        addMember.memberName = appDLG.currentUserName;
        addMember.memberType = appDLG.loginType;
        if ([type isEqualToString:@"first"])
        {
            addMember.memberApproved = YES;
            addMember.memberClass = @"admin";
        }
    }
    [DataBaseManager updateToCoreData];
}

@end
