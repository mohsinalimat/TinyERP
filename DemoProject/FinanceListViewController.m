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

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //這個要設高一點...
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    tableHeaderView.backgroundColor = [UIColor yellowColor];
    CGFloat buttonXlocalPE = self.financeTableView.frame.size.width - 80;
    CGFloat buttonXlocalSE = self.financeTableView.frame.size.width - 160;
    UIButton *buttonPE = [[UIButton alloc]initWithFrame:CGRectMake(buttonXlocalPE, 0, 0, 0)];
    UIButton *buttonSE = [[UIButton alloc]initWithFrame:CGRectMake(buttonXlocalSE, 0, 0, 0)];
    buttonPE.tag = section;
    buttonSE.tag = section;
    [buttonPE setTitle:@"新增支出" forState:UIControlStateNormal];
    [buttonSE setTitle:@"新增收入" forState:UIControlStateNormal];
    [buttonPE setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [buttonSE setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    //沒有Fit按鈕不會出來.......
    [buttonPE sizeToFit];
    [buttonSE sizeToFit];
    [tableHeaderView addSubview:buttonPE];
    [tableHeaderView addSubview:buttonSE];
    [buttonPE addTarget:self action:@selector(addOrderPE:) forControlEvents:UIControlEventTouchUpInside];
    [buttonSE addTarget:self action:@selector(addOrderSE:) forControlEvents:UIControlEventTouchUpInside];
    
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.financeTableView.frame.size.width, 22)];
    BankAccount *ba = self.financeAcountList[section];
    if ([ba.bankID isEqualToString:@"000"])
    {
        sectionLabel.text = @"[000][現金]";
    }
    else
    {
        NSString *sectionTitle = [NSString stringWithFormat:@"[%@][%@][%@]",ba.bankID,ba.bankName,ba.bankAccount];
        sectionLabel.text = sectionTitle;
    }
    [tableHeaderView addSubview:sectionLabel];
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

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"finCell"];
    NSArray *array = self.finance2DList[indexPath.section];
    OrderMaster *om = array[indexPath.row];
    cell.textLabel.text = om.orderNo;
    return cell;
}

-(void)addOrderPE:(UIButton*)btn
{
    NSLog(@"%d",btn.tag);
}

-(void)addOrderSE:(UIButton*)btn
{
    NSLog(@"%d",btn.tag);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
