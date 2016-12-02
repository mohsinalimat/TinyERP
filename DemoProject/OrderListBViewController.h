//
//  OrderListBViewController.h
//  DemoProject
//
//  Created by user32 on 2016/11/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "ViewController.h"

@interface OrderListBViewController : UIViewController
@property NSString *whereFromB;
@property NSMutableArray *orderListB;
@property (weak, nonatomic) IBOutlet UITableView *orderListBTableView;
@end
