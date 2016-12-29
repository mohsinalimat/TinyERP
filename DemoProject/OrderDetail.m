//
//  OrderDetail.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "OrderDetail.h"
#import "DataBaseManager.h"

@implementation OrderDetail
@dynamic orderItemNo;
@dynamic orderAmount;
@dynamic orderNotYetQty;
@dynamic orderThisQty;
@dynamic orderNotYetAmount;
@dynamic orderThisAmount;
@dynamic orderNo;
@dynamic orderNoOld;
@dynamic orderPrice;
@dynamic orderQty;
@dynamic orderSeq;
@dynamic orderSeqOld;
@dynamic isInventory;

+(void)deleteOrderDetail:(OrderDetail*)od array:(NSMutableArray*)array tableView:(UITableView*)tableView indexPath:(NSIndexPath*)indexPath;
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    //刪DB
    [helper.managedObjectContext deleteObject:od];
    //刪陣列
    [array removeObjectAtIndex:indexPath.row];
    //刪cell
    [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

+(NSString*)isPostOrder:(NSArray*)orderDetailList
{
    NSMutableString *yesString = [NSMutableString stringWithFormat:@""];
    for (OrderDetail *odPre in orderDetailList)
    {
        NSArray *yesPostArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeqOld" fiterByArray:@[odPre.orderNo,odPre.orderSeq]];
        if(yesPostArray != nil)
        {
            for (OrderDetail *odPost in yesPostArray)
            {
                NSString *odString = [NSString stringWithFormat:@"項次[%@]有衍生單據%@-%@\n",odPre.orderSeq,odPost.orderNo,odPost.orderSeq];
                [yesString appendString:odString];
            }
        }
        //拿我的前單去找人家的前單, 如果他的號碼大於我
        if (odPre.orderNoOld == nil)
        {
            odPre.orderNoOld = @".";
        }
        NSArray *yesBrotherArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeqOld" fiterByArray:@[odPre.orderNoOld,odPre.orderSeqOld]];
        if (yesBrotherArray != nil)
        {
            for (OrderDetail *odBrother in yesBrotherArray)
            {
                NSComparisonResult youBrother = [odPre.orderNo compare:odBrother.orderNo];
                if (youBrother == NSOrderedAscending)
                {
                    NSString *odString = [NSString stringWithFormat:@"項次[%@]有相關單據%@-%@\n",odPre.orderSeq,odBrother.orderNo,odBrother.orderSeq];
                    [yesString appendString:odString];
                }
            }
        }
    }
    return yesString;
}

+(void)rollbackNotYet:(NSArray*)orderDetailList
{
    for (OrderDetail *odPost in orderDetailList)
    {
        NSArray *yesPreArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeq" fiterByArray:@[odPost.orderNoOld,odPost.orderSeqOld]];
        if (yesPreArray != nil)
        {
            OrderDetail *odPre = yesPreArray.firstObject;
            if ([[odPost.orderNo substringWithRange:NSMakeRange(1,1)] isEqualToString:@"B"])
            {
                odPre.orderNotYetQty = odPost.orderQty;
            }
            else if ([[odPost.orderNo substringWithRange:NSMakeRange(1,1)] isEqualToString:@"C"])
            {
                odPre.orderNotYetAmount = odPost.orderAmount;
            }
            [DataBaseManager updateToCoreData];
        }
    }
}

@end

