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
        if ([od.isInventory boolValue] != YES && [od.orderQty integerValue] != 0)
        {
            Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:warehouse];
            if (getInventory != nil)
            {
                if ([orderNoBegin isEqualToString:@"P"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
                }
                else if ([orderNoBegin isEqualToString:@"S"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
                }
            }
            else
            {
                //首次異動
                CoreDataHelper *helper = [CoreDataHelper sharedInstance];
                Inventory *newInventory = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryEntity" inManagedObjectContext:helper.managedObjectContext];
                newInventory.itemNo = od.orderItemNo;
                newInventory.warehouse = warehouse;
                if ([orderNoBegin isEqualToString:@"P"])
                {
                    newInventory.qty = od.orderQty;
                }
                else if ([orderNoBegin isEqualToString:@"S"])
                {
                    newInventory.qty = @(-[od.orderQty floatValue]);
                }
            }
            //算過了
            od.isInventory = @YES;
        }
    }
}

+(void)rollbackInventory:(OrderDetail*)od warehouse:(NSString*)warehouse orderNoBegin:(NSString*)orderNoBegin
{
    if ([od.isInventory boolValue] == YES)
    {
        Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:warehouse];
        
        if ([orderNoBegin isEqualToString:@"P"])
        {
            getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
        }
        else if ([orderNoBegin isEqualToString:@"S"])
        {
            getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
        }
    }
}
@end
