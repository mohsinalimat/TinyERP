//
//  AccountingReversedListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AccountingReversedListViewController.h"
#import "AccountingReverseViewController.h"
#import "DataBaseManager.h"
#import "OrderMaster.h"
#import "OrderDetail.h"
#import "AccChartsViewController.h"

@interface AccountingReversedListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *accountingReversedTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigationBackButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *pieChartButton;
@property NSMutableArray *orderListDidReversed;
@end

@implementation AccountingReversedListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.orderListDidReversed = [[NSMutableArray alloc]init];
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        self.orderListDidReversed = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"PC"];
        self.title = @"已沖應付";
        self.navigationBackButton.title = @"＜未沖應付";
        self.pieChartButton.title = @"支出比例";
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.orderListDidReversed = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"SC"];
        self.title = @"已沖應收";
        self.navigationBackButton.title = @"＜未沖應收";
        self.pieChartButton.title = @"收入比例";
    }
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:nil];
    [self.accountingReversedTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderListDidReversed.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accDidRevCell"];
    OrderMaster *om = [self.orderListDidReversed objectAtIndex:indexPath.row];
    cell.textLabel.text = [NSString stringWithFormat:@"[%@]%@",om.orderPartner,om.orderNo];
    return cell;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        OrderMaster *om = [self.orderListDidReversed objectAtIndex:indexPath.row];
        OrderMaster *deleteFinanceOM = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNoTwins" fiterBy:om.orderNo].firstObject;
        if (deleteFinanceOM != nil)
        {
            CoreDataHelper *help = [CoreDataHelper sharedInstance];
            [help.managedObjectContext deleteObject:deleteFinanceOM];
        }
        NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:om.orderNo];
        [OrderDetail rollbackNotYet:deadList];
        [DataBaseManager deleteOM:self.orderListDidReversed omtableView:tableView indexPath:indexPath];
        [DataBaseManager updateToCoreData];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    if ([segue.identifier isEqualToString:@"accQuerySegue"])
    {
        AccountingReverseViewController *arvc = segue.destinationViewController;
        arvc.whereFrom = @"accQuerySegue";
        arvc.accOrderListInDetail = self.orderListDidReversed;
        arvc.currentReverseOM = [self.orderListDidReversed objectAtIndex:self.accountingReversedTableView.indexPathForSelectedRow.row];
    }
    else if ([segue.identifier isEqualToString:@"accChartsSegue"])
    {
        AccChartsViewController *acvc = segue.destinationViewController;
        acvc.whereFrom = self.whereFrom;
    }
}

- (IBAction)navigationBack:(id)sender
{
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
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
