//
//  AccountingReverseViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/7.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AccountingReverseViewController.h"
#import "AccountingReversedListViewController.h"
#import "OrderDetail.h"
#import "AccRevCell.h"
#import "DataBaseManager.h"
#import "AlertManager.h"
#import "Item.h"
#import "DateManager.h"
#import "AppDelegate.h"

@interface AccountingReverseViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *accOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *accOrderDateInput;
@property (weak, nonatomic) IBOutlet UITextField *accOrderPartnerInput;
@property (weak, nonatomic) IBOutlet UITextField *accDiscountInput;
@property (weak, nonatomic) IBOutlet UITextField *accUserInput;
@property (weak, nonatomic) IBOutlet UITextView *accRemarkInput;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accFinanceType;
@property (weak, nonatomic) IBOutlet UITextField *accBankAccountInput;
@property (weak, nonatomic) IBOutlet UIButton *deleteAccOrderButton;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *accDidRevListBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UITableView *accountingReverseTableView;
@property BOOL isDeleteAction;
@property BOOL isOverAmount;
@property BOOL isLeaveVC;
@end

@implementation AccountingReverseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //代理
    self.accountingReverseTableView.delegate = self;
    self.accountingReverseTableView.dataSource = self;
    //單頭初值
    self.accOrderNoInput.text = self.currentReverseOM.orderNo;
    self.accOrderPartnerInput.text = self.currentReverseOM.orderPartner;
    self.accOrderDetailList = [NSMutableArray new];
    self.title = @"沖帳明細";
    [self.accOrderPartnerInput setEnabled:NO];
    self.accRemarkInput.layer.borderWidth = 1;
    self.accRemarkInput.layer.borderColor = self.view.tintColor.CGColor;
    if ([self.whereFrom isEqualToString:@"accQuerySegue"])
    {
        self.accOrderDateInput.text = [DateManager getFormatedDateString:self.currentReverseOM.orderDate];
        self.accUserInput.text = self.currentReverseOM.orderUser;
        self.accBankAccountInput.text = self.currentReverseOM.orderBankAccount;
        self.accFinanceType.selectedSegmentIndex = [self.currentReverseOM.orderFinanceType integerValue];
        self.accDiscountInput.text = [self.currentReverseOM.orderDiscount stringValue];
        self.totalAmountLabel.text = [@"總金額  " stringByAppendingString:[self.currentReverseOM.orderTotalAmount stringValue]];
        [self.accDidRevListBtn setEnabled:NO];
        [self.accDidRevListBtn setTintColor:[UIColor clearColor]];
        [self.deleteAccOrderButton setTitle:@"刪除單據" forState:UIControlStateNormal];
        self.accOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentReverseOM.orderNo];
        if (self.currentReverseOM.orderFinanceType>0)
        {
            [self.accBankAccountInput setEnabled:NO];
        }
        else
        {
            [self.accBankAccountInput setEnabled:YES];
        }
    }
    else if ([self.whereFrom isEqualToString:@"accCreateSegue"])
    {
        self.accOrderDateInput.text = [DateManager getTodayDateString];
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.accUserInput.text = appDLG.currentUserName;
        [self.deleteAccOrderButton setTitle:@"放棄新增" forState:UIControlStateNormal];
        //轉單身
        for (OrderDetail *fatherOrderDetail in self.orginalOrderDetailList)
        {
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            OrderDetail *childOD = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
            //帶單身
            childOD.orderNo = self.currentReverseOM.orderNo;
            NSUInteger seq = [self.orginalOrderDetailList indexOfObject:fatherOrderDetail] + 1;
            childOD.orderSeq = @(seq);
            childOD.orderItemNo = fatherOrderDetail.orderItemNo;
            childOD.orderAmount = fatherOrderDetail.orderNotYetAmount;
            childOD.orderNoOld = fatherOrderDetail.orderNo;
            childOD.orderSeqOld = fatherOrderDetail.orderSeq;
            [self.accOrderDetailList addObject:childOD];
        }
    }
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteReverseAction) name:@"deleteReverseYes" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteFinanceOrder) name:@"deleteFinanceOrderYes" object:nil];
    
}

