//
//  OrderMasterManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/19.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "OrderMasterManager.h"

@implementation OrderMasterManager

+(OrderMaster*)createOrderMaster:(NSString*)orderBegin orderList:(NSMutableArray*)orderList
{
    //產生單頭物件
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    OrderMaster *om = [NSEntityDescription insertNewObjectForEntityForName:@"OrderMasterEntity" inManagedObjectContext:helper.managedObjectContext];
    //單頭初值
    om.orderType = orderBegin;
    om.orderCount = 0;
    //處理單號日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYMMdd"];
    NSDate *date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    //處理單號流水
    NSString *waterNoString;
    //如果完全沒單
    if (orderList.count == 0)
    {
        //那就是當然的一號
        waterNoString = @"001";
    }
    else
    {
        BOOL isTodayOrderNo = NO;
        NSMutableArray *todayOrderNoArray = [NSMutableArray array];
        //遍歷
        for (OrderMaster *om in orderList)
        {
            NSString *orderNoDate = [om.orderNo substringWithRange:NSMakeRange(2,6)];
            if ([om.orderType isEqualToString:orderBegin] && [orderNoDate isEqualToString:dateString])
            {
                isTodayOrderNo = YES;
                [todayOrderNoArray addObject:@([[om.orderNo substringFromIndex:8] integerValue])];
            }
        }
        //如果今天都沒單
        if (isTodayOrderNo == NO)
        {
            //那還是今天的一號
            waterNoString = @"001";
        }
        else
        {
            NSNumber *maxOrderNo = [todayOrderNoArray valueForKeyPath: @"@max.integerValue"];
            NSUInteger waterNoInt = [maxOrderNo integerValue] + 1;
            NSNumber *waterNo = @(waterNoInt);
            waterNoString = [waterNo stringValue];
            if (waterNoString.length == 1)
            {
                waterNoString = [@"00" stringByAppendingString:waterNoString];
            }
            else if (waterNoString.length == 2)
            {
                waterNoString = [@"0" stringByAppendingString:waterNoString];
            }
        }
    }
    //組單號
    NSString *orderNoString = [om.orderType stringByAppendingFormat:@"%@%@",dateString,waterNoString];
    om.orderNo = orderNoString;
    
    return om;
}

@end
