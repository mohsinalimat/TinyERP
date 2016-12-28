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
        NSArray *yesArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeqOld" fiterByArray:@[odPre.orderNo,odPre.orderSeq]];
        if(yesArray != nil)
        {
            for (OrderDetail *odPost in yesArray)
            {
                NSString *odString = [NSString stringWithFormat:@"項次[%@]有衍生單據%@-%@\n",odPre.orderSeq,odPost.orderNo,odPost.orderSeq];
                [yesString appendString:odString];
            }
        }
    }
    return yesString;
}

@end

