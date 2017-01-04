//
//  OrderViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/16.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "OrderViewController.h"
#import "CoreDataHelper.h"
#import "DataBaseManager.h"
#import "OrderDetail.h"
#import "OrderDetailCell.h"
#import "Item.h"
#import "BasicData.h"
#import "Partner.h"
#import "OrderListViewController.h"
#import "OrderListBViewController.h"
#import "AlertManager.h"
#import "Inventory.h"
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import "AppDelegate.h"
#import "DataPickerManager.h"

@interface OrderViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *partnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *preOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *warehouseLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountWordLabel;
@property (weak, nonatomic) IBOutlet UIButton *allDeliveryButton;

@property (weak, nonatomic) IBOutlet UILabel *orderDateLabel;

@property (weak, nonatomic) IBOutlet UITextField *orderNoInput;
@property (weak, nonatomic) IBOutlet UITextField *orderPreOrderInput;
@property (weak, nonatomic) IBOutlet UITextField *orderPartnerInput;
@property (weak, nonatomic) IBOutlet UITextField *orderDateInput;
@property (weak, nonatomic) IBOutlet UITextField *orderWarehouseInput;
@property (weak, nonatomic) IBOutlet UITextField *orderUserInput;
@property (weak, nonatomic) IBOutlet UITextField *orderExpectedDayInput;

@property (weak, nonatomic) IBOutlet UIDatePicker *datePickerView;
@property (weak, nonatomic) IBOutlet UIPickerView *dataPickerView;
@property (weak, nonatomic) IBOutlet UITableView *orderDetailTableView;
@property (weak, nonatomic) IBOutlet UILabel *orderExpectedReverseDayLabel;
@property (weak, nonatomic) IBOutlet UITextField *orderExpectedReverseDayInput;
@property OrderDetailCell *lastODCell;
//單頭UI排列比較好看
@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UITextField *emptyInput;
@property (weak, nonatomic) IBOutlet UIButton *deleteOrderButton;

@property NSMutableArray *orderDetailList;
@property NSMutableArray *firmList;
@property NSMutableArray *custList;
@property NSMutableArray *warehouseList;
@property NSString *orderNoBegin;
@property NSString *whichInput;
@property NSInteger selectedRowIndex;
@property OrderListViewController *olvc;
@property OrderListBViewController *olBvc;
@property (weak, nonatomic) IBOutlet UIButton *orderDetailButtonForAdd;
@property (weak, nonatomic) IBOutlet UIButton * orderDetailButtonForCopy;

@property NSString *originalPreOrderNo;
@property BOOL isOverQty;
@property BOOL isLeaveVC;
@property DataPickerManager *dpm;
@property (weak, nonatomic) IBOutlet UIView *headerView;
@property UITextField *orderDateField;

