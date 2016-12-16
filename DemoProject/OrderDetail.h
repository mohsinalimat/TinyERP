//
//  OrderDetail.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

@interface OrderDetail : NSManagedObject
@property NSString *orderItemNo;
@property NSNumber *orderAmount;
@property NSNumber *orderNotYetAmount;
@property NSNumber *orderNotYetQty;
@property NSNumber *orderThisQty;
@property NSString *orderNo;
@property NSString *orderNoOld;
@property NSNumber *orderPrice;
@property NSNumber *orderQty;
@property NSNumber *orderSeq;
@property NSNumber *orderSeqOld;
@property NSNumber *isInventory;
@end
