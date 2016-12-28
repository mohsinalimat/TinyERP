//
//  AccountingReverseViewController.h
//  DemoProject
//
//  Created by user32 on 2016/12/7.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OrderMaster.h"

@interface AccountingReverseViewController : UIViewController
@property NSMutableArray *orginalOrderDetailList;
@property NSMutableArray *accOrderDetailList;
@property NSMutableArray *accOrderListInDetail;
@property OrderMaster *currentReverseOM;
@property NSString *whereFrom;
@end