@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderNoBegin = [self.currentOM.orderNo substringToIndex:1];
    self.selectedRowIndex = -1;
    self.dpm = [DataPickerManager new];
    //單頭初值
    self.orderNoInput.text = self.currentOM.orderNo;
    self.orderPreOrderInput.text = self.currentOM.oderPreOrder;
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString;
    if (self.currentOM.orderDate != nil)
    {
        dateString = [formatter stringFromDate:self.currentOM.orderDate];
    }
    else
    {
        NSDate *today = [NSDate date];
        dateString = [formatter stringFromDate:today];
    }
    if (self.currentOM.orderUser != nil)
    {
        self.orderUserInput.text = self.currentOM.orderUser;
    }
    else
    {
        AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
        self.orderUserInput.text = appDLG.currentUserName;
    }
    self.orderDateInput.text = dateString;
    self.orderPartnerInput.text = self.currentOM.orderPartner;
    self.orderWarehouseInput.text = self.currentOM.orderWarehouse;
    
    //設定UI
    Partner *partnerForLabel = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerID" fiterBy:self.currentOM.orderPartner].firstObject;
    [self.datePickerView setHidden:YES];
    [self.dataPickerView setHidden:YES];
    self.orderPartnerInput.placeholder = @"必填";
    self.orderWarehouseInput.placeholder = @"必填";
    self.datePickerView.datePickerMode = UIDatePickerModeDate;
    self.totalAmountLabel.text = [self.currentOM.orderTotalAmount stringValue];
    //設了會當掉
    //self.orderDateInput.inputView = self.datePickerView;
    if ([self.whereFrom isEqualToString:@"aSegue"])
    {
        NSArray *naviArray = [self.navigationController viewControllers];
        NSInteger thisIndex = [naviArray indexOfObject:self];
        self.olvc = [naviArray objectAtIndex:thisIndex-1];
        [self.orderWarehouseInput setHidden:YES];
        [self.warehouseLabel setHidden:YES];
        [self.allDeliveryButton setHidden:YES];
        [self.orderExpectedReverseDayLabel setHidden:YES];
        [self.orderExpectedReverseDayInput setHidden:YES];
        //如果沒指定寬度的話, 就沒辦法變顏色
        self.emptyInput.layer.borderWidth = 1;
        self.emptyInput.layer.borderColor = [[UIColor whiteColor]CGColor];
        [self.preOrderLabel setHidden:YES];
        [self.orderPreOrderInput setHidden:YES];
    }
    else if ([self.whereFrom isEqualToString:@"bSegue"])
    {
        NSArray *naviArray = [self.navigationController viewControllers];
        NSInteger thisIndex = [naviArray indexOfObject:self];
        self.olvc = [naviArray objectAtIndex:thisIndex-1];
        self.olBvc = self.olvc.childViewControllers[0];
        [self.orderDetailButtonForAdd setHidden:YES];
        [self.orderDetailButtonForCopy setHidden:YES];
        [self.totalAmountLabel setHidden:YES];
        [self.totalAmountWordLabel setHidden:YES];
        [self.expectedDayLabel setHidden:YES];
        [self.orderExpectedDayInput setHidden:YES];
        [self.orderPartnerInput setEnabled:NO];
        if (self.currentOM.orderWarehouse != nil)
        {
            [self.orderWarehouseInput setEnabled:NO];
        }
#pragma mark Q.為何不能設
//        CGRect frame = self.orderExpectedReverseDayInput.frame;
//        frame.size.width = 130.0;
//        self.orderExpectedReverseDayInput.frame = frame;
    }
    if ([self.orderNoBegin isEqualToString:@"P"])
    {
        if (self.currentOM.orderPartner != nil)
        {
            self.partnerLabel.text = partnerForLabel.partnerName;
        }
        else
        {
            self.partnerLabel.text = @"廠商";
        }
        self.orderDateLabel.text = @"採購日期";
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            self.title = @"採購單";
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            [self.emptyLabel setHidden:YES];
            [self.emptyInput setHidden:YES];
            self.orderPreOrderInput.placeholder = @"請輸入採購單號";
            self.title = @"進貨單";
            self.orderExpectedReverseDayLabel.text = @"預付日期";
            [self.allDeliveryButton setTitle:@"全部收貨" forState:UIControlStateNormal];
        }
    }
    else if ([self.orderNoBegin isEqualToString:@"S"])
    {
        if (self.currentOM.orderPartner != nil)
        {
            self.partnerLabel.text = partnerForLabel.partnerName;
        }
        else
        {
            self.partnerLabel.text = @"客戶";
        }
        self.orderDateLabel.text = @"訂單日期";
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            self.title = @"訂單";
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            [self.emptyLabel setHidden:YES];
            [self.emptyInput setHidden:YES];
            self.orderPreOrderInput.placeholder = @"請輸入訂單號碼";
            self.orderExpectedReverseDayLabel.text = @"預收日期";
            self.title = @"銷貨單";
            [self.allDeliveryButton setTitle:@"全部出貨" forState:UIControlStateNormal];
        }
    }
    //代理區
    self.orderDetailTableView.delegate = self;
    self.orderDetailTableView.dataSource = self;
    
    self.dataPickerView.delegate = self;
    self.dataPickerView.dataSource = self;
    
    self.orderNoInput.delegate = self;
    self.orderDateInput.delegate = self;
    self.orderExpectedDayInput.delegate = self;
    self.orderExpectedReverseDayInput.delegate = self;
    self.orderPartnerInput.delegate = self;
    self.orderWarehouseInput.delegate = self;
    self.orderPreOrderInput.delegate = self;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(deleteAndGetOrderDetail) name:@"deleteAndGetOrderDetailYes" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(clearPreOrderNo) name:@"deleteAndGetOrderDetailNo" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
    
    //DataMode
    self.orderDetailList = [[NSMutableArray alloc]init];
    self.orderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentOM.orderNo];
    if (self.orderDetailList.count == 0)
    {
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.deleteOrderButton setTitle:@"放棄新增" forState:UIControlStateNormal];
    }
    else
    {
        [self.deleteOrderButton setTitle:@"刪除此單" forState:UIControlStateNormal];
    }
    self.firmList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"F"];
    self.custList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"C"];
    self.warehouseList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"倉庫"];
}

