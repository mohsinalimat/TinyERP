//
//  AccChartsViewController.m
//  DemoProject
//
//  Created by user32 on 2017/1/5.
//  Copyright © 2017年 謝騰飛. All rights reserved.
//

#import "AccChartsViewController.h"
#import "DataBaseManager.h"
@import Charts;

@interface AccChartsViewController ()
@property NSMutableArray *dataEntryList;
@end

@implementation AccChartsViewController

- (void)viewDidLoad
{
    //把所有的C單單身撈出
    //根據不同的商品加總
    [super viewDidLoad];
    CGFloat viewW = self.view.frame.size.width;
    CGFloat viewH = self.view.frame.size.height;
    PieChartView *pCharView = [[PieChartView alloc] initWithFrame:CGRectMake(0, -20, viewW, viewH)];
    self.dataEntryList = [NSMutableArray new];
    if ([self.whereFrom isEqualToString:@"apSegue"])
    {
        [self prepareForDataEntry:@"PC"];
    }
    else if ([self.whereFrom isEqualToString:@"arSegue"])
    {
        [self prepareForDataEntry:@"SC"];
    }
    
    PieChartDataSet *chartDataSet = [[PieChartDataSet alloc]initWithValues:self.dataEntryList];
    NSMutableArray *colors = [[NSMutableArray alloc]init];
    [colors addObjectsFromArray:[ChartColorTemplates material]];
    chartDataSet.colors = colors;
    PieChartData *chartData = [[PieChartData alloc] initWithDataSet:chartDataSet];
    pCharView.data = chartData;
    [pCharView animateWithYAxisDuration:2];
    [self.view addSubview:pCharView];
}

-(void)prepareForDataEntry:(NSString*)dataType
{
    NSMutableArray *orderCList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderDetailType" fiterBy:dataType];
    NSSet *itemGroup = [NSSet setWithArray:[orderCList valueForKey:@"orderItemNo"]];
    
    for (NSString *itemNo in itemGroup)
    {
        CGFloat itemSum = 0;
        for (OrderDetail *od in orderCList)
        {
            if ([itemNo isEqualToString:od.orderItemNo])
            {
                itemSum += [od.orderThisAmount floatValue];
            }
        }
        PieChartDataEntry *dataEntry = [[PieChartDataEntry alloc]initWithValue:itemSum label:itemNo];
        [self.dataEntryList addObject:dataEntry];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