-(void)viewWillDisappear:(BOOL)animated
{
    self.isLeaveVC = YES;
    [super viewWillDisappear:nil];
    [DataBaseManager rollbackFromCoreData];
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
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
    accRevCell.odAmount.text = @"";
    accRevCell.odThisAmount.text = @"";
    accRevCell.odResultLabel.text = @"";
    //監聽
    [accRevCell.odThisAmount addTarget:self action:@selector(odThisAmountEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    //取物件
    OrderDetail *od = [self.accOrderDetailList objectAtIndex:indexPath.row];
    //設畫面
    accRevCell.odSeq.text = [od.orderSeq stringValue];
    accRevCell.odItemNo.text = od.orderItemNo;
    [accRevCell.odItemNo setEnabled:NO];
    accRevCell.odThisAmount.tag = [od.orderSeq integerValue];
    //料號
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:od.orderItemNo];
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        accRevCell.odItemNameLabel.text = item.itemName;
    }
    
    accRevCell.odAmount.text = [od.orderAmount stringValue];
    [accRevCell.odAmount setEnabled:NO];
    accRevCell.odThisAmount.text = [od.orderThisAmount stringValue];
    CGFloat resultFloat = [accRevCell.odAmount.text floatValue] - [accRevCell.odThisAmount.text floatValue];
    accRevCell.odResultLabel.text = [@(resultFloat) stringValue];
    return accRevCell;
}

-(void)odThisAmountEditingEnd:(UITextField*)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:ip];
    OrderDetail *od = [self.accOrderDetailList objectAtIndex:sender.tag-1];
    od.orderThisAmount = @([arCell.odThisAmount.text floatValue]);
    if ([arCell.odThisAmount.text floatValue] == 0 && self.isLeaveVC != YES)
    {
        [AlertManager alert:@"異動額不可為零" controller:self];
    }
    else
    {
        CGFloat newNotYetQty = [arCell.odAmount.text floatValue] - [arCell.odThisAmount.text floatValue];
        if (newNotYetQty < 0 && self.isLeaveVC != YES)
        {
            self.isOverAmount = YES;
            [AlertManager alert:@"本次沖帳額不可大於累積未沖額" controller:self];
        }
        else
        {
            self.isOverAmount = NO;
            arCell.odResultLabel.text = [@(newNotYetQty) stringValue];
            [self sumAmount];
        }
    }
}

-(CGFloat)sumAmount
{
    CGFloat totalAmount = 0.0;
    for (NSUInteger index=0; index<self.accOrderDetailList.count; index++)
    {
        AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        totalAmount += [arCell.odThisAmount.text floatValue];
    }
    totalAmount -= [self.accDiscountInput.text floatValue];
    self.totalAmountLabel.text = [NSString stringWithFormat:@"總金額  %.2f",totalAmount];
    return totalAmount;
}

- (IBAction)allReverse:(id)sender
{
    for (OrderDetail *od in self.accOrderDetailList)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.accOrderDetailList indexOfObject:od] inSection:0];
        AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:ip];
        arCell.odThisAmount.text = [od.orderAmount stringValue];
        arCell.odResultLabel.text = [@(0) stringValue];
    }
}

