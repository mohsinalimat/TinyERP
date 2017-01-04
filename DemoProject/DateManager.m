//
//  DateManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/21.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "DateManager.h"

@implementation DateManager

+(NSString*)getTodayDateString
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSDate *today = [NSDate date];
    NSString *dateString = [formatter stringFromDate:today];
    return dateString;
}

+(NSString*)getFormatedDateString:(NSDate*)date
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [formatter stringFromDate:date];
    return dateString;
}

+(NSDate*)getDateByString:(NSString*)string
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSDate *date = [df dateFromString:string];
    return date;
}

-(void)showDatePicker:(UIViewController *)controller dateField:(UITextField*)dateField
{
    CGFloat vcWidth = controller.view.frame.size.width;
    CGFloat vcHeight = controller.view.frame.size.height;
    self.dp = [[UIDatePicker alloc]initWithFrame:CGRectMake(0, vcHeight/5, vcWidth, vcHeight/3)];
    self.dp.datePickerMode = UIDatePickerModeDate;
    self.dp.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    self.dateField = dateField;
    [controller.view addSubview:self.dp];
    [self.dp addTarget:self action:@selector(sendDateString:) forControlEvents:UIControlEventValueChanged];
}

-(void)sendDateString:(UIDatePicker*)sender
{
    self.dateField.text = [DateManager getFormatedDateString:sender.date];
}

@end
