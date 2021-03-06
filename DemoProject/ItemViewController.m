//
//  ItemViewController.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "ItemViewController.h"
#import "Item.h"
#import "BasicData.h"
#import "DataBaseManager.h"
#import "ItemListViewController.h"
#import "AlertManager.h"
#import "ImageManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ItemViewController () <UINavigationControllerDelegate,UIImagePickerControllerDelegate,UIPickerViewDelegate,UIPickerViewDataSource,UITextFieldDelegate,UITextViewDelegate,GADInterstitialDelegate>

@property (nonatomic) GADInterstitial *interAD;
@property (weak, nonatomic) IBOutlet UIPickerView *pickerView;
//文字欄位
@property (weak, nonatomic) IBOutlet UITextField *itemNoInput;
@property (weak, nonatomic) IBOutlet UITextField *itemNameInput;
@property (weak, nonatomic) IBOutlet UITextField *itemKindInput;
@property (weak, nonatomic) IBOutlet UITextField *itemUnitInput;
@property (weak, nonatomic) IBOutlet UITextField *itemPriceInput;
@property (weak, nonatomic) IBOutlet UITextField *itemSafetyStockInput;
@property (weak, nonatomic) IBOutlet UITextField *itemSpecInput;
@property (weak, nonatomic) IBOutlet UITextView *itemRemarkInput;

@property (weak, nonatomic) IBOutlet UIButton *itemDeleteButton;
@property (weak, nonatomic) IBOutlet UILabel *itemNoIsSame;

@property (nonatomic) BOOL isCreateStatus;
@property (nonatomic) BOOL isCreataAgain;
@property (nonatomic) NSMutableArray *unitList;
@property (nonatomic) NSMutableArray *itemKindList;
@property (nonatomic) NSString *whichInput;
@property (nonatomic) NSString *originalItemNo;
@property ImageManager *imgManager;
@end

@implementation ItemViewController

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        self.unitList = [[NSMutableArray alloc]init];
        self.itemKindList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    //預設不顯示
    //[self.pickerView setHidden:YES];
    self.pickerView.alpha = 0;
    [self.itemNoIsSame setHidden:YES];
    
    //廣告
    self.interAD = [[GADInterstitial alloc]initWithAdUnitID:@"ca-app-pub-7838204729392356/2229865429"];
    self.interAD.delegate = self;
    //模擬器的話就放假廣告
    GADRequest *request = [GADRequest request];
    [request setTestDevices:@[kGADSimulatorID]];
    [self.interAD loadRequest:request];
    
    //模擬器跑真廣告好像會壞
    //[self.interAD loadRequest:[GADRequest request]];
    
    //代理
    self.itemNoInput.delegate = self;
    self.itemNameInput.delegate = self;
    self.itemKindInput.delegate = self;
    self.itemUnitInput.delegate = self;
    self.itemPriceInput.delegate = self;
    self.itemPriceInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.itemSafetyStockInput.delegate = self;
    self.itemSafetyStockInput.keyboardType = UIKeyboardTypeNumbersAndPunctuation;
    self.itemSpecInput.delegate = self;
    self.pickerView.delegate = self;
    self.pickerView.dataSource = self;
    
    //撈資料
    self.unitList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"單位"];
    self.itemKindList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:@"商品分類"];
    
    //設定UI
    self.title=@"商品明細";
    self.itemRemarkInput.layer.borderWidth = 1;
    self.itemRemarkInput.layer.borderColor = self.view.tintColor.CGColor;
    self.itemImageView.layer.borderWidth = 1;
    self.itemImageView.layer.borderColor = self.view.tintColor.CGColor;
    //設定欄位提示
    self.itemNoInput.placeholder = @"必填,請勿輸入中文";
    self.itemNameInput.placeholder = @"必填";
    self.itemUnitInput.placeholder = @"必填";
    
    //設定欄位初始值
    self.itemNoInput.text = self.thisItem.itemNo;
    self.itemNameInput.text = self.thisItem.itemName;
    self.itemKindInput.text = self.thisItem.itemKind;
    self.itemUnitInput.text = self.thisItem.itemUnit;
    if (![[self.thisItem.itemPrice stringValue]isEqualToString:@"0"])
    {
        self.itemPriceInput.text = [self.thisItem.itemPrice stringValue];
    }
    if (![[self.thisItem.itemSafetyStock stringValue]isEqualToString:@"0"])
    {
        self.itemSafetyStockInput.text = [self.thisItem.itemSafetyStock stringValue];
    }
    self.itemSpecInput.text = self.thisItem.itemSpec;
    self.itemRemarkInput.text = self.thisItem.itemRemark;
    self.itemImageView.image = [UIImage imageWithData:self.thisItem.itemImg];
    
    //紀錄原始料號, 供重複比對時使用(這行不能放在已經給值之前!!!)
    self.originalItemNo = self.itemNoInput.text;
    
    //若必填欄位沒值
    if (self.itemNoInput.text.length==0 || self.itemNameInput.text.length==0)
    {
        //關掉返回
        [self.navigationItem setHidesBackButton:YES animated:YES];
        //更改按鈕文字
        [self.itemDeleteButton setTitle:@"放棄新增" forState:UIControlStateNormal];
        //設定為新增狀態
        self.isCreateStatus = YES;
    }
}

