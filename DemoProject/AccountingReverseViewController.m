//
//  AccountingReverseViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/7.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AccountingReverseViewController.h"
#import "OrderDetail.h"
#import "AccRevCell.h"
#import "DataBaseManager.h"
#import "Item.h"

@interface AccountingReverseViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *accOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *accOrderDate;
@property (weak, nonatomic) IBOutlet UITextField *accOrderPartner;
@property (weak, nonatomic) IBOutlet UITextField *accDiscountInput;


@property (weak, nonatomic) IBOutlet UITextField *accUserInput;
@property (weak, nonatomic) IBOutlet UITextView *accRemarkInput;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UITableView *accountingReverseTableView;
@end

@implementation AccountingReverseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountingReverseTableView.delegate = self;
    self.accountingReverseTableView.dataSource = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.accOrderDetailList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //產生cell並馬上清空殘留
    AccRevCell *accRevCell = [tableView dequeueReusableCellWithIdentifier:@"accRevCell"];
    accRevCell.odItemNameLabel.text = @"";
    accRevCell.odItemUnitLabel.text = @"";
    accRevCell.odNotYetAmount.text = @"";
    accRevCell.odThisAmount.text = @"";
    accRevCell.odResultLabel.text = @"";
    //監聽
    [accRevCell.odThisAmount addTarget:self action:@selector(odThisAmountEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    //取物件
    OrderDetail *od = [self.accOrderDetailList objectAtIndex:indexPath.row];
    //賦值
    accRevCell.odItemNo.text = od.orderItemNo;
    [accRevCell.odItemNo setEnabled:NO];
    //料號
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:od.orderItemNo];
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        accRevCell.odItemNameLabel.text = item.itemName;
        accRevCell.odItemUnitLabel.text = item.itemUnit;
    }
    accRevCell.odNotYetAmount.text = [od.orderNotYetAmount stringValue];
    CGFloat resultFloat = [accRevCell.odNotYetAmount.text floatValue] - [accRevCell.odThisAmount.text floatValue];
    accRevCell.odResultLabel.text = [@(resultFloat) stringValue];
    return accRevCell;
}

-(void)odThisAmountEditingEnd
{
    
}

- (IBAction)allReverse:(id)sender {
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
