//
//  OrderViewController.h
//  DemoProject
//
//  Created by user32 on 2016/11/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "ViewController.h"
#import "OrderMaster.h"

@interface OrderViewController : ViewController
@property OrderMaster *currentOM;
@property NSMutableArray *orderListInDteail;
@property NSString *whereFrom;
@end
