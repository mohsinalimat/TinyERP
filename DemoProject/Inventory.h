//
//  Inventory.h
//  DemoProject
//
//  Created by user32 on 2016/11/25.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <CoreData/CoreData.h>
#import "OrderDetail.h"

@interface Inventory : NSManagedObject
@property NSString *itemNo;
@property NSString *warehouse;
@property NSNumber *qty;
+(void)calculateInventory:(NSArray*)orderDetailList warehouse:(NSString*)warehouse orderNoBegin:(NSString*)orderNoBegin;
+(void)rollbackInventory:(OrderDetail*)od warehouse:(NSString*)warehouse orderNoBegin:(NSString*)orderNoBegin;
@end