-(void)viewWillDisappear:(BOOL)animated
{
    [super viewWillDisappear:nil];
    [DataBaseManager rollbackFromCoreData];
    self.isLeaveVC = YES;
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

-(void)deleteAndGetOrderDetail
{
    //撈單身
    NSMutableArray *orderAOrderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNoAndNotYetQty" fiterByArray:@[self.orderPreOrderInput.text,@(0)]];
    
    if (orderAOrderDetailList.count != 0)
    {
        //撈單頭
        NSArray *omArray = [DataBaseManager fiterFromCoreData:@"OrderMasterEntity" sortBy:@"orderNo" fiterFrom:@"orderNo" fiterBy:self.orderPreOrderInput.text];
        //如果有撈到單頭
        if (omArray.count != 0)
        {
            //assign交易對象
            OrderMaster *om = omArray[0];
            self.orderPartnerInput.text = om.orderPartner;
            Partner *partnerForLabel = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerID" fiterBy:self.currentOM.orderPartner].firstObject;
            self.partnerLabel.text = partnerForLabel.partnerName;
        }
        //清空單身
        if (self.orderDetailList.count !=0)
        {
            for (OrderDetail *od in self.orderDetailList)
            {
                [DataBaseManager deleteDataAndObject:od array:self.orderDetailList];
            }
        }
        for (OrderDetail *od in orderAOrderDetailList)
        {
            OrderDetail *odB = [self birthOrderDetail:od type:@"inherit"];
            //項次重排
            odB.orderSeq = @([orderAOrderDetailList indexOfObject:od]+1);
            [self.orderDetailList addObject:odB];
        }
        [self.orderDetailTableView reloadData];
    }
    else
    {
        if ([self.whereFrom isEqualToString:@"pSegue"])
        {
            [AlertManager alert:@"此單號查無未進貨單身,請確認" controller:self];
        }
        else if ([self.whereFrom isEqualToString:@"sSegue"])
        {
            [AlertManager alert:@"此單號查無未銷貨單身,請確認" controller:self];
        }
    }

}

-(void)clearPreOrderNo
{
    self.orderPreOrderInput.text = @"";
}

//觸碰self.view縮鍵盤
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    if (![self.orderNoInput isExclusiveTouch])
    {
        [self.orderNoInput resignFirstResponder];
    }
}

//按Return縮鍵盤
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}

//開始編輯
//只要有這個Method, setEnable:NO跟shouldChangeCharactersInRange return NO; 都無效
//shouldChangeCharactersInRange還是有用啊 當初怎會這麼說
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.orderDateInput || textField == self.orderExpectedDayInput || textField == self.orderExpectedReverseDayInput)
    {
        self.orderDateField = textField;
        [self.datePickerView setHidden:NO];
#pragma mark Q.不知為何storyBoard設背景沒用
        self.datePickerView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];;
    }
    else if (textField == self.orderPartnerInput)
    {
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            self.whichInput = @"夥伴";
            [self.dataPickerView setHidden:NO];
            [self.dataPickerView reloadAllComponents];
        }
    }
    else if (textField == self.orderWarehouseInput)
    {
        self.whichInput = @"倉庫";
        [self.dataPickerView setHidden:NO];
        [self.dataPickerView reloadAllComponents];
    }
    else if (textField == self.orderPreOrderInput)
    {
        self.originalPreOrderNo = self.orderPreOrderInput.text;
    }
}

//結束編輯
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.orderDateInput || textField == self.orderExpectedDayInput || textField == self.orderExpectedReverseDayInput)
    {
        [self.datePickerView setHidden:YES];
    }
    //帶單身
    if (textField == self.orderPreOrderInput)
    {
        if (![self.originalPreOrderNo isEqualToString:self.orderPreOrderInput.text])
        {
            if ([self.whereFrom isEqualToString:@"aSegue"] && textField.text.length != 0)
            {
                [self checkPreOrderNo:@"SA"];
            }
            else if ([self.whereFrom isEqualToString:@"bSegue"] && textField.text.length != 0)
            {
                if ([self.orderNoBegin isEqualToString:@"P"])
                {
                    [self checkPreOrderNo:@"PA"];
                }
                else if ([self.orderNoBegin isEqualToString:@"S"])
                {
                    [self checkPreOrderNo:@"SA"];
                }
            }
        }
    }
    if (textField == self.orderPartnerInput || textField == self.orderWarehouseInput)
    {
        [self.dataPickerView setHidden:YES];
    }
}

