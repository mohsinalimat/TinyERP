//
//  FinanceListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/23.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "FinanceListViewController.h"
#import "DataBaseManager.h"
#import "BankAccount.h"
#import "CoreDataHelper.h"
#import "FinanceCell.h"
#import "DateManager.h"
#import "OrderMasterManager.h"
#import "AlertManager.h"
#import "AppDelegate.h"

@interface FinanceListViewController () <UITableViewDelegate,UITableViewDataSource>
@property NSMutableArray *financeAcountList;
@property NSMutableArray *financeOrderList;
@property NSMutableArray *finance2DList;
@end

@implementation FinanceListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //代理
    self.financeTableView.delegate = self;
    self.financeTableView.dataSource = self;
    self.finance2DList = [NSMutableArray new];
    //帳戶資料
    self.financeAcountList = [DataBaseManager queryFromCoreData:@"BankAccountEntity" sortBy:@"bankID"];
    BOOL exisitCash = NO;
    for (BankAccount *ba in self.financeAcountList)
    {
        if ([ba.bankID isEqualToString:@"000"])
        {
            exisitCash = YES;
            break;
        }
    }
    if (exisitCash == NO)
    {
        CoreDataHelper *hp = [CoreDataHelper sharedInstance];
        BankAccount *cashAccount = [NSEntityDescription insertNewObjectForEntityForName:@"BankAccountEntity" inManagedObjectContext:hp.managedObjectContext];
        cashAccount.bankID = @"000";
        cashAccount.bankName = @"現金";
        [self.financeAcountList insertObject:cashAccount atIndex:0];
    }
    //單據資料
    self.financeOrderList = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderDE" fiterBy:@"DE"];
    for (OrderMaster *om in self.financeOrderList)
    {
        NSLog(@"%@",om.orderNo);
    }
    [self splitArray];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)splitArray
{
    self.finance2DList = [NSMutableArray array];
    for (BankAccount *ba in self.financeAcountList)
    {
        NSMutableArray *accountArray = [NSMutableArray new];
        for (OrderMaster *om in self.financeOrderList)
        {
            if ([ba.bankID isEqualToString:@"000"] && [om.orderFinanceType integerValue] == 1)
            {
                [accountArray addObject:om];
            }
            else if ([ba.bankAccount isEqualToString:om.orderBankAccount])
            {
                [accountArray addObject:om];
            }
        }
        [self.finance2DList addObject:accountArray];
    }
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:nil];
    [DataBaseManager rollbackFromCoreData];
}

-(CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 44.0;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //自訂View
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    tableHeaderView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    //按鈕
    CGFloat buttonXlocalPE = self.financeTableView.frame.size.width - 80;
    CGFloat buttonXlocalSE = self.financeTableView.frame.size.width - 160;
    UIButton *buttonPE = [[UIButton alloc]initWithFrame:CGRectMake(buttonXlocalPE, 18, 0, 0)];
    UIButton *buttonSE = [[UIButton alloc]initWithFrame:CGRectMake(buttonXlocalSE, 18, 0, 0)];
    buttonPE.tag = section;
    buttonSE.tag = section;
    [buttonPE setTitle:@"新增支出" forState:UIControlStateNormal];
    [buttonSE setTitle:@"新增收入" forState:UIControlStateNormal];
    [buttonPE setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    [buttonSE setTitleColor:self.view.tintColor forState:UIControlStateNormal];
    //沒有Fit按鈕不會出來.......
    [buttonPE sizeToFit];
    [buttonSE sizeToFit];
    [tableHeaderView addSubview:buttonPE];
    [tableHeaderView addSubview:buttonSE];
    //hihi
    [buttonPE addTarget:self action:@selector(addOrderPE:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSE addTarget:self action:@selector(addOrderSE:) forControlEvents:UIControlEventTouchUpInside];
    //帳號title
    UILabel *sectionTitleLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.financeTableView.frame.size.width, 22)];
    BankAccount *ba = self.financeAcountList[section];
    if ([ba.bankID isEqualToString:@"000"])
    {
        sectionTitleLabel.text = @"[000][現金]";
    }
    else
    {
        NSString *sectionTitle = [NSString stringWithFormat:@"[%@][%@][%@]",ba.bankID,ba.bankName,ba.bankAccount];
        sectionTitleLabel.text = sectionTitle;
    }
    [tableHeaderView addSubview:sectionTitleLabel];
    //金額title
    UILabel *sectionAmountLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 24, self.financeTableView.frame.size.width, 22)];
    //先拆分
    NSArray *sectionArray = self.finance2DList[section];
    NSMutableArray *sectionArrayP = [NSMutableArray new];
    NSMutableArray *sectionArrayS = [NSMutableArray new];
    for (OrderMaster *om in sectionArray)
    {
        if ([[om.orderNo substringToIndex:1]isEqualToString:@"P"])
        {
            [sectionArrayP addObject:om];
        }
        else if ([[om.orderNo substringToIndex:1]isEqualToString:@"S"])
        {
            [sectionArrayS addObject:om];
        }
    }
    NSNumber *sectionAmountP = [sectionArrayP valueForKeyPath:@"@sum.orderTotalAmount"];
    NSNumber *sectionAmountS = [sectionArrayS valueForKeyPath:@"@sum.orderTotalAmount"];
    CGFloat sectionAmount = [sectionAmountS floatValue] - [sectionAmountP floatValue];
    sectionAmountLabel.text = [NSString stringWithFormat:@"總金額  %.2f",sectionAmount];
    [tableHeaderView addSubview:sectionAmountLabel];
    return tableHeaderView;
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.financeAcountList.count;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    NSArray *array = self.finance2DList[section];
    return array.count;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 80.0;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    FinanceCell *finCell = [tableView dequeueReusableCellWithIdentifier:@"finCell"];
    NSArray *array = self.finance2DList[indexPath.section];
    OrderMaster *om = array[indexPath.row];
    finCell.finOrderNoInput.text = om.orderNo;
    finCell.finOrderDateInput.text = [DateManager getFormatedDateString:om.orderDate];
    finCell.finOrderUserInput.text = om.orderUser;
    finCell.finOrderNoTwinsInput.text = om.orderNoTwins;
    finCell.finOrderAmountInput.text = [om.orderTotalAmount stringValue];
    finCell.finOrderDiscountInput.text = [om.orderDiscount stringValue];
    finCell.finOrderReasonInput.text = om.orderReason;
    finCell.finOrderPartnerInput.text = om.orderPartner;
    [finCell.finOrderNoInput setEnabled:NO];
    [finCell.finOrderNoTwinsInput setEnabled:NO];
    if ([om.orderUser isEqualToString:@"系統產生"])
    {
        for (UITextField *field in finCell.finOrderSevenInput)
        {
            [field setEnabled:NO];
        }
        finCell.finOrderUserInput.textColor = [UIColor purpleColor];
    }
    else
    {
        finCell.finOrderUserInput.textColor = [UIColor colorWithRed:0.95 green:0.7 blue:0 alpha:1];
    }
    if ([[om.orderNo substringToIndex:1]isEqualToString:@"P"])
    {
        finCell.finOrderNoInput.textColor = [UIColor redColor];
    }
    else if ([[om.orderNo substringToIndex:1]isEqualToString:@"S"])
    {
        finCell.finOrderNoInput.textColor = [UIColor colorWithRed:0 green:0.7 blue:0 alpha:1];
    }
    return finCell;
}

