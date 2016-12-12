//
//  OrderDetailCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/17.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *odSeq;
@property (weak, nonatomic) IBOutlet UITextField *odItemNo;
@property (weak, nonatomic) IBOutlet UILabel *odItemName;
@property (weak, nonatomic) IBOutlet UILabel *odItemUnit;
@property (weak, nonatomic) IBOutlet UITextField *odQty;
@property (weak, nonatomic) IBOutlet UITextField *odAlreadyQty;
@property (weak, nonatomic) IBOutlet UITextField *odPrice;
@property (weak, nonatomic) IBOutlet UILabel *odAmount;
@end
