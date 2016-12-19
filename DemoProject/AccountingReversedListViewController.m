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
@property NSMutableArray *orderListDidReversed;
@end

@implementation AccountingReversedListViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.orderListDidReversed = [[NSMutableArray alloc]init];
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        self.orderListDidReversed = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"PC"];
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.orderListDidReversed = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderType" fiterBy:@"SC"];
    }
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        self.title = @"已沖應收";
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.title = @"已沖應付";
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
    cell.textLabel.text = om.orderNo;
    return cell;
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AccountingReverseViewController *arvc = segue.destinationViewController;
    arvc.whereFrom = @"accQuerySegue";
    arvc.currentReverseOM = [self.orderListDidReversed objectAtIndex:self.accountingReversedTableView.indexPathForSelectedRow.row];
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
