//
//  DateManager.h
//  DemoProject
//
//  Created by user32 on 2016/12/21.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DateManager : NSObject
@property UIDatePicker *dp;
@property UITextField *dateField;
+(NSString*)getTodayDateString;
+(NSString*)getFormatedDateString:(NSDate*)date;
+(NSDate*)getDateByString:(NSString*)string;
-(void)showDatePicker:(UIViewController*)controller dateField:(UITextField*)dateField;
@end
