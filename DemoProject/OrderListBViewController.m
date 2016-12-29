//
//  OrderListBViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "OrderListBViewController.h"
#import "OrderListViewController.h"
#import "OrderViewController.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "OrderDetail.h"
#import "OrderMasterManager.h"
#import "AlertManager.h"

@interface OrderListBViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *downBarLabel;
@property (weak, nonatomic) IBOutlet UIButton *downBarButton;
@property BOOL isViewDidLoad;

@end

@implementation OrderListBViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.orderListBTableView.delegate = self;
    self.orderListBTableView.dataSource = self;
    self.orderListB = [[NSMutableArray alloc]init];
    self.isViewDidLoad = YES;
}

//因為whereFrom只會傳給爸爸, VDL時還抓不到爸爸, 故寫在VWA
-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:YES];
    OrderListViewController *olvc = (OrderListViewController*)self.parentViewController;
    self.whereFromB = olvc.whereFrom;
    if ([self.whereFromB isEqualToString:@"pSegue"])
    {
        self.downBarLabel.text = @"進貨單";
        [self.downBarButton setTitle:@"新增收貨" forState:UIControlStateNormal];
        
        if (self.isViewDidLoad == YES)
        {
            self.orderListB = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"PB"];
        }
        
    }
    else if ([self.whereFromB isEqualToString:@"sSegue"])
    {
        self.downBarLabel.text = @"銷貨單";
        [self.downBarButton setTitle:@"新增出貨" forState:UIControlStateNormal];
        
        if (self.isViewDidLoad == YES)
        {
            self.orderListB = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"SB"];
        }
    }
    [self.orderListBTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderListB.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCellB"];
    OrderMaster *om = [self.orderListB objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"[%@]%@",om.orderPartner,om.orderNo];
    cell.textLabel.text = title;
    return cell;
}

- (IBAction)downBarButton:(id)sender
{
    OrderMaster *om;
    if ([self.whereFromB isEqualToString:@"pSegue"])
    {
        om = [OrderMasterManager createOrderMaster:@"PB" orderList:self.orderListB];
    }
    else if ([self.whereFromB isEqualToString:@"sSegue"])
    {
        om = [OrderMasterManager createOrderMaster:@"SB" orderList:self.orderListB];
    }
    
    [self.orderListB insertObject:om atIndex:0];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.orderListBTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [DataBaseManager updateToCoreData];
    
    //生成ViewController
    OrderViewController *ovc = [self.storyboard instantiateViewControllerWithIdentifier:@"orderViewController"];
    //把物件跟陣列丟過去
    ovc.whereFrom = @"bSegue";
    ovc.currentOM = om;
    ovc.orderListInDteail = self.orderListB;
    self.isViewDidLoad = NO;
    //換頁
    [self showViewController:ovc sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"bSegue"])
    {
        //生成ViewController物件
        OrderViewController *ovc = segue.destinationViewController;
        //找到被選的cell
        NSIndexPath *ip = self.orderListBTableView.indexPathForSelectedRow;
        //生成物件
        OrderMaster *om = [self.orderListB objectAtIndex:ip.row];
        //把物件跟陣列丟過去
        ovc.whereFrom = segue.identifier;
        ovc.currentOM = om;
        ovc.orderListInDteail = self.orderListB;
        self.isViewDidLoad = NO;
    }
}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        OrderMaster *om = [self.orderListB objectAtIndex:indexPath.row];
        NSString *findPostOrderString = [OrderDetail isPostOrder:[DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:om.orderNo]];
        if (findPostOrderString.length != 0)
        {
            NSString *finalString = [NSString stringWithFormat:@"%@，不可刪除",findPostOrderString];
            [AlertManager alert:finalString controller:self];
        }
        else
        {
            //生成物件
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            OrderMaster *om = [self.orderListB objectAtIndex:indexPath.row];
            NSString *orderNo = om.orderNo;
            NSString *warehouse = om.orderWarehouse;
            //刪DB
            [helper.managedObjectContext deleteObject:om];
            //刪陣列
            [self.orderListB removeObjectAtIndex:indexPath.row];
            //刪cell
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //單身也要刪
            NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:orderNo];
            for (OrderDetail *deadOD in deadList)
            {
                [Inventory rollbackInventory:deadOD warehouse:warehouse orderNoBegin:[om.orderNo substringToIndex:1]];
                [OrderDetail rollbackNotYet:@[deadOD]];
                [helper.managedObjectContext deleteObject:deadOD];
            }
            //寫DB
            [DataBaseManager updateToCoreData];
        }
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