-(void)checkPreOrderNo:(NSString*)type
{
    if ([[self.orderPreOrderInput.text substringToIndex:2] isEqualToString:type])
    {
        //單身有東西才確認
        if (self.orderDetailList.count !=0)
        {
            [AlertManager alertYesAndNo:@"請確認是否刪除單身所有資料\n並由此單號帶出單身" yes:@"是" no:@"否" controller:self postNotificationName:@"deleteAndGetOrderDetail"];
        }
        else
        {
            [self deleteAndGetOrderDetail];
        }
    }
    else
    {
        [AlertManager alert:@"單號類型錯誤" controller:self];
    }
}

//不可變更
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.orderNoInput || textField==self.orderPartnerInput || textField==self.orderWarehouseInput)
    {
        return NO;
    }
    return YES;
}

//選日期
- (IBAction)selectDate:(UIDatePicker*)sender
{
    NSDateFormatter *formatter = [[NSDateFormatter alloc]init];
    [formatter setDateFormat:@"yyyy/MM/dd"];
    NSString *dateString = [formatter stringFromDate:sender.date];
    self.orderDateField.text = dateString;
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self.whichInput isEqualToString:@"夥伴"])
    {
        if ([self.orderNoBegin isEqualToString:@"P"])
        {
            return self.firmList.count;
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            return self.custList.count;
        }
    }
    else if ([self.whichInput isEqualToString:@"倉庫"])
    {
        return self.warehouseList.count;
    }
    return 0;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    if ([self.whichInput isEqualToString:@"夥伴"])
    {
        Partner *p;
        if ([self.orderNoBegin isEqualToString:@"P"])
        {
            p = [self.firmList objectAtIndex:row];
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            p = [self.custList objectAtIndex:row];
        }
        NSString *pIDAndpName = [p.partnerID stringByAppendingFormat:@"_%@",p.partnerName];
        return pIDAndpName;
    }
    else if ([self.whichInput isEqualToString:@"倉庫"])
    {
        BasicData *bd;
        bd = [self.warehouseList objectAtIndex:row];
        return bd.basicDataName;
    }
    return nil;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    if ([self.whichInput isEqualToString:@"夥伴"])
    {
        Partner *p;
        if ([self.orderNoBegin isEqualToString:@"P"])
        {
            if (self.firmList.count != 0)
            {
                p = [self.firmList objectAtIndex:row];
                self.orderPartnerInput.text = p.partnerID;
                Partner *partnerForLabel = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerID" fiterBy:p.partnerID].firstObject;
                self.partnerLabel.text = partnerForLabel.partnerName;
            }
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            if (self.custList.count != 0)
            {
                p = [self.custList objectAtIndex:row];
                self.orderPartnerInput.text = p.partnerID;
                Partner *partnerForLabel = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerID" fiterBy:p.partnerID].firstObject;
                self.partnerLabel.text = partnerForLabel.partnerName;
            }
        }
    }
    else if ([self.whichInput isEqualToString:@"倉庫"])
    {
        BasicData *bd;
        bd = [self.warehouseList objectAtIndex:row];
        self.orderWarehouseInput.text = bd.basicDataName;
    }
    
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.orderDetailList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //產生cell
    OrderDetailCell *odCell = [tableView dequeueReusableCellWithIdentifier:@"orderDetailCell"];
    //把殘留的信息清掉
    odCell.odItemNameLabel.text = @"";
    odCell.odItemUnitLabel.text = @"";
    odCell.odQty.text = @"";
    odCell.odThisQty.text = @"";
    odCell.odPrice.text = @"";
    odCell.odResultLabel.text = @"";
    [odCell.odItemNo setEnabled:YES];
    if ([self.whereFrom isEqualToString:@"aSegue"])
    {
        [odCell.odThisQty setHidden:YES];
    }
    else if ([self.whereFrom isEqualToString:@"bSegue"])
    {
        [odCell.odItemNo setEnabled:NO];
        [odCell.odQty setEnabled:NO];
        [odCell.odPrice setHidden:YES];
    }
    //監聽欄位
    odCell.odItemNo.delegate = self;
    odCell.odQty.delegate = self;
    odCell.odPrice.delegate = self;
    odCell.odThisQty.delegate = self;
    [odCell.odItemNo addTarget:self action:@selector(itemEditingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [odCell.odQty addTarget:self action:@selector(anyoneEditingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [odCell.odPrice addTarget:self action:@selector(anyoneEditingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [odCell.odThisQty addTarget:self action:@selector(anyoneEditingBegin:) forControlEvents:UIControlEventEditingDidBegin];
    [odCell.odItemNo addTarget:self action:@selector(odItemNoEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [odCell.odQty addTarget:self action:@selector(odQtyOrPriceEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [odCell.odPrice addTarget:self action:@selector(odQtyOrPriceEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [odCell.odThisQty addTarget:self action:@selector(odThisQtyEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    //產生物件
    OrderDetail *od = [self.orderDetailList objectAtIndex:indexPath.row];
    if (od.isInventory != nil)
    {
        [odCell.odItemNo setEnabled:NO];
    }
    //根據序號區分tag
    odCell.odItemNo.tag = [od.orderSeq integerValue];
    odCell.odQty.tag = [od.orderSeq integerValue];
    odCell.odPrice.tag = [od.orderSeq integerValue];
    odCell.odThisQty.tag = [od.orderSeq integerValue];
    //輸入提示
    odCell.odItemNo.placeholder = @"品號";
    odCell.odQty.placeholder = @"量";
    odCell.odPrice.placeholder = @"價";
    //單身初值
    odCell.odSeq.text = [od.orderSeq stringValue];
    odCell.odItemNo.text = od.orderItemNo;
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:od.orderItemNo];
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        odCell.odItemNameLabel.text = item.itemName;
        odCell.odItemUnitLabel.text = item.itemUnit;
    }
    if (![[od.orderQty stringValue] isEqualToString:@"0"])
    {
        odCell.odQty.text = [od.orderQty stringValue];
    }
    if (![[od.orderPrice stringValue] isEqualToString:@"0"])
    {
        odCell.odPrice.text = [od.orderPrice stringValue];
    }
    if ([self.whereFrom isEqualToString:@"aSegue"])
    {
        if (![[od.orderAmount stringValue] isEqualToString:@"0"])
        {
            odCell.odResultLabel.text = [od.orderAmount stringValue];
        }
    }
    else if ([self.whereFrom isEqualToString:@"bSegue"])
    {
        odCell.odResultLabel.text = [@([od.orderQty floatValue]-[od.orderThisQty floatValue]) stringValue];
    }
    odCell.odThisQty.text = [od.orderThisQty stringValue];
    return odCell;
}

-(IBAction)itemEditingBegin:(UITextField*)sender
{
    [self.dpm showDataPicker:self dataField:sender dataSource:@"ItemEntity" sortBy:@"itemNo" fiterFrom:nil fiterBy:nil headerView:self.headerView];
    [self anyoneEditingBegin:sender];
}

//紀錄最後欄位的單身
-(IBAction)anyoneEditingBegin:(UITextField*)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    self.lastODCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
}

//輸完料號
-(IBAction)odItemNoEditingEnd:(UITextField*)sender
{
    [self.dpm.pv removeFromSuperview];
    //產生cell
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
    OrderDetail *od = [self.orderDetailList objectAtIndex:sender.tag-1];
    od.orderItemNo = odCell.odItemNo.text;
    //讀DB
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:odCell.odItemNo.text];
    //如果有建料號基本資料
    //就帶出資料
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        odCell.odItemNameLabel.text = item.itemName;
        odCell.odItemUnitLabel.text = item.itemUnit;
        //如果基本資料的價格不等於0 且 目前沒價格
        if (![[item.itemPrice stringValue]isEqualToString:@"0"] && [odCell.odPrice.text isEqualToString:@""])
        {
            odCell.odPrice.text = [item.itemPrice stringValue];
        }
    }
}

//輸完量價
-(IBAction)odQtyOrPriceEditingEnd:(UITextField*)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
//    OrderDetail *od = [self.orderDetailList objectAtIndex:sender.tag-1];
//    od.orderQty = @([odCell.odQty.text floatValue]);
//    od.orderPrice = @([odCell.odPrice.text floatValue]);
    if ([odCell.odQty.text floatValue] == 0 && odCell != nil && self.isLeaveVC != YES)
    {
        [AlertManager alert:@"數量不可為零" controller:self];
    }
    else
    {
        NSNumber *amountN = @([odCell.odQty.text floatValue]*[odCell.odPrice.text floatValue]);
        if (![[amountN stringValue] isEqualToString:@"0"])
        {
            odCell.odResultLabel.text = [amountN stringValue];
        }
        //總計
        [self sumAmount];
    }
}

-(CGFloat)sumAmount
{
    CGFloat totalAmount = 0.0;
    for (NSUInteger index=0; index<self.orderDetailList.count; index++)
    {
        OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:index inSection:0]];
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            totalAmount += ([odCell.odQty.text floatValue]*[odCell.odPrice.text floatValue]);
            self.totalAmountLabel.text = [NSString stringWithFormat:@"%.2f",totalAmount];
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            OrderDetail *od = self.orderDetailList[index];
            totalAmount += [od.orderAmount floatValue];
        }
    }
    return totalAmount;
}

//輸完本次異動
-(IBAction)odThisQtyEditingEnd:(UITextField*)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
//    OrderDetail *od = [self.orderDetailList objectAtIndex:sender.tag-1];
//    od.orderThisQty = @([odCell.odThisQty.text floatValue]);
    if ([odCell.odThisQty.text floatValue] == 0 && self.isLeaveVC !=YES)
    {
        [AlertManager alert:@"異動量不可為零" controller:self];
    }
    else
    {
        CGFloat newNotYetQty = [odCell.odQty.text floatValue] - [odCell.odThisQty.text floatValue];
        if (newNotYetQty < 0 && self.isLeaveVC !=YES)
        {
            self.isOverQty = YES;
            [self overQtyAlert];
        }
        else
        {
            self.isOverQty = NO;
            //差額
            odCell.odResultLabel.text = [@(newNotYetQty) stringValue];
        }
    }
}

-(void)overQtyAlert
{
    if ([self.orderNoBegin isEqualToString:@"P"])
    {
        [AlertManager alert:@"本次收貨量不可大於累積未收量" controller:self];
    }
    else if ([self.orderNoBegin isEqualToString:@"S"])
    {
        [AlertManager alert:@"本次出貨量不可大於累積未收量" controller:self];
    }
}

- (IBAction)allDelivery:(id)sender
{
    for (OrderDetail *od in self.orderDetailList)
    {
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.orderDetailList indexOfObject:od] inSection:0];
        OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
        odCell.odThisQty.text = [od.orderQty stringValue];
        odCell.odResultLabel.text = [@(0) stringValue];
    }
}

//新增單身
- (IBAction)addOrderDetail:(id)sender
{
    [self.datePickerView setHidden:YES];
    [self.dataPickerView setHidden:YES];
    //產生物件DB寫入殼
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    OrderDetail *od = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
    //指定單號
    od.orderNo = self.currentOM.orderNo;
    [self newOrderDetail:od];
}

//選擇單身
-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (indexPath.row == self.selectedRowIndex)
    {
        [tableView deselectRowAtIndexPath:indexPath animated:NO];
        self.selectedRowIndex = -1;
    }
    else
    {
        self.selectedRowIndex = indexPath.row;
    }
}

