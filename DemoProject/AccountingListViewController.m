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
@property (nonatomic) NSString *partner;
@property (nonatomic) UIView *headView;
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
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        self.totalOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"NotYetAmountPB" fiterBy:@"0"];
        self.partner = @"廠商";
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        self.totalOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"NotYetAmountSB" fiterBy:@"0"];
        self.partner = @"客戶";
    }
    [self.accountingSegment setTitle:self.partner forSegmentAtIndex:0];
    
    //取得單號並去重
    NSSet *orederNoGroup = [NSSet setWithArray:[self.totalOrderDetailList valueForKey:@"orderNo"]];
    
    //拿單身單號去找單頭
    NSMutableArray *orderDayList = [[NSMutableArray alloc]init];
    NSMutableArray *orderMonthList = [[NSMutableArray alloc]init];
    NSMutableArray *orderPartnerList = [[NSMutableArray alloc]init];
    for (NSString *orderNoString in orederNoGroup)
    {
        OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:orderNoString][0];
        
        NSDateFormatter *monthDF = [[NSDateFormatter alloc]init];
        [monthDF setDateFormat:@"yyyy/MM"];
        NSString *monthString = [monthDF stringFromDate:om.orderDate];
        NSDateFormatter *dayDF = [[NSDateFormatter alloc]init];
        [dayDF setDateFormat:@"yyyy/MM/dd"];
        NSString *dayString = [dayDF stringFromDate:om.orderDate];
        
        [orderDayList addObject:dayString];
        [orderMonthList addObject:monthString];
        [orderPartnerList addObject:om.orderPartner];
    }
    //交易對象跟日期再去重
    NSSet *orderDayGroup = [NSSet setWithArray:orderDayList];
    NSSet *orderMonthGroup = [NSSet setWithArray:orderMonthList];
    NSSet *orderPartnerGroup = [NSSet setWithArray:orderPartnerList];
    
    //排序
    NSArray *sortedArray = @[[[NSSortDescriptor alloc]initWithKey:nil ascending:YES]];
    NSArray *orderNoSortedList = [orederNoGroup sortedArrayUsingDescriptors:sortedArray];
    NSArray *orderDaySortedList = [orderDayGroup sortedArrayUsingDescriptors:sortedArray];
    NSArray *orderMonthSortedList = [orderMonthGroup sortedArrayUsingDescriptors:sortedArray];
    NSArray *orderPartnerSortedList = [orderPartnerGroup sortedArrayUsingDescriptors:sortedArray];
    
    self.orderNoTwoDimensionalList = [[NSMutableArray alloc]init];
    //遍歷排序過的單號
    for (NSString *orderNoString in orderNoSortedList)
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
    
    self.orderDayTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderDayString in orderDaySortedList)
    {
        //先固定格式
        NSDateFormatter *dayDF = [[NSDateFormatter alloc]init];
        [dayDF setDateFormat:@"yyyy/MM/dd"];
        
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            //先從單身找出單頭日期 再比
            OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo][0];
            NSString *dayString = [dayDF stringFromDate:om.orderDate];
            if ([orderDayString isEqualToString:dayString])
            {
                [orderDetailList addObject:od];
            }
        }
        //把單身陣列放進二維陣列
        [self.orderDayTwoDimensionalList addObject:orderDetailList];
    }
    
    self.orderMonthTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderMonthString in orderMonthSortedList)
    {
        NSDateFormatter *monthDF = [[NSDateFormatter alloc]init];
        [monthDF setDateFormat:@"yyyy/MM"];
        
        NSMutableArray *orderDetailList = [[NSMutableArray alloc]init];
        for (OrderDetail *od in self.totalOrderDetailList)
        {
            OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo][0];
            NSString *monthString = [monthDF stringFromDate:om.orderDate];
            if ([orderMonthString isEqualToString:monthString])
            {
                [orderDetailList addObject:od];
            }
        }
        [self.orderMonthTwoDimensionalList addObject:orderDetailList];
    }
    
    self.orderPartnerTwoDimensionalList = [[NSMutableArray alloc]init];
    for (NSString *orderPartnerString in orderPartnerSortedList)
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

-(NSArray*)getOMArray:(OrderDetail*)od
{
    OrderMaster *om = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:od.orderNo][0];
    
    NSDateFormatter *monthDF = [[NSDateFormatter alloc]init];
    [monthDF setDateFormat:@"yyyy/MM"];
    NSString *monthString = [monthDF stringFromDate:om.orderDate];
    NSDateFormatter *dayDF = [[NSDateFormatter alloc]init];
    [dayDF setDateFormat:@"yyyy/MM/dd"];
    NSString *dayString = [dayDF stringFromDate:om.orderDate];
    NSMutableArray *findPartnerArray;
    Partner *partner;
    NSString *partnerName = @"";
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        findPartnerArray = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerIDtypeF" fiterBy:om.orderPartner];
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        findPartnerArray = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerIDtypeC" fiterBy:om.orderPartner];
    }
    if (findPartnerArray.count != 0)
    {
        partner = findPartnerArray[0];
        partnerName = partner.partnerName;
    }
    NSArray *omArray = @[partnerName,monthString,dayString,om.orderNo];
    return omArray;
}


-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"accountingCell"];
    
    OrderDetail *od = [self getOD:indexPath];

    CGFloat orderAlreadyAmount = [od.orderAmount floatValue] - [od.orderNotYetAmount floatValue];
    cell.textLabel.text = [NSString stringWithFormat:@"          [%ld]應收%.2f已收%.2f未收%.2f",[od.orderSeq integerValue],[od.orderAmount floatValue],orderAlreadyAmount,[od.orderNotYetAmount floatValue]];
    
    return cell;
}

-(NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:section];
    OrderDetail *od = [self getOD:ip];
    NSArray *omArray = [self getOMArray:od];
    
    switch (self.accountingSummaryType)
    {
        case 0:
        {
            return [NSString stringWithFormat:@"[%ld]%@",section,omArray[0]];
            break;
        }
        case 1:
        {
            return [NSString stringWithFormat:@"[%ld]%@",section,omArray[1]];
            break;
        }
        case 2:
        {
            return [NSString stringWithFormat:@"[%ld]%@",section,omArray[2]];
            break;
        }
        case 3:
        {
            return [NSString stringWithFormat:@"[%ld]%@",section,omArray[3]];
            break;
        }
        default:
            break;
    }
    return @"";
}

//-(UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
//{
//    
//}

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end