//
//  DataPickerManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/30.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "DataPickerManager.h"
#import "DataBaseManager.h"
#import "BankAccount.h"
#import "BasicData.h"

@implementation DataPickerManager

-(void)showDataPicker:(UIViewController*)controller dataField:(UITextField*)dataField dataSource:(NSString*)dataSource sortBy:(NSString*)sortBy
{
    CGFloat vcWidth = controller.view.frame.size.width;
    CGFloat vcHeight = controller.view.frame.size.height;
    self.pv = [[UIPickerView alloc]initWithFrame:CGRectMake(0, vcHeight/2, vcWidth, vcHeight/3)];
    self.pv.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    self.pv.delegate = self;
    self.dataField = dataField;
    self.dataSource = dataSource;
    self.dataSourceList = [DataBaseManager queryFromCoreData:dataSource sortBy:sortBy];
    [controller.view addSubview:self.pv];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return self.dataSourceList.count;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.dataSource isEqualToString:@"BankAccountEntity"])
    {
        BankAccount *ba = self.dataSourceList[row];
        NSString *baString = [NSString stringWithFormat:@"[%@][%@]%@",ba.bankID,ba.bankName,ba.bankAccount];
        return baString;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.dataSource isEqualToString:@"BankAccountEntity"])
    {
        BankAccount *ba = self.dataSourceList[row];
        self.dataField.text = ba.bankAccount;
    }
}


@end