-(void)showPickerView:(NSString*)whichInput
{
    [UIView animateWithDuration:0.75 animations:
     ^{
         //[self.pickerView setHidden:NO];
         self.pickerView.alpha = 1;
     }];
    self.whichInput = whichInput;
    [self.pickerView reloadAllComponents];
}

//開始編輯
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    //不管是誰先藏picker
    self.pickerView.alpha = 0;
    if (textField == self.itemUnitInput)
    {
        [self showPickerView:@"單位"];
    }
    else if (textField == self.itemKindInput)
    {
        [self showPickerView:@"商品分類"];
    }
}

//結束編輯
-(void)textFieldDidEndEditing:(UITextField *)textField
{
    if (textField == self.itemNoInput)
    {
        [self isSameItemNo];
    }
    else if (textField == self.itemUnitInput || textField == self.itemKindInput)
    {
        //[self.pickerView setHidden:YES];
        self.pickerView.alpha = 0;
    }
    [textField resignFirstResponder];
}

//觸碰self.view縮鍵盤
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.pickerView.alpha = 0;
    [self.itemRemarkInput resignFirstResponder];
}

//不准輸入
-(BOOL)textField:(UITextField *)textField shouldChangeCharactersInRange:(NSRange)range replacementString:(NSString *)string
{
    if (textField==self.itemUnitInput || textField==self.itemKindInput)
    {
        return NO;
    }
    return YES;
}

-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    if (textField == self.itemUnitInput || textField == self.itemKindInput)
    {
        //[self.pickerView setHidden:YES];
        self.pickerView.alpha = 0;
    }
    return YES;
}

//幾個滾輪(不可省略= =)
-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

//每個滾輪幾筆資料
-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    if ([self.whichInput isEqualToString:@"單位"])
    {
        return self.unitList.count;
    }
    else if ([self.whichInput isEqualToString:@"商品分類"])
    {
        return self.itemKindList.count;
    }
    return 0;
}

//row的樣子
-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    BasicData *bd;
    if ([self.whichInput isEqualToString:@"單位"])
    {
        bd = [self.unitList objectAtIndex:row];
    }
    else if ([self.whichInput isEqualToString:@"商品分類"])
    {
        bd = [self.itemKindList objectAtIndex:row];
    }
    return bd.basicDataName;
}

//選擇row
-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    BasicData *bd;
    if ([self.whichInput isEqualToString:@"單位"])
    {
        if (self.unitList.count!=0)
        {
            bd = [self.unitList objectAtIndex:row];
            self.itemUnitInput.text = bd.basicDataName;
        }
    }
    else if ([self.whichInput isEqualToString:@"商品分類"])
    {
        if (self.unitList.count!=0)
        {
            bd = [self.itemKindList objectAtIndex:row];
            self.itemKindInput.text = bd.basicDataName;
        }
    }
}

-(void)prepareForImage
{
    self.imgManager = [ImageManager new];
    self.imgManager.vc = self;
    self.imgManager.imageView = self.itemImageView;
}

- (IBAction)itemIamge:(id)sender
{
    [self prepareForImage];
    [self.imgManager getImageByAlbum];
}

- (IBAction)itemCamera:(id)sender
{
    [self prepareForImage];
    [self.imgManager getImageByCamera];
}

