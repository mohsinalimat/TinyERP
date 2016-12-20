//
//  OrderDetailCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/17.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface OrderDetailCell : UITableViewCell
//AB單都要
@property (weak, nonatomic) IBOutlet UILabel *odSeq;
@property (weak, nonatomic) IBOutlet UITextField *odItemNo;
@property (weak, nonatomic) IBOutlet UILabel *odItemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *odItemUnitLabel;
@property (weak, nonatomic) IBOutlet UILabel *odResultLabel;
//A單
@property (weak, nonatomic) IBOutlet UITextField *odQty;
@property (weak, nonatomic) IBOutlet UITextField *odPrice;
//B單
@property (weak, nonatomic) IBOutlet UITextField *odThisQty;
@end
