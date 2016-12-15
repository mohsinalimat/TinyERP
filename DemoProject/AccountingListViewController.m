//
//  AccountingListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/7.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AccountingListViewController.h"
#import "CoreDataHelper.h"
#import "DataBaseManager.h"
#import "OrderMaster.h"
#import "OrderDetail.h"
#import "Partner.h"

@interface AccountingListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *accountingTableView;
@property (weak, nonatomic) IBOutlet UISegmentedControl *accountingSegment;
@property (nonatomic) NSUInteger accountingSummaryType;
@property (nonatomic) NSMutableArray *totalOrderDetailList;
@property (nonatomic) NSMutableArray *orderPartnerTwoDimensionalList;
@property (nonatomic) NSMutableArray *orderMonthTwoDimensionalList;
@property (nonatomic) NSMutableArray *orderDayTwoDimensionalList;
@property (nonatomic) NSMutableArray *orderNoTwoDimensionalList;

@property (nonatomic) NSArray *orderNoSortedList;
@property (nonatomic) NSArray *orderDaySortedList;
@property (nonatomic) NSArray *orderMonthSortedList;
@property (nonatomic) NSArray *orderPartnerSortedList;

@property (nonatomic) NSString *partner;
@end

@implementation AccountingListViewController

- (void)viewDidLoad
{
    
    [super viewDidLoad];
    self.accountingSummaryType = 0;
    //代理區
    self.accountingTableView.delegate = self;
    self.accountingTableView.dataSource = self;
    //UI
    //並撈出所有未沖單身
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        self.totalOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"NotYetAmountPB" fiterBy:@"0"];
        self.partner = @"廠商";
        self.title = @"未沖應付";
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.totalOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"NotYetAmountSB" fiterBy:@"0"];
        self.partner = @"客戶";
        self.title = @"未沖應收";
    }
    //預設為零
    [self.accountingSegment setTitle:self.partner forSegmentAtIndex:0];
    
    //取得單號並去重
    NSSet *orederNoGroup = [NSSet setWithArray:[self.totalOrderDetailList valueForKey:@"orderNo"]];
    
    NSMutableArray *orderDayList = [[NSMutableArray alloc]init];
    NSMutableArray *orderMonthList = [[NSMutableArray alloc]init];
    NSMutableArray *orderPartnerList = [[NSMutableArray alloc]init];
    for (NSString *orderNoString in orederNoGroup)
    {
        //拿單身單號去找單頭 並存字串
        OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:orderNoString][0];
        
        NSDateFormatter *monthDF = [[NSDateFormatter alloc]init];
        [monthDF setDateFormat:@"yyyy/MM"];
        NSString *monthString = [monthDF stringFromDate:om.orderDate];
        NSString *partnerMonthString = [om.orderPartner stringByAppendingFormat:@"_%@",monthString];
        
        NSDateFormatter *dayDF = [[NSDateFormatter alloc]init];
        [dayDF setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [dayDF stringFromDate:om.orderDate];
        NSString *partnerDayString = [om.orderPartner stringByAppendingFormat:@"_%@",dayString];
        
        [orderMonthList addObject:partnerMonthString];
        [orderDayList addObject:partnerDayString];
        [orderPartnerList addObject:om.orderPartner];
    }
    //交易對象跟日期再去重
    NSSet *orderDayGroup = [NSSet setWithArray:orderDayList];
    NSSet *orderMonthGroup = [NSSet setWithArray:orderMonthList];
    NSSet *orderPartnerGroup = [NSSet setWithArray:orderPartnerList];
    
    //排序
    NSArray *sortedArray = @[[[NSSortDescriptor alloc]initWithKey:nil ascending:YES]];
    
    self.orderNoSortedList = [orederNoGroup sortedArrayUsingDescriptors:sortedArray];
    self.orderDaySortedList = [orderDayGroup sortedArrayUsingDescriptors:sortedArray];
    self.orderMonthSortedList = [orderMonthGroup sortedArrayUsingDescriptors:sortedArray];
    self.orderPartnerSortedList = [orderPartnerGroup sortedArrayUsingDescriptors:sortedArray];
    
    //單號維度
    self.orderNoTwoDimensionalList = [[NSMutableArray alloc]init];
    //遍歷排序過的單號
    for (NSString *orderNoString in self.orderNoSortedList)
    {
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            //如果單號跟單身的單號一樣 就放到單身陣列
            if ([orderNoString isEqualToString:od.orderNo])
            {
                [orderDetailList addObject:od];
            }
        }
        //把單身陣列放進二維陣列
        [self.orderNoTwoDimensionalList addObject:orderDetailList];
    }
    
    //日期維度
    self.orderDayTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderDayString in self.orderDaySortedList)
    {
        //先固定格式
        NSDateFormatter *dayDF = [[NSDateFormatter alloc]init];
        [dayDF setDateFormat:@"yyyy/MM/dd"];
        
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            //先從單身找出單頭日期 再比
            NSArray *omArray = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo];
            OrderMaster *om;
            if (omArray.count != 0)
            {
                om = omArray[0];
            }
            NSString *dayString = [dayDF stringFromDate:om.orderDate];
            NSString *partnerDayString = [om.orderPartner stringByAppendingFormat:@"_%@",dayString];
            if ([orderDayString isEqualToString:partnerDayString])
            {
                [orderDetailList addObject:od];
            }
        }
        //把單身陣列放進二維陣列
        [self.orderDayTwoDimensionalList addObject:orderDetailList];
    }
    
    //月份維度
    self.orderMonthTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderMonthString in self.orderMonthSortedList)
    {
        NSDateFormatter *monthDF = [[NSDateFormatter alloc]init];
        [monthDF setDateFormat:@"yyyy/MM"];
        
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            NSArray *omArray = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo];
            OrderMaster *om;
            if (omArray.count != 0)
            {
                om = omArray[0];
            }
            
            NSString *monthString = [monthDF stringFromDate:om.orderDate];
            NSString *partnerMonthString = [om.orderPartner stringByAppendingFormat:@"_%@",monthString];
            if ([orderMonthString isEqualToString:partnerMonthString])
            {
                [orderDetailList addObject:od];
            }
        }
        [self.orderMonthTwoDimensionalList addObject:orderDetailList];
    }
    
    //交易對象維度
    self.orderPartnerTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderPartnerString in self.orderPartnerSortedList)
    {
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo][0];
            if ([orderPartnerString isEqualToString:om.orderPartner])
            {
                [orderDetailList addObject:od];
            }
        }
        [self.orderPartnerTwoDimensionalList addObject:orderDetailList];
    }
}

