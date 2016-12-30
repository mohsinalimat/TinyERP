//
//  InventoryOrderListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/27.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "InventoryOrderListViewController.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "InventoryOrderViewController.h"

@interface InventoryOrderListViewController () <UITableViewDelegate,UITableViewDataSource>
@property NSMutableArray *inventoryOrderList;
@end

@implementation InventoryOrderListViewController

- (void)viewDidLoad
{
    self.inventoryOrderTableView.delegate = self;
    self.inventoryOrderTableView.dataSource = self;
    self.inventoryOrderList = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderTypeF" fiterBy:@"F"];
    self.title = @"庫存異動單";
    [super viewDidLoad];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:nil];
    self.inventoryOrderList = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderTypeF" fiterBy:@"F"];
    [self.inventoryOrderTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.inventoryOrderList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"invOrderCell"];
    OrderMaster *om = [self.inventoryOrderList objectAtIndex:indexPath.row];
    if ([om.orderType isEqualToString:@"PF"])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"[入庫]%@",om.orderNo];
    }
    else if ([om.orderType isEqualToString:@"SF"])
    {
        cell.textLabel.text = [NSString stringWithFormat:@"[出庫]%@",om.orderNo];
    }
    return cell;
}

- (IBAction)addInventoryOrder:(id)sender
{
    InventoryOrderViewController *iovc = [self.storyboard instantiateViewControllerWithIdentifier:@"inventoryOrderViewController"];
    iovc.invOrderListInDetail = self.inventoryOrderList;
    [self showViewController:iovc sender:self];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        OrderMaster *om = [self.inventoryOrderList objectAtIndex:indexPath.row];
        NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:om.orderNo];
        for (OrderDetail *deadOD in deadList)
        {
            [Inventory rollbackInventory:deadOD warehouse:om.orderWarehouse orderNoBegin:om.orderType];
        }
        [DataBaseManager deleteOM:self.inventoryOrderList omtableView:tableView indexPath:indexPath];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    InventoryOrderViewController *iovc = segue.destinationViewController;
    iovc.currentInventoryOM = [self.inventoryOrderList objectAtIndex:self.inventoryOrderTableView.indexPathForSelectedRow.row];
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