//複製單身
- (IBAction)copyOoderDetail:(id)sender
{
    //有東西才能複製
    if (self.selectedRowIndex == -1)
    {
        [AlertManager alert:@"請先選擇欲複製的單身" controller:self];
    }
    if (self.selectedRowIndex != -1)
    {
        //取得複製對象
        OrderDetail *selectedOD = [self.orderDetailList objectAtIndex:self.selectedRowIndex];
        OrderDetail *copyOD = [self birthOrderDetail:selectedOD type:@"copy"];
        [self newOrderDetail:copyOD];
    }
}

-(OrderDetail*)birthOrderDetail:(OrderDetail*)fatherOrderDetail type:(NSString*)type
{
    //生新物件
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    OrderDetail *childOD = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
    //賦值
    
    childOD.orderItemNo = fatherOrderDetail.orderItemNo;
    childOD.orderPrice = fatherOrderDetail.orderPrice;
    if ([type isEqualToString:@"copy"])
    {
        childOD.orderNo = fatherOrderDetail.orderNo;
        childOD.orderSeq = fatherOrderDetail.orderSeq;
        childOD.orderNotYetAmount = @(0);
        childOD.orderAmount = fatherOrderDetail.orderAmount;
        childOD.orderQty = fatherOrderDetail.orderQty;
        childOD.orderNoOld = fatherOrderDetail.orderNoOld;
        childOD.orderSeqOld = fatherOrderDetail.orderSeqOld;
    }
    else if ([type isEqualToString:@"inherit"])
    {
        //紀錄原A單的單號項次
        childOD.orderNoOld = fatherOrderDetail.orderNo;
        childOD.orderSeqOld = fatherOrderDetail.orderSeq;
        //改單身的爸爸
        childOD.orderNo = self.currentOM.orderNo;
        childOD.orderNotYetAmount = @(0);
        childOD.orderAmount = @(0);
        childOD.orderQty = fatherOrderDetail.orderNotYetQty;
    }
    
    return childOD;
}

