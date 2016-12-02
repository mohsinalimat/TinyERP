//
//  OrderListViewController.h
//  DemoProject
//
//  Created by user32 on 2016/11/15.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "ViewController.h"

@interface OrderListViewController : UIViewController
@property NSString *whereFrom;
@property NSMutableArray *orderList;
@property (weak, nonatomic) IBOutlet UITableView *orderListTableView;
@end
