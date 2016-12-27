//
//  InvOredrDetailCell.h
//  DemoProject
//
//  Created by user32 on 2016/12/27.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InvOredrDetailCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *invOrderSeqLabel;
@property (weak, nonatomic) IBOutlet UITextField *invOrderItemNoInput;
@property (weak, nonatomic) IBOutlet UILabel *invOrderItemNameLabel;
@property (weak, nonatomic) IBOutlet UITextField *invOrderQtyInput;
@property (weak, nonatomic) IBOutlet UILabel *invOrderItemUnitLabel;

@end