//新增單身資料
-(void)newOrderDetail:(OrderDetail*)od
{
    //處理序號
    NSInteger countInt = [self.currentOM.orderCount integerValue];
    countInt += 1;
    NSNumber *newCount = @(countInt);
    self.currentOM.orderCount = newCount;
    od.orderSeq = newCount;
    //加到陣列並存檔
    [self.orderDetailList insertObject:od atIndex:self.orderDetailList.count];
    //加到TV
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.orderDetailList.count-1 inSection:0];
    [self.orderDetailTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.orderDetailTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

- (IBAction)saveOrder:(id)sender
{
    NSString *findPostOrderString = [OrderDetail isPostOrder:self.orderDetailList];
    //不管如何先確認廠商必填
    if (self.orderPartnerInput.text.length == 0)
    {
        if ([self.orderNoBegin isEqualToString:@"P"])
        {
            [AlertManager alert:@"廠商未填" controller:self];
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            [AlertManager alert:@"客戶未填" controller:self];
        }
    }
    else if (self.orderDetailList.count == 0)
    {
        [AlertManager alert:@"沒有單身不可儲存" controller:self];
    }
    else if (findPostOrderString.length != 0)
    {
        NSString *finalString = [NSString stringWithFormat:@"%@，不可修改",findPostOrderString];
        [AlertManager alert:finalString controller:self];
    }
    else
    {
        //檢查單身是否合法
        BOOL invalidOrderDteail = NO;
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            //處理最後沒離開的欄位
            if (self.lastODCell != nil)
            {
                [self odItemNoEditingEnd:self.lastODCell.odItemNo];
                [self odQtyOrPriceEditingEnd:self.lastODCell.odQty];
                [self odQtyOrPriceEditingEnd:self.lastODCell.odPrice];
            }
            for (NSUInteger i=0; i<self.orderDetailList.count; i++)
            {
                OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if (odCell.odItemNo.text.length==0 || odCell.odQty.text.length==0 || odCell.odPrice.text.length==0)
                {
                    invalidOrderDteail = YES;
                    break;
                }
            }
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            if (self.lastODCell != nil)
            {
                [self odThisQtyEditingEnd:self.lastODCell.odThisQty];
            }
            for (NSUInteger i=0; i<self.orderDetailList.count; i++)
            {
                OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:i inSection:0]];
                if (odCell.odThisQty.text.length==0)
                {
                    invalidOrderDteail = YES;
                    break;
                }
            }
        }
        
        if (invalidOrderDteail == YES)
        {
            [AlertManager alert:@"有單身資料不齊全\n請檢查" controller:self];
        }
        else if (self.isOverQty == YES)
        {
            [self overQtyAlert];
        }
        else
        {
            if ([self.whereFrom isEqualToString:@"aSegue"])
            {
                [self saveToOrderMasterObject];
                [self saveToOrderDetailAObject];
                [DataBaseManager updateToCoreData];
                [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
            }
            //若是b單
            else if ([self.whereFrom isEqualToString:@"bSegue"])
            {
                //還要填倉庫
                if (self.orderWarehouseInput.text.length==0)
                {
                    [AlertManager alert:@"倉庫未填" controller:self];
                }
                else
                {
                    //才可存單頭跟計算庫存
                    [self saveToOrderMasterObject];
                    [self saveToOrderDetailBObject];
                    [Inventory calculateInventory:self.orderDetailList warehouse:self.currentOM.orderWarehouse orderNoBegin:self.currentOM.orderType];;
                    [DataBaseManager updateToCoreData];
                    [AlertManager alertWithoutButton:@"資料已儲存" controller:self time:0.5 action:@"popVC"];
                }
            }
        }
    }
}

