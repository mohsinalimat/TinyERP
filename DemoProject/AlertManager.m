//
//  AlertManager.m
//  DemoProject
//
//  Created by user32 on 2016/11/22.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AlertManager.h"
#import "ItemViewController.h"
#import "SetupViewController.h"
#import "SignupViewController.h"
#import "ViewController.h"
#import <UIKit/UIKit.h>

@implementation AlertManager

+ (void)dismissAlertController:(UIAlertController *)alert
{
    //還是用廣播, 當Alert縮下來時才做
    [alert dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark Q.不知為何多參就不能Delay
//+ (void)dismissAlertController:(UIAlertController *)alert controller:(UIViewController*)vc
+ (void)dismissAlertControllerWithPop:(UIAlertController *)alert
{
    [alert dismissViewControllerAnimated:YES completion:
    ^{
        //還是用廣播, 當Alert縮下來時才做
        [[NSNotificationCenter defaultCenter]postNotificationName:@"popVC" object:nil];
    }];
}

+(void)alertWithoutButton:(NSString*)message controller:(UIViewController*)vc time:(CGFloat)time action:(NSString*)action
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    [vc presentViewController:ac animated:YES completion:nil];
    //延後執行要做不同的事
    if ([action isEqualToString:@"popVC"])
    {
        [self performSelector:@selector(dismissAlertControllerWithPop:) withObject:ac afterDelay:time];
    }
    else
    {
        [self performSelector:@selector(dismissAlertController:) withObject:ac afterDelay:time];
    }
#pragma mark Q.不知為何多參就不能Delay
//    [self performSelector:@selector(dismissAlertController:controller:) withObject:ac withObject:vc  afterDelay:time];
}

+(void)alert:(NSString*)message controller:(UIViewController*)vc
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:cfn];
    [vc presentViewController:ac animated:YES completion:nil];
}

+(void)alert:(NSString*)message controller:(UIViewController*)vc command:(NSString*)action
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cfn;
    if ([action isEqualToString:@"transferWVC"])
    {
        cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            [(ViewController*)vc transferWVC];
        }];
    }
    else if ([action isEqualToString:@"popViewController"])
    {
        cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
               {
                   [vc.navigationController popViewControllerAnimated:YES];
               }];
    }
    else if ([action isEqualToString:@"dismissViewController"])
    {
        cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
               {
                   [vc dismissViewControllerAnimated:YES completion:nil];
               }];
    }
    else
    {
        cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
    }

    [ac addAction:cfn];
    [vc presentViewController:ac animated:YES completion:nil];
}

+(void)alert:(NSString*)message controller:(UIViewController*)vc postNotificationName:(NSString*)notification;
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
    {
        [[NSNotificationCenter defaultCenter]postNotificationName:notification object:vc];
    }];
    [ac addAction:cfn];
    [vc presentViewController:ac animated:YES completion:nil];
}

+(void)alertYesAndNo:(NSString*)message yes:(NSString*)yesString no:(NSString*)noString controller:(UIViewController*)vc postNotificationName:(NSString*)Notification
{
    NSString *postName = Notification;
    
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:yesString style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            NSString *postNameYes = [postName stringByAppendingString:@"Yes"];
            [[NSNotificationCenter defaultCenter]postNotificationName:postNameYes object:nil];
        }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:noString style:UIAlertActionStyleDefault handler:^(UIAlertAction * _Nonnull action)
        {
            NSString *postNameNo = [postName stringByAppendingString:@"No"];
            [[NSNotificationCenter defaultCenter]postNotificationName:postNameNo object:nil];
        }];
    [ac addAction:noButton];
    [ac addAction:yesButton];
    [vc presentViewController:ac animated:YES completion:nil];
}
@end
