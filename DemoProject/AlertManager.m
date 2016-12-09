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
#import <UIKit/UIKit.h>

@implementation AlertManager

+(void)alert:(NSString*)message controller:(UIViewController*)vc
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *cfn = [UIAlertAction actionWithTitle:@"確定" style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:cfn];
    [vc presentViewController:ac animated:YES completion:nil];
}

+(void)alertYesAndNo:(NSString*)message yes:(NSString*)yesString no:(NSString*)noString controller:(UIViewController*)vc
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:yesString style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            if ([vc isKindOfClass:[ItemViewController class]])
            {
                ItemViewController *ivc = (ItemViewController*)vc;
                ivc.itemImageView.image = nil;
            }
        }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:noString style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:noButton];
    [ac addAction:yesButton];
    [vc presentViewController:ac animated:YES completion:nil];
}

+(void)alertYesAndNo:(NSString*)message yes:(NSString*)yesString no:(NSString*)noString controller:(UIViewController*)vc postNotificationName:(NSString*)Notification
{
    UIAlertController *ac = [UIAlertController alertControllerWithTitle:@"" message:message preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction *yesButton = [UIAlertAction actionWithTitle:yesString style:UIAlertActionStyleDestructive handler:^(UIAlertAction * _Nonnull action)
        {
            [[NSNotificationCenter defaultCenter]postNotificationName:Notification object:vc];
        }];
    UIAlertAction *noButton = [UIAlertAction actionWithTitle:noString style:UIAlertActionStyleDefault handler:nil];
    [ac addAction:noButton];
    [ac addAction:yesButton];
    [vc presentViewController:ac animated:YES completion:nil];
}
@end