-(void)saveToOrderMasterObject
{
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd"];
    NSString *orderDateString = self.orderDateInput.text;
    self.currentOM.orderDate = [df dateFromString:orderDateString];
    NSString *orderExpectedString = self.orderExpectedDayInput.text;
    self.currentOM.orderExpectedDay = [df dateFromString:orderExpectedString];
    
    self.currentOM.orderNo = self.orderNoInput.text;
    self.currentOM.orderUser = self.orderUserInput.text;
    self.currentOM.orderPartner = self.orderPartnerInput.text;
    self.currentOM.orderWarehouse = self.orderWarehouseInput.text;
    self.currentOM.oderPreOrder = self.orderPreOrderInput.text;
    self.currentOM.orderTotalAmount = @([self sumAmount]);
}

-(void)saveToOrderDetailAObject
{
    for (OrderDetail *od in self.orderDetailList)
    {
        OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.orderDetailList indexOfObject:od] inSection:0]];
        od.orderItemNo = odCell.odItemNo.text;
        od.orderQty = @([odCell.odQty.text floatValue]);;
        od.orderNotYetQty = @([odCell.odQty.text floatValue]);;
        od.orderPrice = @([odCell.odPrice.text floatValue]);
        od.orderAmount = @([odCell.odQty.text floatValue]*[odCell.odPrice.text floatValue]);
        od.orderNotYetAmount = @([odCell.odQty.text floatValue]*[odCell.odPrice.text floatValue]);
    }
}

