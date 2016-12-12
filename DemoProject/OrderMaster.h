//
//  OrderMaster.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

@interface OrderMaster : NSManagedObject
@property NSString *oderPreOrder;
@property NSDate *orderDate;
@property NSString *orderNo;
@property NSString *orderPartner;
@property NSNumber *orderTotalAmount;
@property NSString *orderUser;
@property NSString *orderWarehouse;
@property NSString *orderType;
@property NSNumber *orderCount;
@property NSDate *orderExpectedDay;
@end
