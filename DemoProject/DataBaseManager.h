//
//  DataBaseManager.h
//  DemoProject
//
//  Created by user32 on 2016/11/1.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Inventory.h"

@interface DataBaseManager : NSObject
+(NSMutableArray*)queryFromCoreData:(NSString*)entity sortBy:(NSString*)sortString;
+(NSMutableArray*)fiterFromCoreData:(NSString*)entity sortBy:(NSString*)sortString fiterFrom:(NSString*)fiterColumn fiterBy:(NSString*)fiterString;
+(NSMutableArray*)fiterFromCoreData:(NSString*)entity sortBy:(NSString*)sortString fiterFrom:(NSString*)fiterColumn fiterByArray:(NSArray*)fiterArray;
+(Inventory*)fiterInventoryFromCoreDataWithItemNo:(NSString*)fiterItemNo WithWarehouse:(NSString*)fiterWarehouse;
+(void)updateToCoreData;
+(void)deleteDataAndObject:(id)entity array:(NSMutableArray*)list;
@end
