//
//  OrderMasterManager.h
//  DemoProject
//
//  Created by user32 on 2016/12/19.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "OrderMaster.h"

@interface OrderMasterManager : NSObject
+(OrderMaster*)createOrderMaster:(NSString*)orderBegin orderList:(NSMutableArray*)orderList;
@end
