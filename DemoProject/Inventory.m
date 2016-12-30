//
//  Inventory.m
//  DemoProject
//
//  Created by user32 on 2016/11/25.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "Inventory.h"
#import "OrderDetail.h"
#import "DataBaseManager.h"

@implementation Inventory
@dynamic itemNo;
@dynamic warehouse;
@dynamic qty;

+(void)calculateInventory:(NSArray*)orderDetailList warehouse:(NSString*)warehouse orderNoBegin:(NSString*)orderNoBegin
{
    for (OrderDetail *od in orderDetailList)
    {
        Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:warehouse];
        //之前已算過
        if (od.isInventory != nil)
        {
            if ([orderNoBegin isEqualToString:@"PF"])
            {
                //比較多
                if (od.orderQty > od.isInventory)
                {
                    //加差額
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]-[od.isInventory integerValue]);
                    od.isInventory = od.orderQty;
                }
                else if (od.orderQty < od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]-([od.isInventory integerValue]-[od.orderQty integerValue]));
                    od.isInventory = od.orderQty;
                }
            }
            else if ([orderNoBegin isEqualToString:@"SF"])
            {
                if (od.orderQty > od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.isInventory integerValue]-[od.orderQty integerValue]);
                    od.isInventory = od.orderQty;
                }
                else if (od.orderQty < od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]-([od.orderQty integerValue]-[od.isInventory integerValue]));
                    od.isInventory = od.orderQty;
                }
            }
            else if ([orderNoBegin isEqualToString:@"PB"])
            {
                if (od.orderThisQty > od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderThisQty integerValue]-[od.isInventory integerValue]);
                    od.isInventory = od.orderThisQty;
                }
                else if (od.orderThisQty < od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]-([od.isInventory integerValue]-[od.orderThisQty integerValue]));
                    od.isInventory = od.orderThisQty;
                }
            }
            else if ([orderNoBegin isEqualToString:@"SB"])
            {
                if (od.orderThisQty > od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.isInventory integerValue]-[od.orderThisQty integerValue]);
                    od.isInventory = od.orderThisQty;
                }
                else if (od.orderThisQty < od.isInventory)
                {
                    getInventory.qty = @([getInventory.qty integerValue]-([od.orderThisQty integerValue]-[od.isInventory integerValue]));
                    od.isInventory = od.orderThisQty;
                }
            }
        }
        //之前沒算過
        else
        {
            //已有庫存
            if (getInventory != nil)
            {
                if ([orderNoBegin isEqualToString:@"PF"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
                    od.isInventory = od.orderQty;
                }
                else if ([orderNoBegin isEqualToString:@"SF"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
                    od.isInventory = od.orderQty;
                }
                else if ([orderNoBegin isEqualToString:@"PB"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderThisQty integerValue]);
                    od.isInventory = od.orderThisQty;
                }
                else if ([orderNoBegin isEqualToString:@"SB"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]-[od.orderThisQty integerValue]);
                    od.isInventory = od.orderThisQty;
                }
            }
            //沒有庫存
            else
            {
                CoreDataHelper *helper = [CoreDataHelper sharedInstance];
                Inventory *newInventory = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryEntity" inManagedObjectContext:helper.managedObjectContext];
                newInventory.itemNo = od.orderItemNo;
                newInventory.warehouse = warehouse;
                if ([orderNoBegin isEqualToString:@"PF"])
                {
                    newInventory.qty = od.orderQty;
                    od.isInventory = od.orderQty;
                }
                else if ([orderNoBegin isEqualToString:@"SF"])
                {
                    newInventory.qty = @(-[od.orderQty floatValue]);
                    od.isInventory = od.orderQty;
                }
                else if ([orderNoBegin isEqualToString:@"PB"])
                {
                    newInventory.qty = od.orderThisQty;
                    od.isInventory = od.orderThisQty;
                }
                else if ([orderNoBegin isEqualToString:@"SB"])
                {
                    newInventory.qty = @(-[od.orderThisQty floatValue]);
                    od.isInventory = od.orderThisQty;
                }
            }
        }
    }
}

+(void)rollbackInventory:(OrderDetail*)od warehouse:(NSString*)warehouse orderNoBegin:(NSString*)orderNoBegin
{
    if ([od.isInventory boolValue] == YES)
    {
        Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:warehouse];
        
        if ([orderNoBegin isEqualToString:@"PF"])
        {
            getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
        }
        else if ([orderNoBegin isEqualToString:@"SF"])
        {
            getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
        }
        else if ([orderNoBegin isEqualToString:@"PB"])
        {
            getInventory.qty = @([getInventory.qty integerValue]-[od.orderThisQty integerValue]);
        }
        else if ([orderNoBegin isEqualToString:@"SB"])
        {
            getInventory.qty = @([getInventory.qty integerValue]+[od.orderThisQty integerValue]);
        }
    }
}
@end