- (IBAction)saveReverse:(id)sender
{
    if (self.accOrderPartnerInput.text.length==0)
    {
        [AlertManager alert:@"交易對象未填" controller:self];
    }
    else if (self.accFinanceType.selectedSegmentIndex==0 && self.accBankAccountInput.text.length==0)
    {
        [AlertManager alert:@"資金類型為銀行時\n帳號為必填" controller:self];
    }
    else if (self.accOrderDetailList.count == 0)
    {
        [AlertManager alert:@"沒有單身不可儲存" controller:self];
    }
    else
    {
        BOOL invalidOrderDteail = NO;
        for (NSUInteger i=0; i<self.accOrderDetailList.count; i++)
        {
            AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (arCell.odThisAmount.text.length==0)
            {
                invalidOrderDteail = YES;
                break;
            }
        }
        if (invalidOrderDteail == YES)
        {
            [AlertManager alert:@"有單身資料不齊全\n請檢查" controller:self];
        }
        else if (self.isOverAmount==YES)
        {
            [AlertManager alert:@"本次沖帳額不可大於累積未沖額" controller:self];
        }
        else
        {
            //存單頭
            self.currentReverseOM.orderDate = [DateManager getDateByString:self.accOrderDateInput.text];
            self.currentReverseOM.orderNo = self.accOrderNoInput.text;
            self.currentReverseOM.orderUser = self.accUserInput.text;
            self.currentReverseOM.orderPartner = self.accOrderPartnerInput.text;
            self.currentReverseOM.orderBankAccount = self.accBankAccountInput.text;
            self.currentReverseOM.orderFinanceType = @(self.accFinanceType.selectedSegmentIndex);
            self.currentReverseOM.orderTotalAmount = @([self sumAmount]);
            self.currentReverseOM.orderDiscount = @([self.accDiscountInput.text floatValue]);
            //存單身
            for (OrderDetail *od in self.accOrderDetailList)
            {
                AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.accOrderDetailList indexOfObject:od] inSection:0]];
                od.orderAmount = @([arCell.odAmount.text floatValue]);
                od.orderThisAmount = @([arCell.odThisAmount.text floatValue]);
                
                //回寫前單未沖量
                NSArray *queryArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeq" fiterByArray:@[od.orderNoOld,od.orderSeqOld]];
                OrderDetail *updateOD;
                if (queryArray.count !=0)
                {
                    updateOD = queryArray[0];
                    updateOD.orderNotYetAmount = @([arCell.odAmount.text floatValue] - [arCell.odThisAmount.text floatValue]);
                }
            }
            //第一次存
            if (self.currentReverseOM.orderNoTwins == nil)
            {
                //有帳號或現金
                if (self.accFinanceType.selectedSegmentIndex != 2)
                {
                    //(決議因單據由系統產生 故直接MAPPING)
                    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
                    OrderMaster *sonOM = [NSEntityDescription insertNewObjectForEntityForName:@"OrderMasterEntity" inManagedObjectContext:helper.managedObjectContext];
                    if ([[self.currentReverseOM.orderNo substringToIndex:1] isEqualToString:@"P"])
                    {
                        sonOM.orderType = @"PD";
                        sonOM.orderReason = @"應付沖帳";
                    }
                    else if ([[self.currentReverseOM.orderNo substringToIndex:1] isEqualToString:@"S"])
                    {
                        sonOM.orderType = @"SD";
                        sonOM.orderReason = @"應收沖帳";
                    }
                    sonOM.orderNo = [sonOM.orderType stringByAppendingString:[self.currentReverseOM.orderNo substringFromIndex:2]];
                    sonOM.orderDate = self.currentReverseOM.orderDate;
                    sonOM.orderPartner = self.currentReverseOM.orderPartner;
                    sonOM.orderTotalAmount = self.currentReverseOM.orderTotalAmount;
                    sonOM.orderUser = @"系統產生";
                    sonOM.orderBankAccount = self.currentReverseOM.orderBankAccount;
                    sonOM.orderFinanceType = self.currentReverseOM.orderFinanceType;
                    sonOM.orderDiscount = self.currentReverseOM.orderDiscount;
                    sonOM.orderNoTwins = self.currentReverseOM.orderNo;
                    self.currentReverseOM.orderNoTwins = sonOM.orderNo;
                }
            }
            else
            {
                if (self.accFinanceType.selectedSegmentIndex == 2)
                {
                    [AlertManager alertYesAndNo:@"系統已產生財務單據\n財務類型改為無,將會把財務單據刪除\n是否確定執行" yes:@"是" no:@"否" controller:self postNotificationName:@"deleteFinanceOrder"];
                }
                else
                {
                    OrderMaster *updateFinanceOM = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNoTwins" fiterBy:self.currentReverseOM.orderNo].firstObject;
                    updateFinanceOM.orderBankAccount = self.currentReverseOM.orderBankAccount;
                    updateFinanceOM.orderFinanceType = self.currentReverseOM.orderFinanceType;
                    updateFinanceOM.orderTotalAmount = self.currentReverseOM.orderTotalAmount;
                    updateFinanceOM.orderDiscount = self.currentReverseOM.orderDiscount;
                    updateFinanceOM.orderDate = self.currentReverseOM.orderDate;
                }
            }
            [DataBaseManager updateToCoreData];
            [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
        }
    }
}