-(void)tableView:(UITableView *)tableView didselectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
}

-(void)addOrderPE:(UIButton*)btn
{
    [self addOrder:@"PE" section:btn.tag];
}

-(void)addOrderSE:(UIButton*)btn
{
    [self addOrder:@"SE" section:btn.tag];
}

-(void)addOrder:(NSString*)orderType section:(NSUInteger)section
{
    OrderMaster *om = [OrderMasterManager createOrderMaster:orderType orderList:self.financeOrderList];
    BankAccount *ba = self.financeAcountList[section];
    if ([ba.bankID isEqualToString:@"000"])
    {
        om.orderFinanceType = @(1);
    }
    else
    {
        om.orderFinanceType = @(0);
        om.orderBankAccount = ba.bankAccount;
    }
    om.orderDate = [NSDate date];
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    om.orderUser = appDLG.currentUserName;
    [self.financeOrderList addObject:om];
    NSLog(@"%@",om.orderNo);
    [self splitArray];
    [self.financeTableView reloadData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        NSMutableArray *array = self.finance2DList[indexPath.section];
        OrderMaster *om = array[indexPath.row];
        if ([om.orderUser isEqualToString:@"系統產生"])
        {
            [AlertManager alert:@"此單據為系統產生，不可刪除\n請至沖帳管理修改" controller:self];
        }
        else
        {
            //生成物件
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            //刪DB
            [helper.managedObjectContext deleteObject:om];
            //刪陣列
            [array removeObjectAtIndex:indexPath.row];
            //刪cell
            [self.financeTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //寫DB
            [DataBaseManager updateToCoreData];
        }
    }
}

-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:NO];
}

- (IBAction)saveFinanceOrder:(id)sender
{
    BOOL invaildOM = NO;
    for (NSUInteger accountIndex=0; accountIndex<self.financeAcountList.count; accountIndex++)
    {
        for (OrderMaster *om in self.finance2DList[accountIndex])
        {
            NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.finance2DList[accountIndex] indexOfObject:om] inSection:accountIndex];
            FinanceCell *finCell = [self.financeTableView cellForRowAtIndexPath:ip];
            NSLog(@"%@",finCell.finOrderAmountInput.text);
            if (finCell.finOrderAmountInput.text.length==0)
            {
                invaildOM = YES;
                goto invaild;
            }
            om.orderDate = [DateManager getDateByString:finCell.finOrderDateInput.text];
            om.orderUser = finCell.finOrderUserInput.text;
            om.orderTotalAmount = @([finCell.finOrderAmountInput.text floatValue]);
            om.orderDiscount = @([finCell.finOrderDiscountInput.text floatValue]);
            om.orderReason = finCell.finOrderReasonInput.text;
            om.orderPartner = finCell.finOrderPartnerInput.text;
        }
    }
    invaild:
    if (invaildOM == YES)
    {
        [AlertManager alert:@"資料金額未填" controller:self];
    }
    else
    {
        [DataBaseManager updateToCoreData];
        [AlertManager alertWithoutButton:@"儲存成功" controller:self time:0.5 action:@"popVC"];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
