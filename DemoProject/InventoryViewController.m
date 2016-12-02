//
//  InventoryViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/25.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "InventoryViewController.h"
#import "InventoryCell.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "Inventory.h"

@interface InventoryViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *inventoryCollectionView;
@property NSMutableArray *totalInventoryList;
@property NSMutableArray *itemListSorted;
@property NSMutableArray *warehouseListSorted;
@property BOOL isShowByItem;
@end

@implementation InventoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.inventoryCollectionView.delegate = self;
    self.inventoryCollectionView.dataSource = self;
    self.isShowByItem = NO;
    //先把所有非零庫存撈出
    self.totalInventoryList = [DataBaseManager fiterFromCoreData:@"InventoryEntity" sortBy:@"itemNo" fiterFrom:@"qty" fiterBy:@"0"];
    //去重
    NSSet *itemGroup = [NSSet setWithArray:[self.totalInventoryList valueForKey:@"itemNo"]];
    NSSet *warehouseGroup = [NSSet setWithArray:[self.totalInventoryList valueForKey:@"warehouse"]];
    //排序
    NSArray *sortedArray = @[[[NSSortDescriptor alloc]initWithKey:nil ascending:YES]];
    NSArray *itemGroupSortedArray = [itemGroup sortedArrayUsingDescriptors:sortedArray];
    NSArray *warehouseGroupSortedArray = [warehouseGroup sortedArrayUsingDescriptors:sortedArray];
    //組二維陣列
    self.itemListSorted = [[NSMutableArray alloc]init];
    for (NSString *setString in itemGroupSortedArray)
    {
        NSMutableArray *aItemList = [[NSMutableArray alloc]init];
        for (Inventory *inv in self.totalInventoryList)
        {
            if (inv.itemNo == setString)
            {
                [aItemList addObject:inv];
            }
        }
        [self.itemListSorted addObject:aItemList];
    }
    
    self.warehouseListSorted = [[NSMutableArray alloc]init];
    for (NSString *setString in warehouseGroupSortedArray)
    {
        NSMutableArray *aWarehouseList = [[NSMutableArray alloc]init];
        for (Inventory *inv in self.totalInventoryList)
        {
            if (inv.warehouse == setString)
            {
                [aWarehouseList addObject:inv];
            }
        }
        [self.warehouseListSorted addObject:aWarehouseList];
    }
}

- (IBAction)InventorySegment:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex==0)
    {
        self.isShowByItem = NO;
    }
    else
    {
        self.isShowByItem = YES;
    }
    [self.inventoryCollectionView reloadData];
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    if (self.isShowByItem)
    {
        return self.itemListSorted.count;
    }
    else
    {
        return self.warehouseListSorted.count;
    }
    return 0;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isShowByItem)
    {
        NSArray *aItemList = self.itemListSorted[section];
        return aItemList.count;
    }
    else
    {
        NSArray *aWarehouseList = self.warehouseListSorted[section];
        return aWarehouseList.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    InventoryCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"inventoryCell" forIndexPath:indexPath];
    cell.inventoryNo.text = @"";
    cell.inventoryWarehouse.text = @"";
    Inventory *inv;
    if (self.isShowByItem)
    {
        inv = [[self.itemListSorted objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.inventoryWarehouse.text = inv.warehouse;
    }
    else
    {
        inv = [[self.warehouseListSorted objectAtIndex:indexPath.section] objectAtIndex:indexPath.row];
        cell.inventoryNo.text = inv.itemNo;
    }
    cell.inventoryQty.text = [inv.qty stringValue];
    return cell;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
