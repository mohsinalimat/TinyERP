//
//  DataBaseManager.m
//  DemoProject
//
//  Created by user32 on 2016/11/1.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "Inventory.h"
#import "OrderDetail.h"

@implementation DataBaseManager

+(NSMutableArray*)queryFromCoreData:(NSString*)entity sortBy:(NSString*)sortString
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSError *error = nil;
    NSSortDescriptor *sort=[[NSSortDescriptor alloc] initWithKey:sortString ascending:YES];
    request.sortDescriptors=@[sort];
    NSArray *results = [helper.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *returnResults = [[NSMutableArray alloc]init];
    
    if (error)
    {
        NSLog(@"%@",error);
        returnResults = [NSMutableArray array];
    }
    else
    {
        returnResults = [NSMutableArray arrayWithArray:results];
    }
    return returnResults;
}

+(NSMutableArray*)fiterFromCoreData:(NSString*)entity sortBy:(NSString*)sortString fiterFrom:(NSString*)fiterColumn fiterBy:(NSString*)fiterString
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:entity];
    NSError *error = nil;
    
    NSSortDescriptor *sort=[[NSSortDescriptor alloc] initWithKey:sortString ascending:YES];
    request.sortDescriptors=@[sort];
    
#pragma mark Q.為什麼條件直接傳進來不行？
    //@"partnerType == \"F\""
    //NSPredicate *pred = [NSPredicate predicateWithFormat:@"%@",fiterString];
    NSPredicate *pred;
    //交易對象
    if ([fiterColumn isEqualToString:@"partnerType"])
    {
        pred = [NSPredicate predicateWithFormat:@"partnerType=%@",fiterString];
    }
    //基本資料
    else if ([fiterColumn isEqualToString:@"basicDataType"])
    {
        pred = [NSPredicate predicateWithFormat:@"basicDataType=%@",fiterString];
    }
    //單據類別
    else if ([fiterColumn isEqualToString:@"orderType"])
    {
        pred = [NSPredicate predicateWithFormat:@"orderType=%@",fiterString];
    }
    //單號
    else if ([fiterColumn isEqualToString:@"orderNo"])
    {
        pred = [NSPredicate predicateWithFormat:@"orderNo=%@",fiterString];
    }
    //單身查料號
    else if ([fiterColumn isEqualToString:@"itemNo"])
    {
        pred = [NSPredicate predicateWithFormat:@"itemNo=%@",fiterString];
    }
    //查非零庫存
    else if ([fiterColumn isEqualToString:@"qty"])
    {
        pred = [NSPredicate predicateWithFormat:@"qty!=%@",@([fiterString floatValue])];
    }
    //查進貨未沖金額不等於零
    else if ([fiterColumn isEqualToString:@"NotYetAmountPB"])
    {
        NSString *pb = @"PB*";
        pred = [NSPredicate predicateWithFormat:@"(orderNotYetAmount!=%@) && (orderNo like %@)",@([fiterString floatValue]),pb];
    }
    //查銷貨未沖金額不等於零
    else if ([fiterColumn isEqualToString:@"NotYetAmountSB"])
    {
        NSString *sb = @"SB*";
        pred = [NSPredicate predicateWithFormat:@"(orderNotYetAmount!=%@) && (orderNo like %@)",@([fiterString floatValue]),sb];
    }
    //廠商編號
    else if ([fiterColumn isEqualToString:@"partnerIDtypeF"])
    {
        //        pred = [NSPredicate predicateWithFormat:@"partnerID=%@",fiterString];
        NSString *f = @"F";
        pred = [NSPredicate predicateWithFormat:@"(partnerID=%@) && (partnerType=%@)",fiterString,f];
    }
    //客戶編號
    else if ([fiterColumn isEqualToString:@"partnerIDtypeC"])
    {
        //        pred = [NSPredicate predicateWithFormat:@"partnerID=%@",fiterString];
        NSString *c = @"C";
        pred = [NSPredicate predicateWithFormat:@"(partnerID=%@) && (partnerType=%@)",fiterString,c];
    }
    
    request.predicate = pred;
    
    NSArray *results = [helper.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *returnResults = [[NSMutableArray alloc]init];
    
    if (error)
    {
        NSLog(@"%@",error);
        returnResults = [NSMutableArray array];
    }
    else
    {
        returnResults = [NSMutableArray arrayWithArray:results];
    }
    return returnResults;
}

+(Inventory*)fiterInventoryFromCoreDataWithItemNo:(NSString*)fiterItemNo WithWarehouse:(NSString*)fiterWarehouse
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSFetchRequest *request = [NSFetchRequest fetchRequestWithEntityName:@"InventoryEntity"];
    NSError *error = nil;
    NSPredicate *pred;
#pragma mark Q.為什麼不能兩個條件？
    //又是一個奇怪的當法.......
    //pred = [NSPredicate predicateWithFormat:@"(itemNo=%@) && (warehourse=%@)",fiterItemNo,fiterWarehouse];
    pred = [NSPredicate predicateWithFormat:@"(itemNo=%@)",fiterItemNo];
    request.predicate = pred;
    NSArray *results = [helper.managedObjectContext executeFetchRequest:request error:&error];
    NSMutableArray *returnResults = [[NSMutableArray alloc]init];
    
    if (error)
    {
        NSLog(@"%@",error);
        returnResults = [NSMutableArray array];
    }
    else
    {
        returnResults = [NSMutableArray arrayWithArray:results];
    }
    
    Inventory *pickInventory;
    for (Inventory *inv in returnResults)
    {
        if ([inv.warehouse isEqualToString:fiterWarehouse])
        {
            pickInventory = inv;
            break;
        }
    }
    
    return pickInventory;
}

+(void)updateToCoreData
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSError *error = nil;
    [helper.managedObjectContext save:&error];
    if (error)
    {
        NSLog(@"%@",error);
    }
}

+(void)deleteDataAndObject:(id)entity array:(NSMutableArray*)list
{
    CoreDataHelper *help = [CoreDataHelper sharedInstance];
    [help.managedObjectContext deleteObject:entity];
    [list removeObject:entity];
    [DataBaseManager updateToCoreData];
}
@end
