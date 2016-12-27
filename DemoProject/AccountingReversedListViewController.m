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

@interface AccountingReversedListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *accountingReversedTableView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *navigationBackButton;
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
        self.navigationBackButton.title = @"未沖應付";
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.orderListDidReversed = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"SC"];
        self.title = @"已沖應收";
        self.navigationBackButton.title = @"未沖應收";
    }
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
        [DataBaseManager deleteOM:self.orderListDidReversed omtableView:tableView indexPath:indexPath];
    }
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AccountingReverseViewController *arvc = segue.destinationViewController;
    arvc.whereFrom = @"accQuerySegue";
    arvc.currentReverseOM = [self.orderListDidReversed objectAtIndex:self.accountingReversedTableView.indexPathForSelectedRow.row];
}

- (IBAction)navigationBack:(id)sender
{
    [self.navigationController popToViewController:self.navigationController.viewControllers[1] animated:YES];
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
