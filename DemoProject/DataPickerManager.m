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
#import "Partner.h"
#import "Item.h"

@implementation DataPickerManager

-(void)showDataPicker:(UIViewController*)controller dataField:(UITextField*)dataField dataSource:(NSString*)dataSource sortBy:(NSString*)sortBy fiterFrom:(NSString*)fiterFrom fiterBy:(NSString*)fiterBy headerView:(UIView*)headerView
{
    CGFloat vcWidth = controller.view.frame.size.width;
    CGFloat vcHeight = controller.view.frame.size.height;
    if ([dataSource isEqualToString:@"ItemEntity"])
    {
        CGFloat viewY = headerView.frame.origin.y;
        CGFloat viewH = headerView.frame.size.height;
        self.pv = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, vcWidth, viewY+viewH)];
    }
    else if ([dataSource isEqualToString:@"BankAccountEntity"] || [dataSource isEqualToString:@"PartnerEntity"] || [fiterBy isEqualToString:@"財務理由"])
    {
        self.pv = [[UIPickerView alloc]initWithFrame:CGRectMake(0, 0, vcWidth, vcHeight/4)];
    }
    else
    {
        self.pv = [[UIPickerView alloc]initWithFrame:CGRectMake(0, vcHeight/5, vcWidth, vcHeight/3)];
    }
    self.pv.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    self.pv.delegate = self;
    self.dataField = dataField;
    self.dataSource = dataSource;
    if (fiterBy == nil)
    {
        self.dataSourceList = [DataBaseManager queryFromCoreData:dataSource sortBy:sortBy];
    }
    else
    {
        self.dataSourceList = [DataBaseManager fiterFromCoreData:dataSource sortBy:sortBy fiterFrom:fiterFrom fiterBy:fiterBy];
    }
    if ([self.dataSource isEqualToString:@"BankAccountEntity"])
    {
        [self.dataSourceList removeObjectAtIndex:0];
    }
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
    else if ([self.dataSource isEqualToString:@"PartnerEntity"])
    {
        Partner *p = self.dataSourceList[row];
        NSString *pString = [NSString stringWithFormat:@"[%@]%@",p.partnerID,p.partnerName];
        return pString;
    }
    else if ([self.dataSource isEqualToString:@"ItemEntity"])
    {
        Item *item = self.dataSourceList[row];
        NSString *itemString = [NSString stringWithFormat:@"[%@]%@",item.itemNo,item.itemName];
        return itemString;
    }
    else
    {
        BasicData *bd = self.dataSourceList[row];
        return bd.basicDataName;
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
    else if ([self.dataSource isEqualToString:@"PartnerEntity"])
    {
        Partner *p = self.dataSourceList[row];
        self.dataField.text = p.partnerID;
    }
    else if ([self.dataSource isEqualToString:@"ItemEntity"])
    {
        Item *item = self.dataSourceList[row];
        self.dataField.text = item.itemNo;
    }
    else
    {
        BasicData *bd = self.dataSourceList[row];
        self.dataField.text = bd.basicDataName;
    }
}


@end
