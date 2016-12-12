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

@interface OrderViewController () <UITableViewDelegate,UITableViewDataSource,UITextFieldDelegate,UIPickerViewDelegate,UIPickerViewDataSource>
@property (weak, nonatomic) IBOutlet UILabel *partnerLabel;
@property (weak, nonatomic) IBOutlet UILabel *preOrderLabel;
@property (weak, nonatomic) IBOutlet UILabel *expectedDayLabel;
@property (weak, nonatomic) IBOutlet UILabel *warehouseLabel;
@property (weak, nonatomic) IBOutlet UILabel *totalAmountLabel;
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
@property (weak, nonatomic) IBOutlet UITableView *orderDteailTableView;

@property (weak, nonatomic) IBOutlet UILabel *emptyLabel;
@property (weak, nonatomic) IBOutlet UITextField *emptyInput;

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

@end

@implementation OrderViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.orderNoBegin = [self.currentOM.orderNo substringToIndex:1];
    self.selectedRowIndex = -1;
    
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
        self.orderUserInput.text = [FBSDKProfile currentProfile].name;
    }
    self.orderDateInput.text = dateString;
    self.orderPartnerInput.text = self.currentOM.orderPartner;
    self.orderWarehouseInput.text = self.currentOM.orderWarehouse;
    
    //設定UI
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
    }
    else if ([self.whereFrom isEqualToString:@"bSegue"])
    {
        NSArray *naviArray = [self.navigationController viewControllers];
        NSInteger thisIndex = [naviArray indexOfObject:self];
        self.olvc = [naviArray objectAtIndex:thisIndex-1];
        self.olBvc = self.olvc.childViewControllers[0];
        [self.orderDetailButtonForAdd setHidden:YES];
        [self.orderDetailButtonForCopy setHidden:YES];
        [self.expectedDayLabel setHidden:YES];
        [self.orderExpectedDayInput setHidden:YES];
    }
    if ([self.orderNoBegin isEqualToString:@"P"])
    {
        self.partnerLabel.text = @"廠商";
        self.orderDateLabel.text = @"採購日期";
        [self.emptyLabel setHidden:YES];
        [self.emptyInput setHidden:YES];
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            self.orderPreOrderInput.placeholder = @"可輸入訂單號碼";
            self.title = @"採購單";
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            self.orderPreOrderInput.placeholder = @"請輸入採購單號";
            self.title = @"進貨單";
        }
    }
    else if ([self.orderNoBegin isEqualToString:@"S"])
    {
        self.partnerLabel.text = @"客戶";
        self.orderDateLabel.text = @"訂單日期";
        if ([self.whereFrom isEqualToString:@"aSegue"])
        {
            self.emptyInput.layer.borderWidth = 1;
            self.emptyInput.layer.borderColor = [[UIColor whiteColor]CGColor];
            [self.preOrderLabel setHidden:YES];
            [self.orderPreOrderInput setHidden:YES];
            self.title = @"訂單";
        }
        else if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            [self.emptyLabel setHidden:YES];
            [self.emptyInput setHidden:YES];
            self.orderPreOrderInput.placeholder = @"請輸入訂單號碼";
            self.title = @"銷貨單";
        }
    }
    
    //代理區
    self.orderDteailTableView.delegate = self;
    self.orderDteailTableView.dataSource = self;
    
    self.dataPickerView.delegate = self;
    self.dataPickerView.dataSource = self;
    
    self.orderNoInput.delegate = self;
    self.orderDateInput.delegate = self;
    self.orderPartnerInput.delegate = self;
    self.orderWarehouseInput.delegate = self;
    
    //DataMode
    self.orderDetailList = [[NSMutableArray alloc]init];
    self.orderDetailList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:self.currentOM.orderNo];
    self.firmList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"F"];
    self.custList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"C"];
    self.warehouseList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"倉庫"];
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
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField == self.orderDateInput)
    {
        [self.datePickerView setHidden:NO];
    }
    if (textField == self.orderPartnerInput)
    {
        self.whichInput = @"夥伴";
        [self.dataPickerView setHidden:NO];
        [self.dataPickerView reloadAllComponents];
    }
    else if (textField == self.orderWarehouseInput)
    {
        self.whichInput = @"倉庫";
        [self.dataPickerView setHidden:NO];
        [self.dataPickerView reloadAllComponents];
    }
}

//結束編輯
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.orderDateInput)
    {
        [self.datePickerView setHidden:YES];
    }
    if (textField == self.orderPartnerInput)
    {
        [self.dataPickerView setHidden:YES];
    }
    else if (textField == self.orderWarehouseInput)
    {
        [self.dataPickerView setHidden:YES];
    }
}

