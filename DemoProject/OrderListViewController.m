//
//  OrderListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/15.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "OrderListViewController.h"
#import "OrderMaster.h"
#import "OrderDetail.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "OrderViewController.h"
#import "OrderMasterManager.h"
#import "AlertManager.h"
#import "OrderChartsViewController.h"

@interface OrderListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *upBarLabel;
@property (weak, nonatomic) IBOutlet UIButton *upBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notYetOrder;
@end

@implementation OrderListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderListTableView.delegate = self;
    self.orderListTableView.dataSource = self;
    
    self.orderList = [[NSMutableArray alloc]init];
    
    if ([self.whereFrom isEqualToString:@"pSegue"])
    {
        self.title=@"採購單據";
        self.upBarLabel.text = @"採購單";
        self.notYetOrder.title = @"已採未收";
        [self.upBarButton setTitle:@"新增採購" forState:UIControlStateNormal];
        self.orderList = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"PA"];
    }
    else if ([self.whereFrom isEqualToString:@"sSegue"])
    {
        self.title=@"銷售單據";
        self.upBarLabel.text = @"訂單";
        self.notYetOrder.title = @"已訂未出";
        [self.upBarButton setTitle:@"新增訂單" forState:UIControlStateNormal];
        self.orderList = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"SA"];
    }
}

//這樣交易對象才不會是null
-(void)viewWillAppear:(BOOL)animated
{
    [self.orderListTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"orderCell"];
    OrderMaster *om = [self.orderList objectAtIndex:indexPath.row];
    NSString *title = [NSString stringWithFormat:@"[%@]%@",om.orderPartner,om.orderNo];
    cell.textLabel.text = title;
    return cell;
}

- (IBAction)upBarButton:(id)sender
{
    OrderMaster *om;
    //單頭初值
    if ([self.whereFrom isEqualToString:@"pSegue"])
    {
        om = [OrderMasterManager createOrderMaster:@"PA" orderList:self.orderList];
    }
    else if ([self.whereFrom isEqualToString:@"sSegue"])
    {
        om = [OrderMasterManager createOrderMaster:@"SA" orderList:self.orderList];
    }
    
    [self.orderList insertObject:om atIndex:0];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.orderListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [DataBaseManager updateToCoreData];
    
    //生成ViewController
    OrderViewController *ovc = [self.storyboard instantiateViewControllerWithIdentifier:@"orderViewController"];
    //把物件跟陣列丟過去
    ovc.whereFrom = @"aSegue";
    ovc.currentOM = om;
    ovc.orderListInDteail = self.orderList;
    //換頁
    [self showViewController:ovc sender:self];
}

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"aSegue"])
    {
        //生成ViewController物件
        OrderViewController *ovc = segue.destinationViewController;
        //找到被選的cell
        NSIndexPath *ip = self.orderListTableView.indexPathForSelectedRow;
        //生成物件
        OrderMaster *om = [self.orderList objectAtIndex:ip.row];
        //把物件跟陣列丟過去
        ovc.whereFrom = segue.identifier;
        ovc.currentOM = om;
        ovc.orderListInDteail = self.orderList;
    }
    else if ([segue.identifier isEqualToString:@"orderChartsSegue"])
    {
        OrderChartsViewController *ocvc = segue.destinationViewController;
        ocvc.whereFrom = self.whereFrom;
    }
#pragma mark Q.很奇怪為何一進這個VC就會跑到這裡？
}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        OrderMaster *om = [self.orderList objectAtIndex:indexPath.row];
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
            OrderMaster *om = [self.orderList objectAtIndex:indexPath.row];
            NSString *orderNo = om.orderNo;
            //刪DB
            [helper.managedObjectContext deleteObject:om];
            //刪陣列
            [self.orderList removeObjectAtIndex:indexPath.row];
            //刪cell
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //單身也要刪
            NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:orderNo];
            for (OrderDetail *deadOD in deadList)
            {
                [helper.managedObjectContext deleteObject:deadOD];
            }
            //寫DB
            [DataBaseManager updateToCoreData];
        }
    }
}

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
