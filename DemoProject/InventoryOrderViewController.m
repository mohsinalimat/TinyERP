//
//  InventoryOrderViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/27.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "InventoryOrderViewController.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "DateManager.h"
#import "AppDelegate.h"
#import "OrderMasterManager.h"
#import "InvOredrDetailCell.h"
#import "OrderDetail.h"
#import "Item.h"
#import "AlertManager.h"
#import "DataPickerManager.h"
#import "DateManager.h"

@interface InventoryOrderViewController () <UITableViewDataSource,UITableViewDelegate,UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITextField *invOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderDateInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderUserInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderWarehouseInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderReasonInput;
@property (weak, nonatomic) IBOutlet UITableView *invOrderDetailTableView;
@property (weak, nonatomic) IBOutlet UIButton *deleteOrderButton;
@property (weak, nonatomic) IBOutlet UISegmentedControl *invTransType;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property NSMutableArray *invOrderDetailList;
@property NSUInteger odCount;
@property DataPickerManager *dpm;
@property DateManager *dm;
@end

@implementation InventoryOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.invOrderDetailTableView.delegate = self;
    self.invOrderDetailTableView.dataSource = self;
    self.invOrderDateInput.delegate = self;
    self.invOrderWarehouseInput.delegate = self;
    self.invOrderReasonInput.delegate = self;
    self.invOrderDetailList = [NSMutableArray new];
    self.dm = [DateManager new];
    self.dpm = [DataPickerManager new];
    if (self.currentInventoryOM==nil)
    {
        self.invOrderDateInput.text = [DateManager getTodayDateString];
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.invOrderUserInput.text = appDLG.currentUserName;
        self.invOrderNoInput.text = @"存檔後自動產生";
        [self.deleteOrderButton setTitle:@"放棄新增" forState:UIControlStateNormal];
        self.odCount = 0;
    }
    else
    {
        self.invOrderDateInput.text = [DateManager getFormatedDateString:self.currentInventoryOM.orderDate];
        self.invOrderUserInput.text = self.currentInventoryOM.orderUser;
        self.invOrderNoInput.text = self.currentInventoryOM.orderNo;
        self.invOrderReasonInput.text = self.currentInventoryOM.orderReason;
        [self.invTransType setEnabled:NO];
        [self.invOrderWarehouseInput setEnabled:NO];
        if ([self.currentInventoryOM.orderType isEqualToString:@"PF"])
        {
            self.invTransType.selectedSegmentIndex = 0;
        }
        else
        {
            self.invTransType.selectedSegmentIndex = 1;
        }
        self.odCount = [self.currentInventoryOM.orderCount integerValue];
        [self.deleteOrderButton setTitle:@"刪除單據" forState:UIControlStateNormal];
        self.invOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentInventoryOM.orderNo];
    }
    self.invOrderWarehouseInput.text = self.currentInventoryOM.orderWarehouse;
    [self.invOrderNoInput setEnabled:NO];
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteInvAction) name:@"deleteInvOrderYes" object:nil];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:nil];
    [DataBaseManager rollbackFromCoreData];
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.invOrderWarehouseInput)
    {
        [self.dpm showDataPicker:self dataField:textField dataSource:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"倉庫" headerView:nil];
    }
    else if (textField == self.invOrderReasonInput)
    {
        [self.dpm showDataPicker:self dataField:textField dataSource:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"異動理由" headerView:nil];
    }
    else if (textField == self.invOrderDateInput)
    {
        [self.dm showDatePicker:self dateField:textField];
    }
}

-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.invOrderWarehouseInput || textField == self.invOrderReasonInput)
    {
        [self.dpm.pv removeFromSuperview];
    }
    else
    {
        [self.dm.dp removeFromSuperview];
    }
}

//不可變更
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    return NO;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.invOrderDetailList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvOredrDetailCell *iodCell = [tableView dequeueReusableCellWithIdentifier:@"invOrderDetailCell"];
    iodCell.invOrderItemNameLabel.text = @"";
    iodCell.invOrderItemUnitLabel.text = @"";
    iodCell.invOrderQtyInput.text = @"";
    [iodCell.invOrderItemNoInput setEnabled:YES];
    
    iodCell.invOrderItemNoInput.placeholder = @"料號";
    iodCell.invOrderQtyInput.placeholder = @"異動量";
    
    OrderDetail *od = [self.invOrderDetailList objectAtIndex:indexPath.row];
    if (od.isInventory != nil)
    {
        [iodCell.invOrderItemNoInput setEnabled:NO];
    }
    iodCell.invOrderSeqLabel.text = [od.orderSeq stringValue];
    iodCell.invOrderItemNoInput.text = od.orderItemNo;
    iodCell.invOrderQtyInput.text = [od.orderQty stringValue];
    [self showItemNameAndUnit:od.orderItemNo iodCell:iodCell];
    iodCell.invOrderItemNoInput.delegate = self;
    iodCell.invOrderQtyInput.delegate = self;
    iodCell.invOrderQtyInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    [iodCell.invOrderItemNoInput addTarget:self action:@selector(invOrderItemNoEditingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [iodCell.invOrderItemNoInput addTarget:self action:@selector(invOrderItemNoEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    iodCell.invOrderItemNoInput.tag = indexPath.row;
    return iodCell;
}

-(void)invOrderItemNoEditingBegin:(UITextField*)sender
{
    [self.dpm showDataPicker:self dataField:sender dataSource:@"ItemEntity" sortBy:@"itemNo" fiterFrom:nil fiterBy:nil headerView:self.headerView];
}

-(void)invOrderItemNoEditingEnd:(UITextField*)sender
{
    InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:sender.tag inSection:0]];
    [self showItemNameAndUnit:iodCell.invOrderItemNoInput.text iodCell:iodCell];
    [self.dpm.pv removeFromSuperview];
}

-(void)showItemNameAndUnit:(NSString*)itemNo iodCell:(InvOredrDetailCell*)iodCell
{
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:itemNo];
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        iodCell.invOrderItemNameLabel.text = item.itemName;
        iodCell.invOrderItemUnitLabel.text = item.itemUnit;
    }
}

