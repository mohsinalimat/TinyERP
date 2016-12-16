//
//  AccRevCell.h
//  DemoProject
//
//  Created by user32 on 2016/12/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface AccRevCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UILabel *odSeq;
@property (weak, nonatomic) IBOutlet UITextField *odItemNo;
@property (weak, nonatomic) IBOutlet UILabel *odItemNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *odItemUnitLabel;

@property (weak, nonatomic) IBOutlet UITextField *odNotYetAmount;
@property (weak, nonatomic) IBOutlet UITextField *odThisAmount;
@property (weak, nonatomic) IBOutlet UILabel *odResultLabel;
@end
