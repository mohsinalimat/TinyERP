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

@interface OrderListViewController () <UITableViewDelegate,UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *upBarLabel;
@property (weak, nonatomic) IBOutlet UIButton *upBarButton;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *notYetOrder;
@property BOOL isViewDidLoad;
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
    self.isViewDidLoad = YES;
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
    //產生單頭物件
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    OrderMaster *om = [NSEntityDescription insertNewObjectForEntityForName:@"OrderMasterEntity" inManagedObjectContext:helper.managedObjectContext];
    //單頭初值
    if ([self.whereFrom isEqualToString:@"pSegue"])
    {
        om.orderType = @"PA";
    }
    else if ([self.whereFrom isEqualToString:@"sSegue"])
    {
        om.orderType = @"SA";
    }
    om.orderCount = 0;
    //處理單號日期
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"YYMMdd"];
    NSDate *date = [NSDate date];
    NSString *dateString = [formatter stringFromDate:date];
    //處理單號流水
    NSString *waterNoString;
    //如果完全沒單
    if (self.orderList.count == 0)
    {
        //那就是當然的一號
        waterNoString = @"001";
    }
    else
    {
        BOOL isTodayOrderNo = NO;
        //遍歷
        for (OrderMaster *om in self.orderList)
        {
            NSString *orderNoDate = [om.orderNo substringWithRange:NSMakeRange(2,6)];
            if ([orderNoDate isEqualToString:dateString])
            {
                isTodayOrderNo = YES;
                break;
            }
        }
        //如果今天都沒單
        if (isTodayOrderNo == NO)
        {
            //那還是今天的一號
            waterNoString = @"001";
        }
        else
        {
            OrderMaster *lastOM;
            //順流 逆流
            if (self.isViewDidLoad == YES)
            {
                //最後面
                lastOM = [self.orderList objectAtIndex:self.orderList.count-1];
            }
            else
            {
                //第一個
                lastOM = [self.orderList objectAtIndex:0];
            }
            waterNoString = [lastOM.orderNo substringFromIndex:8];
            NSInteger waterNoInt = [waterNoString integerValue];
            waterNoInt += 1;
            NSNumber *waterNo = @(waterNoInt);
            waterNoString = [waterNo stringValue];
            if (waterNoString.length == 1)
            {
                waterNoString = [@"00" stringByAppendingString:waterNoString];
            }
            else if (waterNoString.length == 2)
            {
                waterNoString = [@"0" stringByAppendingString:waterNoString];
            }
        }
    }
    //組單號
    NSString *orderNoString = [om.orderType stringByAppendingFormat:@"%@%@",dateString,waterNoString];
    om.orderNo = orderNoString;
    
    [self.orderList insertObject:om atIndex:0];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.orderListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [DataBaseManager updateToCoreData];
    
    //生成ViewController
    OrderViewController *ovc = [self.storyboard instantiateViewControllerWithIdentifier:@"orderViewController"];
    //把物件跟陣列丟過去
    ovc.whereFrom = @"aSegue";
    ovc.currentOM = om;
    ovc.orderListInDteail = self.orderList;
    //這邊走之前也要改掉啊........
    self.isViewDidLoad = NO;
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
#pragma mark Q.很奇怪為何一進這個VC就會跑到這裡？
    self.isViewDidLoad = NO;
}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
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

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}


- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