//改變維度
- (IBAction)AccountingSummaryChanged:(UISegmentedControl*)sender
{
    switch (sender.selectedSegmentIndex)
    {
        case 0:
            self.accountingSummaryType = 0;
            break;
        case 1:
            self.accountingSummaryType = 1;
            break;
        case 2:
            self.accountingSummaryType = 2;
            break;
        case 3:
            self.accountingSummaryType = 3;
            break;
        default:
            break;
    }
    [self.accountingTableView reloadData];
}

//幾個Seciton
-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    switch (self.accountingSummaryType)
    {
        case 0:
            return self.orderPartnerTwoDimensionalList.count;
        case 1:
            return self.orderMonthTwoDimensionalList.count;
        case 2:
            return self.orderDayTwoDimensionalList.count;
        case 3:
            return self.orderNoTwoDimensionalList.count;
        default:
            break;
    }
    return 0;
}

//幾個Row
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    switch (self.accountingSummaryType)
    {
        case 0:
        {
            NSArray *partnerTypeList = self.orderPartnerTwoDimensionalList[section];
            return partnerTypeList.count;
        }
        case 1:
        {
            NSArray *monthTypeList = self.orderMonthTwoDimensionalList[section];
            return monthTypeList.count;
        }
        case 2:
        {
            NSArray *dayTypeList = self.orderDayTwoDimensionalList[section];
            return dayTypeList.count;
        }
        case 3:
        {
            NSArray *orderNoTypeList = self.orderNoTwoDimensionalList[section];
            return orderNoTypeList.count;
        }
        default:
            break;
    }
    return 0;
}