//不可變更單號
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField == self.orderNoInput)
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
    self.orderDateInput.text = dateString;
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
            }
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            if (self.custList.count != 0)
            {
                p = [self.custList objectAtIndex:row];
                self.orderPartnerInput.text = p.partnerID;
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
    odCell.odItemName.text = @"";
    odCell.odItemUnit.text = @"";
    odCell.odQty.text = @"";
    odCell.odPrice.text = @"";
    odCell.odAmount.text = @"";
    
    //監聽欄位
    [odCell.odItemNo addTarget:self action:@selector(odItemNoEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [odCell.odQty addTarget:self action:@selector(odQtyOrPriceEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    [odCell.odPrice addTarget:self action:@selector(odQtyOrPriceEditingEnd:) forControlEvents:UIControlEventEditingDidEnd];
    //產生物件
    OrderDetail *od = [self.orderDetailList objectAtIndex:indexPath.row];
    //根據序號區分tag
    odCell.odItemNo.tag = [od.orderSeq integerValue];
    odCell.odQty.tag = [od.orderSeq integerValue];
    odCell.odPrice.tag = [od.orderSeq integerValue];
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
        odCell.odItemName.text = item.itemName;
        odCell.odItemUnit.text = item.itemUnit;
    }
    if (![[od.orderQty stringValue] isEqualToString:@"0"])
    {
        odCell.odQty.text = [od.orderQty stringValue];
    }
    if (![[od.orderPrice stringValue] isEqualToString:@"0"])
    {
        odCell.odPrice.text = [od.orderPrice stringValue];
    }
    if (![[od.orderAmount stringValue] isEqualToString:@"0"])
    {
        odCell.odAmount.text = [od.orderAmount stringValue];
    }
    return odCell;
}

//輸完料號
-(IBAction)odItemNoEditingEnd:(UITextField*)sender
{
    //產生cell
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    OrderDetailCell *odCell = [self.orderDteailTableView cellForRowAtIndexPath:ip];
    
    //NSLog(@"%ld號呼叫",sender.tag);
    //產生資料
    OrderDetail *od = [self.orderDetailList objectAtIndex:sender.tag-1];
    
    //把料號寫回資料
    od.orderItemNo = odCell.odItemNo.text;
    
    //讀DB
    NSMutableArray *itemList = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:od.orderItemNo];
    
    //如果有建料號基本資料
    //就帶出資料
    if (itemList.count != 0)
    {
        Item *item = [itemList objectAtIndex:0];
        odCell.odItemName.text = item.itemName;
        odCell.odItemUnit.text = item.itemUnit;
        if (![[item.itemPrice stringValue]isEqualToString:@"0"])
        {
            odCell.odPrice.text = [item.itemPrice stringValue];
            od.orderPrice = item.itemPrice;
        }
    }
    [DataBaseManager updateToCoreData];
}

//輸完量價
-(IBAction)odQtyOrPriceEditingEnd:(UITextField*)sender
{
    //取得cell的量價數值並相乘
    NSIndexPath *ip = [NSIndexPath indexPathForRow:sender.tag-1 inSection:0];
    OrderDetailCell *odc = [self.orderDteailTableView cellForRowAtIndexPath:ip];
    NSNumber *qtyN = @([odc.odQty.text floatValue]);
    NSNumber *priceN = @([odc.odPrice.text floatValue]);
    NSNumber *amountN = @([odc.odQty.text floatValue]*[odc.odPrice.text floatValue]);
    //取得物件
    OrderDetail *od = [self.orderDetailList objectAtIndex:sender.tag-1];
    //存回物件並相乘
    od.orderQty = qtyN;
    od.orderPrice = priceN;
    od.orderAmount = amountN;
    od.orderNotYetAmount = amountN;
    [DataBaseManager updateToCoreData];
    //放到cell
    if (![[od.orderAmount stringValue] isEqualToString:@"0"])
    {
        odc.odAmount.text = [amountN stringValue];
    }
    //總計
    NSNumber *totalAmount = [self.orderDetailList valueForKeyPath:@"@sum.orderAmount"];
    self.currentOM.orderTotalAmount = totalAmount;
    self.totalAmountLabel.text = [totalAmount stringValue];
}

//新增單身
- (IBAction)addOrderDetail:(id)sender
{
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
        OrderDetail *selectedOD = [self.orderDetailList objectAtIndex:self.selectedRowIndex];
        //會崩潰
//        OrderDetail *copyOD = [selectedOD mutableCopy];
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        OrderDetail *copyOD = [NSEntityDescription insertNewObjectForEntityForName:@"OrderDetailEntity" inManagedObjectContext:helper.managedObjectContext];
        copyOD.orderItemNo = selectedOD.orderItemNo;
        copyOD.orderAmount = selectedOD.orderAmount;
        copyOD.orderNo = selectedOD.orderNo;
        copyOD.orderPrice = selectedOD.orderPrice;
        copyOD.orderQty = selectedOD.orderQty;
        copyOD.orderSeq = selectedOD.orderSeq;
        [self newOrderDetail:copyOD];
    }
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
    [DataBaseManager updateToCoreData];
    //加到TV
    NSIndexPath *ip = [NSIndexPath indexPathForRow:self.orderDetailList.count-1 inSection:0];
    [self.orderDteailTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    [self.orderDteailTableView scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionTop animated:YES];
}

-(void)saveToOrderMasterObject
{
    self.currentOM.orderNo = self.orderNoInput.text;
    NSString *dateString = self.orderDateInput.text;
    NSDateFormatter *df = [NSDateFormatter new];
    [df setDateFormat:@"yyyy/MM/dd"];
    self.currentOM.orderDate = [df dateFromString:dateString];
    self.currentOM.orderUser = self.orderUserInput.text;
    self.currentOM.orderPartner = self.orderPartnerInput.text;
    self.currentOM.orderWarehouse = self.orderWarehouseInput.text;
    [DataBaseManager updateToCoreData];
}

//計算庫存
-(void)calculateInventory
{
    for (OrderDetail *od in self.orderDetailList)
    {
        if ([od.isInventory boolValue] != YES && [od.orderQty integerValue] != 0)
        {
            Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:self.currentOM.orderWarehouse];
            
            if (getInventory != nil)
            {
                if ([self.orderNoBegin isEqualToString:@"P"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
                    [DataBaseManager updateToCoreData];
                }
                else if ([self.orderNoBegin isEqualToString:@"S"])
                {
                    getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
                    //這邊還需要判斷庫存不足
                    [DataBaseManager updateToCoreData];
                }
            }
            else
            {
                CoreDataHelper *helper = [CoreDataHelper sharedInstance];
                Inventory *newInventory = [NSEntityDescription insertNewObjectForEntityForName:@"InventoryEntity" inManagedObjectContext:helper.managedObjectContext];
                newInventory.itemNo = od.orderItemNo;
                newInventory.warehouse = self.currentOM.orderWarehouse;
                newInventory.qty = od.orderQty;
                [DataBaseManager updateToCoreData];
                //這邊也要判斷庫存不足
            }
            //算過了
            od.isInventory = @YES;
        }
    }
}

- (IBAction)saveOrder:(id)sender
{
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
    else if (self.orderWarehouseInput.text.length==0)
    {
        [AlertManager alert:@"倉庫未填" controller:self];
    }
    else
    {
        [self saveToOrderMasterObject];
        if ([self.whereFrom isEqualToString:@"bSegue"])
        {
            [self calculateInventory];
        }
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (IBAction)saveAndCreateOrder:(id)sender
{
    
}

- (IBAction)copyOrder:(id)sender
{
    
}

-(void)rollbackInventory:(OrderDetail*)od
{
    if ([od.isInventory boolValue] == YES)
    {
        NSLog(@"NO------%@",od.orderItemNo);
        NSLog(@"WH------%@",self.currentOM.orderWarehouse);
        Inventory *getInventory = [DataBaseManager fiterInventoryFromCoreDataWithItemNo:od.orderItemNo WithWarehouse:self.currentOM.orderWarehouse];
        
        if ([self.orderNoBegin isEqualToString:@"P"])
        {
            getInventory.qty = @([getInventory.qty integerValue]-[od.orderQty integerValue]);
            [DataBaseManager updateToCoreData];
        }
        else if ([self.orderNoBegin isEqualToString:@"S"])
        {
            getInventory.qty = @([getInventory.qty integerValue]+[od.orderQty integerValue]);
            //這邊還需要判斷庫存不足
            [DataBaseManager updateToCoreData];
        }
    }

}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        //生成物件
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        OrderDetail *od = [self.orderDetailList objectAtIndex:indexPath.row];
        //逆庫存
        [self rollbackInventory:od];
        //刪DB
        [helper.managedObjectContext deleteObject:od];
        //刪陣列
        [self.orderDetailList removeObjectAtIndex:indexPath.row];
        //刪cell
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //寫DB
        [DataBaseManager updateToCoreData];
        //如果還有單身的話,刪了之後後面開始的tag都要重排
        if (self.orderDetailList.count != 0)
        {
            for (NSInteger i=indexPath.row; i <= self.orderDetailList.count-1; i++)
            {
                NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
                OrderDetailCell *odCell = [self.orderDteailTableView cellForRowAtIndexPath:ip];
                odCell.odItemNo.tag -= 1 ;
                odCell.odQty.tag -= 1;
                odCell.odPrice.tag -= 1 ;
                OrderDetail *od = [self.orderDetailList objectAtIndex:i];
                int newSeq = [od.orderSeq intValue];
                newSeq -= 1;
                od.orderSeq = @(newSeq);
                [DataBaseManager updateToCoreData];
            }
        }
        self.currentOM.orderCount = @(self.orderDetailList.count);
        [DataBaseManager updateToCoreData];
        [self.orderDteailTableView reloadData];
    }
}

- (IBAction)deleteOrder:(id)sender
{
    //先存單號
    NSString *orderNo = self.currentOM.orderNo;
    
    NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.orderListInDteail indexOfObject:self.currentOM] inSection:0];
    //單身也要刪
    NSMutableArray *deadList = [DataBaseManager fiterFromCoreData:@"OrderDetailEntity" sortBy:@"orderSeq" fiterFrom:@"orderNo" fiterBy:orderNo];
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    for (OrderDetail *deadOD in deadList)
    {
        [self rollbackInventory:deadOD];
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

- (IBAction)backRootView:(id)sender
{
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
