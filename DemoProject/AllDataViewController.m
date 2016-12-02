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

@interface AllDataViewController () <UITableViewDelegate,UITableViewDataSource,UINavigationControllerDelegate>
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
    //代理
    self.allDataTableView.delegate = self;
    self.allDataTableView.dataSource = self;
    //讀DB
    self.basicDataList = [DataBaseManager fiterFromCoreData:@"BasicDataEntity" sortBy:@"basicDataName" fiterFrom:@"basicDataType" fiterBy:self.whereFrom];
}

//cell筆數
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.basicDataList.count;
}

//cell樣式
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    EditCell *cell = [tableView dequeueReusableCellWithIdentifier:@"editCell"];
    BasicData *bd = [self.basicDataList objectAtIndex:indexPath.row];
    cell.editCellTextView.text = bd.basicDataName;
    return cell;
}

- (IBAction)dataAdd:(id)sender
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    BasicData *bd = [NSEntityDescription insertNewObjectForEntityForName:@"BasicDataEntity" inManagedObjectContext:helper.managedObjectContext];
    bd.basicDataName = [@"新 " stringByAppendingString:self.whereFrom];
    bd.basicDataType = self.whereFrom;
    [self.basicDataList insertObject:bd atIndex:0];
    [self.allDataTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    [DataBaseManager updateToCoreData];
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle==UITableViewCellEditingStyleDelete)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        
        BasicData *bd = [self.basicDataList objectAtIndex:indexPath.row];
        [helper.managedObjectContext deleteObject:bd];
        [self.basicDataList removeObject:bd];
        //刪cell
        [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        //寫DB
        [DataBaseManager updateToCoreData];
        
    }
}

-(void)saveTextView:(EditCell*)editCell
{
    //無法由cell得知位置, 頂多藉由cell的txet回推, 但也須全部比對
    if ([self.whereFrom isEqualToString:@"unitSegue"])
    {
        
    }
    else if ([self.whereFrom isEqualToString:@"itemKindSegue"])
    {
        
    }
}

- (IBAction)barBackButton:(id)sender
{
    //先存
    for (int i=0; i<self.basicDataList.count; i++)
    {
        BasicData *bd = [self.basicDataList objectAtIndex:i];
        NSIndexPath *ip = [NSIndexPath indexPathForRow:i inSection:0];
        EditCell *editCell = [self.allDataTableView cellForRowAtIndexPath:ip];
        bd.basicDataName = editCell.editCellTextView.text;
    }
    [DataBaseManager updateToCoreData];
    //比較是否重複
    BOOL isSameName = NO;
    for (BasicData *bd in self.basicDataList)
    {
        for (NSInteger i=[self.basicDataList indexOfObject:bd]+1; i<=self.basicDataList.count-1; i++)
        {
            BasicData *getBD = [self.basicDataList objectAtIndex:i];
            if ([bd.basicDataName isEqualToString:getBD.basicDataName])
            {
                isSameName = YES;
                break;
            }
        }
    }
    if (isSameName == YES)
    {
        [AlertManager alert:@"名稱重複" controller:self];
    }
    else
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
}

@end
