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

@interface InventoryOrderViewController () <UITableViewDataSource,UITableViewDelegate>
@property (weak, nonatomic) IBOutlet UITextField *invOrderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderDateInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderUserInput;
@property (weak, nonatomic) IBOutlet UITextField *invOrderWarehouseInput;
@property (weak, nonatomic) IBOutlet UITableView *invOrderDetailTableView;
@property (weak, nonatomic) IBOutlet UITextField *invOrderTypeInput;
@property NSMutableArray *invOrderDetailList;
@property NSUInteger odCount;
@end

@implementation InventoryOrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.invOrderDetailTableView.delegate = self;
    self.invOrderDetailTableView.dataSource = self;
    self.invOrderDetailList = [NSMutableArray new];
    if (self.currentInventoryOM==nil)
    {
        self.invOrderDateInput.text = [DateManager getTodayDateString];
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.invOrderUserInput.text = appDLG.currentUserName;
        self.invOrderNoInput.text = @"存檔後自動產生";
        self.odCount = 0;
    }
    else
    {
        self.invOrderDateInput.text = [DateManager getFormatedDateString:self.currentInventoryOM.orderDate];
        self.invOrderUserInput.text = self.currentInventoryOM.orderUser;
        self.invOrderNoInput.text = self.currentInventoryOM.orderNo;
        [self.invOrderTypeInput setEnabled:NO];
        self.odCount = [self.currentInventoryOM.orderCount integerValue];
    }
    self.invOrderWarehouseInput.text = self.currentInventoryOM.orderWarehouse;
    self.invOrderTypeInput.text = self.currentInventoryOM.orderType;
    [self.invOrderNoInput setEnabled:NO];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.invOrderDetailList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    InvOredrDetailCell *iodCell = [tableView dequeueReusableCellWithIdentifier:@"invOredrDetailCell"];
    OrderDetail *od = [self.invOrderDetailList objectAtIndex:indexPath.row];
    iodCell.invOrderSeqLabel.text = [od.orderSeq stringValue];
    iodCell.invOrderItemNoInput.text = od.orderItemNo;
    iodCell.invOrderQtyInput.text = [od.orderQty stringValue];
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:od.orderItemNo];
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        iodCell.invOrderItemNameLabel.text = item.itemName;
        iodCell.invOrderItemUnitLabel.text = item.itemUnit;
    }
    return iodCell;
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
    else if (self.invOrderTypeInput.text.length==0)
    {
        [AlertManager alert:@"類型未填" controller:self];
    }
    else
    {
        //檢查單身
        BOOL invalid = NO;
        for (NSUInteger i=0; i<self.invOrderDetailList.count; i++)
        {
            InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
            if (iodCell.invOrderItemNoInput.text.length==0 || iodCell.invOrderQtyInput.text.length==0)
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
                if ([self.invOrderTypeInput.text isEqualToString:@"PF"])
                {
                    OrderMaster *om = [OrderMasterManager createOrderMaster:@"PF" orderList:self.invOrderListInDetail];
                    self.currentInventoryOM = om;
                }
                else if([self.invOrderTypeInput.text isEqualToString:@"SF"])
                {
                    OrderMaster *om = [OrderMasterManager createOrderMaster:@"SF" orderList:self.invOrderListInDetail];
                    self.currentInventoryOM = om;
                }
            }
            //存單頭
            self.currentInventoryOM.orderDate = [DateManager getDateByString:self.invOrderDateInput.text];
            self.currentInventoryOM.orderUser = self.invOrderUserInput.text;
            self.currentInventoryOM.orderWarehouse = self.invOrderWarehouseInput.text;
            self.currentInventoryOM.orderType = self.invOrderTypeInput.text;
            self.currentInventoryOM.orderCount = @(self.odCount);
            //存單身
            for (OrderDetail *od in self.invOrderDetailList)
            {
                InvOredrDetailCell *iodCell = [self.invOrderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.invOrderDetailList indexOfObject:od] inSection:0]];
                od.orderNo = self.currentInventoryOM.orderNo;
                od.orderSeq = @([iodCell.invOrderSeqLabel.text integerValue]);
                od.orderItemNo = iodCell.invOrderItemNoInput.text;
                od.orderQty = @([iodCell.invOrderQtyInput.text floatValue]);
            }
            [DataBaseManager updateToCoreData];
            [self.navigationController popViewControllerAnimated:YES];
        }
        
    }
}

- (IBAction)deleteInvOrder:(id)sender
{
    
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