-(void)saveToOrderDetailBObject
{
    for (OrderDetail *od in self.orderDetailList)
    {
        OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:[self.orderDetailList indexOfObject:od] inSection:0]];
        od.orderThisQty = @([odCell.odThisQty.text floatValue]);
        od.orderAmount = @([odCell.odThisQty.text floatValue]*[od.orderPrice floatValue]);
        od.orderNotYetAmount = od.orderAmount;
        
        //回寫前單未沖量
        NSArray *queryArray = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderNo" fiterFrom:@"orderNoAndSeq" fiterByArray:@[od.orderNoOld,od.orderSeqOld]];
        OrderDetail *updateOD;
        if (queryArray.count !=0)
        {
            updateOD = queryArray[0];
            updateOD.orderNotYetQty = @([odCell.odQty.text floatValue] - [odCell.odThisQty.text floatValue]);
        }
    }
}

- (IBAction)saveAndCreateOrder:(id)sender
{
    
}

- (IBAction)copyOrder:(id)sender
{
    
}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        NSString *findPostOrderString = [OrderDetail isPostOrder:@[[self.orderDetailList objectAtIndex:indexPath.row]]];
        if (findPostOrderString.length != 0)
        {
            NSString *finalString = [NSString stringWithFormat:@"%@，不可刪除",findPostOrderString];
            [AlertManager alert:finalString controller:self];
        }
        else
        {
            //生成物件
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            OrderDetail *od = [self.orderDetailList objectAtIndex:indexPath.row];
            if ([self.whereFrom isEqualToString:@"bSegue"])
            {
                //逆庫存
                [Inventory rollbackInventory:od warehouse:self.currentOM.orderWarehouse orderNoBegin:self.currentOM.orderType];
                //逆餘量
                [OrderDetail rollbackNotYet:@[od]];
            }
            //刪DB
            [helper.managedObjectContext deleteObject:od];
            //刪陣列
            [self.orderDetailList removeObjectAtIndex:indexPath.row];
            //刪cell
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //寫DB
            //如果還有單身的話,刪了之後後面開始的tag都要重排
            if (self.orderDetailList.count != 0)
            {
                for (NSInteger i=indexPath.row; i <= self.orderDetailList.count-1; i++)
                {
                    NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                    OrderDetailCell *odCell = [self.orderDetailTableView cellForRowAtIndexPath:ip];
                    odCell.odItemNo.tag -= 1 ;
                    odCell.odQty.tag -= 1;
                    odCell.odPrice.tag -= 1 ;
                    OrderDetail *od = [self.orderDetailList objectAtIndex:i];
                    int newSeq = [od.orderSeq intValue];
                    newSeq -= 1;
                    od.orderSeq = @(newSeq);
                }
            }
            self.currentOM.orderCount = @(self.orderDetailList.count);
            [self.orderDetailTableView reloadData];
        }
    }
}

- (IBAction)deleteOrder:(id)sender
{
    NSString *findPostOrderString = [OrderDetail isPostOrder:self.orderDetailList];
    if(findPostOrderString.length != 0)
    {
        NSString *finalString = [NSString stringWithFormat:@"%@，不可刪除",findPostOrderString];
        [AlertManager alert:finalString controller:self];
    }
    else
    {
        //先存單號
        NSString *orderNo = self.currentOM.orderNo;
        
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.orderListInDteail indexOfObject:self.currentOM] inSection:0];
        //單身也要刪
        NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:orderNo];
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        for (OrderDetail *deadOD in deadList)
        {
            [OrderDetail rollbackNotYet:@[deadOD]];
            [Inventory rollbackInventory:deadOD warehouse:self.currentOM.orderWarehouse orderNoBegin:self.currentOM.orderType];
            [helper.managedObjectContext deleteObject:deadOD];
        }
        //寫DB
        [DataBaseManager deleteDataAndObject:self.currentOM array:self.orderListInDteail];
        [DataBaseManager updateToCoreData];
        //刪前一頁TV
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            [self.olvc.orderListTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            [self.olBvc.orderListBTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)backRootView:(id)sender
{
    self.isLeaveVC = YES;
    if (self.orderDetailList.count == 0)
    {
        [DataBaseManager deleteDataAndObject:self.currentOM array:self.orderListInDteail];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
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