//挑完照片
-(void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info
{
    self.imgManager.imageInfo = info;
    [self.imgManager putImage];
}

- (IBAction)itemImgDelete:(id)sender
{
    self.imgManager = [ImageManager new];
    self.imgManager.vc = self;
    self.imgManager.imageView = self.itemImageView;
    [self.imgManager deleteImage];
}

//把值寫回當前物件
-(void)saveToItemObject
{
    self.thisItem.itemNo = self.itemNoInput.text;
    self.thisItem.itemName = self.itemNameInput.text;
    self.thisItem.itemKind = self.itemKindInput.text;
    self.thisItem.itemUnit = self.itemUnitInput.text;
    NSNumber *price = [NSNumber numberWithFloat:[self.itemPriceInput.text floatValue]];
    self.thisItem.itemPrice = price;
    NSNumber *safe = [NSNumber numberWithFloat:[self.itemSafetyStockInput.text floatValue]];
    self.thisItem.itemSafetyStock = safe;
    self.thisItem.itemSpec = self.itemSpecInput.text;
    self.thisItem.itemRemark = self.itemRemarkInput.text;
    self.thisItem.itemImg = UIImageJPEGRepresentation(self.itemImageView.image,1);
    [DataBaseManager updateToCoreData];
}

-(BOOL)saveCheckOK
{
    if (self.itemNoInput.text.length==0)
    {
        [AlertManager alert:@"商品編號未填" controller:self];
        return NO;
    }
    else if (self.itemNameInput.text.length==0)
    {
        [AlertManager alert:@"商品名稱未填" controller:self];
        return NO;
    }
    else if (self.itemUnitInput.text.length==0)
    {
        [AlertManager alert:@"商品單位未填" controller:self];
        return NO;
    }
    else if ([self isSameItemNo] == YES)
    {
        [AlertManager alert:@"商品編號重複" controller:self];
        return NO;
    }
    return YES;
}

-(BOOL)isSameItemNo
{
    //NSLog(@"=====================================================");
    for (Item *item in self.itemListInDetail)
    {
        //NSLog(@"%@======================%@",self.originalItemNo,self.itemNoInput.text);
        //NSLog(@"%@",item.itemNo);
        //如果最後的文字 跟陣列裡某文字一樣 且 不等於原始
        if ([self.itemNoInput.text isEqualToString:item.itemNo] && ![self.itemNoInput.text isEqualToString:self.originalItemNo]
            )
        {
            [self.itemNoIsSame setHidden:NO];
            return YES;
        }
    }
    [self.itemNoIsSame setHidden:YES];
    return NO;
}

-(void)saveRefresh
{
    //如果新增多筆
    if (self.isCreataAgain==YES)
    {
        //整個tableView刷新
        [self.delegate allCellRefresh];
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        //只刷新一筆cell
        [self.delegate cellRefresh:self.thisItem];
        [self.navigationController popViewControllerAnimated:YES];
    }
}

//按下儲存
- (IBAction)itemInputDone:(id)sender
{
    if ([self saveCheckOK])
    {
        [self saveToItemObject];
        if (self.interAD.isReady)
        {
            [self.interAD presentFromRootViewController:self];
        }
        [self saveRefresh];
    }
}

//儲存並新增
- (IBAction)itemInputDoneAndCreate:(id)sender
{
    if ([self saveCheckOK])
    {
        //存值並寫DB
        [self saveToItemObject];
        //建立新的物件
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"ItemEntity" inManagedObjectContext:helper.managedObjectContext];
        //塞到陣列
        [self.itemListInDetail insertObject:item atIndex:0];
        //新增到前一頁TV
        NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
        [self.delegate cellInsert:ip];
        //新物件指定為當前物件
        self.thisItem = item;
        //清空畫面
        self.itemNoInput.text = @"";
        self.itemNameInput.text = @"";
        self.itemKindInput.text = @"";
        self.itemUnitInput.text = @"";
        self.itemPriceInput.text = [@0 stringValue];
        self.itemSafetyStockInput.text = [@0 stringValue];
        self.itemSpecInput.text = @"";
        self.itemRemarkInput.text = @"";
        self.itemImageView.image = nil;
        //新增多筆為是
        self.isCreataAgain = YES;
        [self.itemNoInput becomeFirstResponder];
    }
}

//按下刪除
- (IBAction)itemDeleteButton:(id)sender
{
    //刪之前要先存索引
    NSUInteger deleteIndex = [self.itemListInDetail indexOfObject:self.thisItem];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:deleteIndex inSection:0];
    
    [DataBaseManager deleteDataAndObject:self.thisItem array:self.itemListInDetail];
    
    //畫面一定要最後刪
    [self.delegate cellDelete:ip];
    [self.navigationController popViewControllerAnimated:YES];
}

//回首頁
- (IBAction)backRootView:(id)sender
{
    //如果是新增狀態才刪
    if (self.isCreateStatus == YES)
    {
        [DataBaseManager deleteDataAndObject:self.thisItem array:self.itemListInDetail];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

//使用者按下x，關閉廣告
-(void)interstitialDidDismissScreen:(GADInterstitial *)ad
{
    [self saveRefresh];
}

//使用者點擊廣告，賺錢
-(void)interstitialWillLeaveApplication:(GADInterstitial *)ad
{
    [self dismissViewControllerAnimated:YES completion:
     ^{
         [self saveRefresh];
    }];
}
- (IBAction)gesturePop:(id)sender
{
    if (self.itemNoInput.text.length!=0 && self.itemNameInput.text.length!=0)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
