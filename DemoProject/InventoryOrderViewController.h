//
//  InventoryOrderViewController.h
//  DemoProject
//
//  Created by user32 on 2016/12/27.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderMaster.h"

@interface InventoryOrderViewController : UIViewController
@property OrderMaster *currentInventoryOM;
@property NSMutableArray *invOrderListInDetail;
@end
