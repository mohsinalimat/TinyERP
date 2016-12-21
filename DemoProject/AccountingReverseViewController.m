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

@interface AccountingReverseViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITextField *accOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *accOrderDate;
@property (weak, nonatomic) IBOutlet UITextField *accOrderPartner;
@property (weak, nonatomic) IBOutlet UITextField *accDiscountInput;
@property (weak, nonatomic) IBOutlet UITextField *accUserInput;
@property (weak, nonatomic) IBOutlet UITextView *accRemarkInput;
@property (weak, nonatomic) IBOutlet UITextField *accBankAccountInput;

@property (weak, nonatomic) IBOutlet UIBarButtonItem *accDidRevListBtn;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UITableView *accountingReverseTableView;
//@property NSMutableArray *accOrderDetailList;
@end

@implementation AccountingReverseViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.accountingReverseTableView.delegate = self;
    self.accountingReverseTableView.dataSource = self;
    self.accOrderNoInput.text = self.currentReverseOM.orderNo;
    self.accOrderDetailList = [NSMutableArray new];
    self.title = @"沖帳明細";
    if ([self.whereFrom isEqualToString:@"accQuerySegue"])
    {
        [self.accDidRevListBtn setEnabled:NO];
        [self.accDidRevListBtn setTintColor:[UIColor clearColor]];
        self.accOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentReverseOM.orderNo];
    }
    else if ([self.whereFrom isEqualToString:@"accCreateSegue"])
    {
        for (OrderDetail *fatherOrderDetail in self.orginalOrderDetailList)
        {
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            OrderDetail *childOD = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
            //賦值
            childOD.orderNo = self.currentReverseOM.orderNo;
            NSUInteger seq = [self.orginalOrderDetailList indexOfObject:fatherOrderDetail] + 1;
            childOD.orderSeq = @(seq);
            childOD.orderItemNo = fatherOrderDetail.orderItemNo;
            childOD.orderPrice = fatherOrderDetail.orderPrice;
            childOD.orderAmount = fatherOrderDetail.orderAmount;
            childOD.orderNotYetAmount = fatherOrderDetail.orderNotYetAmount;
            childOD.orderNoOld = fatherOrderDetail.orderNoOld;
            childOD.orderSeqOld = fatherOrderDetail.orderSeqOld;
            [self.accOrderDetailList addObject:childOD];
        }
    }
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
    accRevCell.odNotYetAmount.text = @"";
    accRevCell.odThisAmount.text = @"";
    accRevCell.odResultLabel.text = @"";
    //監聽
    [accRevCell.odThisAmount addTarget:self action:@selector(odThisAmountEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    //取物件
    OrderDetail *od = [self.accOrderDetailList objectAtIndex:indexPath.row];
    //賦值
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
        accRevCell.odItemUnitLabel.text = item.itemUnit;
    }
    accRevCell.odNotYetAmount.text = [od.orderNotYetAmount stringValue];
    CGFloat resultFloat = [accRevCell.odNotYetAmount.text floatValue] - [accRevCell.odThisAmount.text floatValue];
    accRevCell.odResultLabel.text = [@(resultFloat) stringValue];
    return accRevCell;
}

-(void)odThisAmountEditingEnd:(UITextField*)sender
{
    
}

- (IBAction)allReverse:(id)sender
{
    
}

- (IBAction)moneyTypeChange:(id)sender {
}

- (IBAction)saveReverse:(id)sender
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *orderDateString = self.accOrderDate.text;
    self.currentReverseOM.orderDate = [df dateFromString:orderDateString];
    self.currentReverseOM.orderNo = self.accOrderNoInput.text;
    self.currentReverseOM.orderUser = self.accUserInput.text;
    self.currentReverseOM.orderPartner = self.accOrderPartner.text;
    [DataBaseManager updateToCoreData];
    [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
}

- (IBAction)deleteReverse:(id)sender
{
    
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
- (IBAction)backRootView:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
