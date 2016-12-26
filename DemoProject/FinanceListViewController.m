//
//  FinanceListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/23.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "FinanceListViewController.h"
#import "DataBaseManager.h"

@interface FinanceListViewController () <UITableViewDelegate,UITableViewDataSource>
@property NSMutableArray *bankAcountList;
@property NSMutableArray *financeOrderList;
@end

@implementation FinanceListViewController

- (void)viewDidLoad
{
    self.financeTableView.delegate = self;
    self.financeTableView.dataSource = self;
    self.bankAcountList = [DataBaseManager queryFromCoreData:@"BankAccountEntity" sortBy:@"bankID"];
    [super viewDidLoad];
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return self.bankAcountList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"finCell"];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
