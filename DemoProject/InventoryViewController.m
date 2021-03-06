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
#import "Item.h"
#import "CollectionReusableViewWithTitle.h"

@interface InventoryViewController () <UICollectionViewDataSource,UICollectionViewDelegate,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *inventoryCollectionView;
@property NSMutableArray *totalInventoryList;
@property NSMutableArray *itemListSorted;
@property NSMutableArray *warehouseListSorted;
@property NSArray *itemGroupSortedArray;
@property NSArray *warehouseGroupSortedArray;
@property (weak, nonatomic) IBOutlet UISegmentedControl *inventorySegment;
@property BOOL isShowByItem;
@end

@implementation InventoryViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"庫存查詢";
    self.inventoryCollectionView.delegate = self;
    self.inventoryCollectionView.dataSource = self;
    self.isShowByItem = NO;
    [self prepareForShowData];
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:nil];
    [self prepareForShowData];
    [self.inventoryCollectionView reloadData];
}

-(void)prepareForShowData
{
    //先把所有非零庫存撈出
    self.totalInventoryList = [DataBaseManager fiterFromCoreData:@"InventoryEntity" sortBy:@"itemNo" fiterFrom:@"qty" fiterBy:@"0"];
    //去重
    NSSet *itemGroup = [NSSet setWithArray:[self.totalInventoryList valueForKey:@"itemNo"]];
    NSSet *warehouseGroup = [NSSet setWithArray:[self.totalInventoryList valueForKey:@"warehouse"]];
    //排序
#pragma mark Q.為何排序不用給Key
    NSArray *sortedArray = @[[[NSSortDescriptor alloc]initWithKey:nil ascending:YES]];
    self.itemGroupSortedArray = [itemGroup sortedArrayUsingDescriptors:sortedArray];
    self.warehouseGroupSortedArray = [warehouseGroup sortedArrayUsingDescriptors:sortedArray];
    //組二維陣列
    self.itemListSorted = [[NSMutableArray alloc]init];
    for (NSString *setString in self.itemGroupSortedArray)
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
    for (NSString *setString in self.warehouseGroupSortedArray)
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
    Item *item;
    if([DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:inv.itemNo].count !=0)
    {
        item = [DataBaseManager fiterFromCoreData:@"ItemEntity" sortBy:@"itemNo" fiterFrom:@"itemNo" fiterBy:inv.itemNo][0];
    }
    cell.inventoryImg.image = [UIImage imageWithData:item.itemImg] ;
    cell.inventoryQty.text = [inv.qty stringValue];
    cell.layer.borderWidth = 1;
    return cell;
}

//處理header或footer
-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionReusableViewWithTitle *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    if (self.isShowByItem)
    {
        NSArray *itemAarray = self.itemListSorted[indexPath.section];
        NSNumber *sumInventory = [itemAarray valueForKeyPath:@"@sum.qty"];
        NSString *headerString = [NSString stringWithFormat:@"%@總數%2.f",self.itemGroupSortedArray[indexPath.section],[sumInventory floatValue]];
        headerView.title.text = headerString;
    }
    else
    {
        NSArray *warehouseAarray = self.warehouseListSorted[indexPath.section];
        NSNumber *sumInventory = [warehouseAarray valueForKeyPath:@"@sum.qty"];
        NSString *headerString = [NSString stringWithFormat:@"%@總數%2.f",self.warehouseGroupSortedArray[indexPath.section],[sumInventory floatValue]];
        headerView.title.text = headerString;
    }
    return headerView;
}

//Header大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //寬度不管設多寬都比照superview
    CGSize size={0,22};
    return size;
}

//UICollectionViewCell的大小
- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 75);
}

//間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    NSLog(@"%@",indexPath);
}

- (IBAction)gestureLeft:(id)sender
{
    if (self.isShowByItem != YES)
    {
        self.isShowByItem = YES;
        self.inventorySegment.selectedSegmentIndex = 1;
        [self.inventoryCollectionView reloadData];
    }
}

- (IBAction)gestureRight:(id)sender
{
    if (self.isShowByItem != YES)
    {
        [self.navigationController popViewControllerAnimated:YES];
    }
    else
    {
        self.isShowByItem = NO;
        self.inventorySegment.selectedSegmentIndex = 0;
        [self.inventoryCollectionView reloadData];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}
@end
