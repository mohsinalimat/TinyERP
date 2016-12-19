//
//  AlertManager.h
//  DemoProject
//
//  Created by user32 on 2016/11/22.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "ItemViewController.h"
#import <UIKit/UIKit.h>

@interface AlertManager : NSObject
+(void)alertWithoutButton:(NSString*)message controller:(UIViewController*)vc time:(CGFloat)time action:(NSString*)action;
+(void)alert:(NSString*)message controller:(UIViewController*)vc;
+(void)alert:(NSString*)message controller:(UIViewController*)vc command:(NSString*)action;
+(void)alert:(NSString*)message controller:(UIViewController*)vc postNotificationName:(NSString*)notification;
+(void)alertYesAndNo:(NSString*)message yes:(NSString*)yesString no:(NSString*)noString controller:(UIViewController*)vc postNotificationName:(NSString*)notification;
@end
