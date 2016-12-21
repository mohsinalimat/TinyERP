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

@end
