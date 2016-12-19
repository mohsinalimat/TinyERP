//
//  AccountingReversedListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AccountingReversedListViewController.h"
#import "DataBaseManager.h"
#import "OrderMaster.h"

@interface AccountingReversedListViewController () <UITableViewDelegate,UITableViewDataSource>
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
- (IBAction)backRootView:(id)sender
{
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
