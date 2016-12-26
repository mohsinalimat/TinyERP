//
//  AllDataViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/7.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "AllDataViewController.h"
#import "CoreDataHelper.h"
#import "DataBaseManager.h"
#import "EditCell.h"
#import "BasicData.h"
#import "AlertManager.h"
#import "BankAccount.h"
#import "BankAccountCell.h"

@interface AllDataViewController () <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate,UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITableView *allDataTableView;
@property (nonatomic) NSMutableArray *basicDataList;
@end

@implementation AllDataViewController

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        //初始化陣列
        self.basicDataList = [[NSMutableArray alloc]init];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    [self.navigationItem setHidesBackButton:YES animated:YES];
    self.title = self.whereFrom;
    //代理
    self.allDataTableView.delegate = self;
    self.allDataTableView.dataSource = self;
    //讀DB
    if ([self.whereFrom isEqualToString:@"銀行帳號"])
    {
        self.basicDataList = [DataBaseManager queryFromCoreData:@"BankAccountEntity" sortBy:@"bankID"];
    }
    else
    {
        self.basicDataList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:self.whereFrom];
    }
}

//cell筆數
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.basicDataList.count;
}

//cell樣式
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    if ([self.whereFrom isEqualToString:@"銀行帳號"])
    {
        BankAccountCell *baCell = [tableView dequeueReusableCellWithIdentifier:@"bankAcountCell"];
        BankAccount *ba = [self.basicDataList objectAtIndex:indexPath.row];
        baCell.bankIDInput.text = ba.bankID;
        baCell.bankNameInput.text = ba.bankName;
        baCell.bankAccountInput.text = ba.bankAccount;
        return baCell;
    }
    else
    {
        EditCell *editCell = [tableView dequeueReusableCellWithIdentifier:@"editCell"];
        BasicData *bd = [self.basicDataList objectAtIndex:indexPath.row];
        editCell.editCellTextView.text = bd.basicDataName;
        if ([editCell.editCellTextView.text isEqualToString:@"點我輸入"])
        {
            editCell.editCellTextView.textColor = [UIColor lightGrayColor];
        }
        editCell.editCellTextView.delegate = self;
        return editCell;
    }
    return nil;
}

-(void)textViewDidBeginEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@"點我輸入"])
    {
        textView.text = @"";
        textView.textColor = [UIColor blackColor];
    }
}

-(void)textViewDidEndEditing:(UITextView *)textView
{
    if ([textView.text isEqualToString:@""])
    {
        textView.text = @"點我輸入";
        textView.textColor = [UIColor lightGrayColor];
    }
}

- (IBAction)dataAdd:(id)sender
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    
    if ([self.whereFrom isEqualToString:@"銀行帳號"])
    {
        BankAccount *ba = [NSEntityDescription insertNewObjectForEntityForName:@"BankAccountEntity" inManagedObjectContext:helper.managedObjectContext];
        [self.basicDataList insertObject:ba atIndex:0];
    }
    else
    {
        BasicData *bd = [NSEntityDescription insertNewObjectForEntityForName:@"BasicDataEntity" inManagedObjectContext:helper.managedObjectContext];
        bd.basicDataName = @"點我輸入";
        bd.basicDataType = self.whereFrom;
        [self.basicDataList insertObject:bd atIndex:0];
    }
    [self.allDataTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        if ([self.whereFrom isEqualToString:@"銀行帳號"])
        {
            BankAccount *ba = [self.basicDataList objectAtIndex:indexPath.row];
            [helper.managedObjectContext deleteObject:ba];
            [self.basicDataList removeObject:ba];
        }
        else
        {
            BasicData *bd = [self.basicDataList objectAtIndex:indexPath.row];
            [helper.managedObjectContext deleteObject:bd];
            [self.basicDataList removeObject:bd];
        }
        //刪cell
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //寫DB
        [DataBaseManager updateToCoreData];
        
    }
}