-(void)deleteFinanceOrder
{
    OrderMaster *deleteFinanceOM = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNoTwins" fiterBy:self.currentReverseOM.orderNo].firstObject;
    if (deleteFinanceOM != nil)
    {
        CoreDataHelper *help = [CoreDataHelper sharedInstance];
        [help.managedObjectContext deleteObject:deleteFinanceOM];
    }
    self.currentReverseOM.orderNoTwins = nil;
    [DataBaseManager updateToCoreData];
    if (self.isDeleteAction!=YES)
    {
        [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
    }
}

- (IBAction)deleteReverse:(id)sender
{
    if ([self.whereFrom isEqualToString:@"accQuerySegue"])
    {
        [AlertManager alertYesAndNo:@"請確認是否刪除" yes:@"是" no:@"否" controller:self postNotificationName:@"deleteReverse"];
    }
    else if ([self.whereFrom isEqualToString:@"accCreateSegue"])
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

-(void)deleteReverseAction
{
    self.isDeleteAction = YES;
    NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentReverseOM.orderNo];
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    for (OrderDetail *deadOD in deadList)
    {
        [OrderDetail rollbackNotYet:@[deadOD]];
        [helper.managedObjectContext deleteObject:deadOD];
    }
    [self deleteFinanceOrder];
    [DataBaseManager deleteDataAndObject:self.currentReverseOM array:self.accOrderListInDetail];
    [DataBaseManager updateToCoreData];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"accRevSegue"])
    {
        AccountingReversedListViewController *arlvc = segue.destinationViewController;
        if ([[self.currentReverseOM.orderNo substringToIndex:2]isEqualToString:@"PC"])
        {
            arlvc.whereFrom = @"apSegue";
        }
        else if ([[self.currentReverseOM.orderNo substringToIndex:2]isEqualToString:@"SC"])
        {
            arlvc.whereFrom = @"arSegue";
        }
    }
}

- (IBAction)ChangeFinanceType:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex>0)
    {
        [self.accBankAccountInput setEnabled:NO];
        self.accBankAccountInput.text = @"";
    }
    else
    {
        [self.accBankAccountInput setEnabled:YES];
    }
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        [OrderDetail rollbackNotYet:@[[self.accOrderDetailList objectAtIndex:indexPath.row]]];
        [OrderDetail deleteOrderDetail:[self.accOrderDetailList objectAtIndex:indexPath.row] array:self.accOrderDetailList tableView:self.accountingReverseTableView indexPath:indexPath];
        if (self.accOrderDetailList.count != 0)
        {
            for (NSInteger i=indexPath.row; i <= self.accOrderDetailList.count-1; i++)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                AccRevCell *arCell = [self.accountingReverseTableView cellForRowAtIndexPath:ip];
                arCell.odThisAmount.tag -= 1 ;
                OrderDetail *od = [self.accOrderDetailList objectAtIndex:i];
                int newSeq = [od.orderSeq intValue];
                newSeq -= 1;
                od.orderSeq = @(newSeq);
            }
        }
        self.currentReverseOM.orderCount = @(self.accOrderDetailList.count);
        [self.accountingReverseTableView reloadData];
    }
}

- (IBAction)backRootView:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
