//
//  OrderChartsViewController.m
//  DemoProject
//
//  Created by user32 on 2017/1/5.
//  Copyright © 2017年 謝騰飛. All rights reserved.
//

#import "OrderChartsViewController.h"
#import "DataBaseManager.h"
@import Charts;
@interface OrderChartsViewController ()
@property NSMutableArray *dataEntryList;
@property NSMutableArray *xValuesStringList;
@end

@implementation OrderChartsViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    CGFloat viewW = self.view.frame.size.width;
    CGFloat viewH = self.view.frame.size.height;
    HorizontalBarChartView *hbCharView = [[HorizontalBarChartView alloc] initWithFrame:CGRectMake(0, 0, viewW, viewH)];
    
    hbCharView.xAxis.valueFormatter = self;
    
    self.dataEntryList = [NSMutableArray new];
    self.xValuesStringList = [NSMutableArray new];
    if ([self.whereFrom isEqualToString:@"pSegue"])
    {
        [self prepareForDataEntry:@"orderNotYetQtyPA" xAxis:hbCharView.xAxis];
    }
    else if ([self.whereFrom isEqualToString:@"sSegue"])
    {
        [self prepareForDataEntry:@"orderNotYetQtySA" xAxis:hbCharView.xAxis];    }
    
    BarChartDataSet *chartDataSet = [[BarChartDataSet alloc] initWithValues:self.dataEntryList];
    
    BarChartData *chartData = [[BarChartData alloc] initWithDataSet:chartDataSet];
    
    hbCharView.data = chartData;
    [hbCharView animateWithYAxisDuration:2];
    [self.view addSubview:hbCharView];
}

- (void)prepareForDataEntry:(NSString*)dataType xAxis:(ChartAxisBase*)xAxis
{
    NSMutableArray *notYatOrder = [NSMutableArray new];
    notYatOrder = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNotYetQty" fiterFrom:dataType fiterBy:@"0"];
    
    NSMutableArray *notYatOrderNo = [notYatOrder valueForKey:@"orderNo"];
    NSMutableArray *notYatOrderSeq = [notYatOrder valueForKey:@"orderSeq"];
    NSMutableArray *notYatOrderQty = [notYatOrder valueForKey:@"orderQty"];
    
    for (NSUInteger index=0; index<notYatOrder.count; index++)
    {
        NSString *orderNo = [notYatOrderNo objectAtIndex:index];
        NSString *orderSeq = [notYatOrderSeq objectAtIndex:index];
        NSString *noAndSeqString = [orderNo stringByAppendingFormat:@"_%@",orderSeq];
        NSNumber *qty = [notYatOrderQty objectAtIndex:index];
        BarChartDataEntry *dataEntry = [[BarChartDataEntry alloc]initWithX:index y:[qty doubleValue]];
        [self.xValuesStringList addObject:noAndSeqString];
        [self stringForValue:index axis:xAxis];
        [self.dataEntryList addObject:dataEntry];
    }
}

- (NSString *)stringForValue:(double)value axis:(ChartAxisBase *)axis
{
    NSUInteger index = (NSUInteger)value;
    return self.xValuesStringList[index];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
