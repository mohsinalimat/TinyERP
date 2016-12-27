//
//  FinanceCell.h
//  DemoProject
//
//  Created by user32 on 2016/12/27.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FinanceCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UITextField *finOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderDateInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderUserInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderPartnerInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderReasonInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderDiscountInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderAmountInput;
@property (weak, nonatomic) IBOutlet UITextField *finOrderNoTwinsInput;
@property (strong, nonatomic) IBOutletCollection(UITextField) NSArray *finOrderSevenInput;

@end