-(void)saveTextView:(EditCell*)editCell
{
    //無法由cell得知位置, 頂多藉由cell的txet回推, 但也須全部比對
}

- (IBAction)barBackButton:(id)sender
{
    if ([self.whereFrom isEqualToString:@"銀行帳號"])
    {
        //先存
        for (int i=0; i<self.basicDataList.count; i++)
        {
            BankAccount *ba = [self.basicDataList objectAtIndex:i];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            BankAccountCell *baCell = [self.allDataTableView cellForRowAtIndexPath:ip];
            ba.bankID = baCell.bankIDInput.text;
            ba.bankName = baCell.bankNameInput.text;
            ba.bankAccount = baCell.bankAccountInput.text;
        }
        //比較是否重複
        BOOL isSameAccount = NO;
        BOOL isNoField = NO;
        for (BankAccount *ba in self.basicDataList)
        {
            for (NSInteger i=[self.basicDataList indexOfObject:ba]+1; i<=self.basicDataList.count-1; i++)
            {
                if ([ba.bankID isEqualToString:@""] || [ba.bankName isEqualToString:@""] || [ba.bankAccount isEqualToString:@""])
                {
                    isNoField = YES;
                    goto baInvalid;
                }
                BankAccount *getBA = [self.basicDataList objectAtIndex:i];
                if ([ba.bankAccount isEqualToString:getBA.bankAccount])
                {
                    isSameAccount = YES;
                    goto baInvalid;
                }
            }
        }
        baInvalid:
        if (isSameAccount == YES)
        {
            [AlertManager alert:@"帳號重複" controller:self];
        }
        else if (isNoField == YES)
        {
            [AlertManager alert:@"有資料尚未輸入" controller:self];
        }
        else
        {
            [DataBaseManager updateToCoreData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
    else
    {
        //先存
        for (int i=0; i<self.basicDataList.count; i++)
        {
            BasicData *bd = [self.basicDataList objectAtIndex:i];
            NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
            EditCell *editCell = [self.allDataTableView cellForRowAtIndexPath:ip];
            bd.basicDataName = editCell.editCellTextView.text;
        }
        //比較是否重複
        BOOL isSameName = NO;
        BOOL isNoName = NO;
        BOOL isLongName = NO;
        for (BasicData *bd in self.basicDataList)
        {
            for (NSInteger i=[self.basicDataList indexOfObject:bd]+1; i<=self.basicDataList.count-1; i++)
            {
                if ([bd.basicDataName isEqualToString:@""] || [bd.basicDataName isEqualToString:@"點我輸入"] || [bd.basicDataName isEqualToString:@" "] || [bd.basicDataName isEqualToString:@"　"])
                {
                    isNoName = YES;
                    goto bdInvalid;
                }
                if ([bd.basicDataType isEqualToString:@"單位"] && [self stringEncodingLenght:bd.basicDataName]>4)
                {
                    isLongName = YES;
                    goto bdInvalid;
                }
                BasicData *getBD = [self.basicDataList objectAtIndex:i];
                if ([bd.basicDataName isEqualToString:getBD.basicDataName])
                {
                    isSameName = YES;
                    goto bdInvalid;
                }
            }
        }
        bdInvalid:
        if (isSameName == YES)
        {
            [AlertManager alert:@"名稱重複" controller:self];
        }
        else if (isLongName == YES)
        {
            [AlertManager alert:@"單位字數過長\n(中文兩個字英文四個字)" controller:self];
        }
        else if (isNoName == YES)
        {
            [AlertManager alert:@"有資料尚未輸入" controller:self];
        }
        else
        {
            [DataBaseManager updateToCoreData];
            [self.navigationController popViewControllerAnimated:YES];
        }
    }
}

- (NSUInteger)stringEncodingLenght:(NSString*)string

{
    NSStringEncoding enc = CFStringConvertEncodingToNSStringEncoding(kCFStringEncodingGB_18030_2000);
    NSData* stringData = [string dataUsingEncoding:enc];
    return [stringData length];
}

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

@end