- (IBAction)addInvOrderDetail:(id)sender
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    OrderDetail *od = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
    self.odCount += 1;
    od.orderSeq = @(self.odCount);
    [self.invOrderDetailList addObject:od];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.odCount-1 inSection:0];
    [self.invOrderDetailTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.invOrderDetailTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)saveInvOrder:(id)sender
{
    if (self.invOrderWarehouseInput.text.length==0)
    {
        [AlertManager alert:@"倉庫未填" controller:self];
    }
    else if (self.invOrderDetailList.count == 0)
    {
        [AlertManager alert:@"沒有單身不可儲存" controller:self];
    }
    else
    {
        //檢查單身
        BOOL invalid = NO;
        for (NSUInteger i=0; i<self.invOrderDetailList.count; i++)
        {
            InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (iodCell.invOrderItemNoInput.text.length==0 || iodCell.invOrderQtyInput.text.length==0 || [iodCell.invOrderQtyInput.text floatValue]==0)
            {
                invalid = YES;
            }
        }
        if (invalid==YES)
        {
            [AlertManager alert:@"單身資料不齊全" controller:self];
        }
        else
        {
            //沒單頭建單頭
            if (self.currentInventoryOM==nil)
            {
                if (self.invTransType.selectedSegmentIndex == 0)
                {
                    OrderMaster *om = [OrderMasterManager createOrderMaster:@"PF" orderList:self.invOrderListInDetail];
                    self.currentInventoryOM = om;
                }
                else
                {
                    OrderMaster *om = [OrderMasterManager createOrderMaster:@"SF" orderList:self.invOrderListInDetail];
                    self.currentInventoryOM = om;
                }
            }
            //存單頭
            self.currentInventoryOM.orderDate = [DateManager getDateByString:self.invOrderDateInput.text];
            self.currentInventoryOM.orderUser = self.invOrderUserInput.text;
            self.currentInventoryOM.orderWarehouse = self.invOrderWarehouseInput.text;
            self.currentInventoryOM.orderCount = @(self.odCount);
            self.currentInventoryOM.orderReason = self.invOrderReasonInput.text;
            //存單身
            for (OrderDetail *od in self.invOrderDetailList)
            {
                InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.invOrderDetailList indexOfObject:od] inSection:0]];
                od.orderNo = self.currentInventoryOM.orderNo;
                od.orderSeq = @([iodCell.invOrderSeqLabel.text integerValue]);
                od.orderItemNo = iodCell.invOrderItemNoInput.text;
                od.orderQty = @([iodCell.invOrderQtyInput.text floatValue]);
            }
            [Inventory calculateInventory:self.invOrderDetailList warehouse:self.currentInventoryOM.orderWarehouse orderNoBegin:self.currentInventoryOM.orderType];
            [DataBaseManager updateToCoreData];
            [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
        }
    }
}

- (IBAction)deleteInvOrder:(id)sender
{
    if (self.currentInventoryOM==nil)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        [AlertManager alertYesAndNo:@"是否確定刪除單據" yes:@"是" no:@"否" controller:self postNotificationName:@"deleteInvOrder"];
    }
}

-(void)deleteInvAction
{
    NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentInventoryOM.orderNo];
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    for (OrderDetail *deadOD in deadList)
    {
        [Inventory rollbackInventory:deadOD warehouse:self.currentInventoryOM.orderWarehouse orderNoBegin:self.currentInventoryOM.orderType];
        [helper.managedObjectContext deleteObject:deadOD];
    }
    [DataBaseManager updateToCoreData];
    [DataBaseManager deleteDataAndObject:self.currentInventoryOM array:self.invOrderListInDetail];
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        if (self.currentInventoryOM != nil)
        {
            [Inventory rollbackInventory:[self.invOrderDetailList objectAtIndex:indexPath.row] warehouse:self.currentInventoryOM.orderWarehouse orderNoBegin:self.currentInventoryOM.orderType];
        }
        [OrderDetail deleteOrderDetail:[self.invOrderDetailList objectAtIndex:indexPath.row] array:self.invOrderDetailList tableView:self.invOrderDetailTableView indexPath:indexPath];
        if (self.invOrderDetailList.count != 0)
        {
            for (NSInteger i=indexPath.row; i <= self.invOrderDetailList.count-1; i++)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:ip];
                iodCell.invOrderItemNoInput.tag -= 1 ;
                OrderDetail *od = [self.invOrderDetailList objectAtIndex:i];
                int newSeq = [od.orderSeq intValue];
                newSeq -= 1;
                od.orderSeq = @(newSeq);
            }
        }
        [self.invOrderDetailTableView reloadData];
        self.odCount -= 1;
    }
}

- (IBAction)backRootView:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)gestureRight:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