//Row資料呈現
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountingCell"];
    
    OrderDetail *od = [self getOD:indexPath];
    //已沖
    CGFloat orderAlreadyAmount = [od.orderAmount floatValue] - [od.orderNotYetAmount floatValue];
    cell.textLabel.text = [NSString stringWithFormat:@"          [%ld]應收%.2f已收%.2f未收%.2f",
                           [od.orderSeq integerValue],
                           [od.orderAmount floatValue],
                           orderAlreadyAmount,
                           [od.orderNotYetAmount floatValue]];
    
    return cell;
}

-(OrderDetail*)getOD:(NSIndexPath*)indexPath
{
    OrderDetail *od;
    switch (self.accountingSummaryType)
    {
        case 0:
        {
            od = self.orderPartnerTwoDimensionalList[indexPath.section][indexPath.row];
            break;
        }
        case 1:
        {
            od = self.orderMonthTwoDimensionalList[indexPath.section][indexPath.row];
            break;
        }
        case 2:
        {
            od = self.orderDayTwoDimensionalList[indexPath.section][indexPath.row];
            break;
        }
        case 3:
        {
            od = self.orderNoTwoDimensionalList[indexPath.section][indexPath.row];
            break;
        }
        default:
            break;
    }
    return od;
}

//沒有這個方法viewForHeader就不會出現
-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    return @" ";
}

//Section資料呈現
-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    //不知這邊為何大小設0,0沒用
    //self.accountingTableView.tableHeaderView.frame.size.width
    //self.accountingTableView.tableHeaderView.frame.size.height
    //self.accountingTableView.estimatedSectionHeaderHeight
    //上面都是0
    //然後這個是-1 self.accountingTableView.sectionHeaderHeight
    UIView *tableHeaderView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, 0, 0)];
    tableHeaderView.backgroundColor = [UIColor yellowColor];
    CGFloat buttonXlocal = self.accountingTableView.frame.size.width - 100;
    //大小一樣沒用
    UIButton *reverseButton = [[UIButton alloc]initWithFrame:CGRectMake(buttonXlocal, 0, 0, 0)];
    reverseButton.tag = section;
    //按了UI看不出變化
    [reverseButton setTitle:@"沖帳請按我" forState:UIControlStateNormal];
    [reverseButton setTitleColor:[UIColor redColor] forState:UIControlStateNormal];
    [reverseButton sizeToFit];
    [tableHeaderView addSubview:reverseButton];
    [reverseButton addTarget:self action:@selector(transferARVC:) forControlEvents:UIControlEventTouchUpInside];
    
    NSString *sectionTitle;
    UILabel *sectionLabel = [[UILabel alloc]initWithFrame:CGRectMake(5, 0, self.accountingTableView.frame.size.width, 22)];
    switch (self.accountingSummaryType)
    {
        case 0:
        {
            sectionTitle = self.orderPartnerSortedList[section];
            break;
        }
        case 1:
        {            sectionTitle = self.orderMonthSortedList[section];
            break;
        }
        case 2:
        {
            sectionTitle = self.orderDaySortedList[section];
            break;
        }
        case 3:
        {
            sectionTitle = self.orderNoSortedList[section];
            break;
        }
        default:
            break;
    }
    sectionLabel.text = sectionTitle;
    [tableHeaderView addSubview:sectionLabel];
    return tableHeaderView;
}

-(void)transferARVC:(UIButton*)btn
{
    [self performSegueWithIdentifier:@"accSegue" sender:btn];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(UIButton*)sender
{
    NSLog(@"%ld",sender.tag);
}

- (IBAction)gestureLeft:(id)sender
{
    switch (self.accountingSummaryType)
    {
        case 0:
        case 1:
        case 2:
            self.accountingSummaryType += 1;
            self.accountingSegment.selectedSegmentIndex += 1;
            [self.accountingTableView reloadData];
            break;
        default:
            break;
    }
}

- (IBAction)gestureRight:(id)sender
{
    switch (self.accountingSummaryType)
    {
        case 0:
            [self.navigationController popViewControllerAnimated:YES];
            break;
        default:
            self.accountingSummaryType -= 1;
            self.accountingSegment.selectedSegmentIndex -= 1;
            [self.accountingTableView reloadData];
            break;
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
