//
//  ItemListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "ItemListViewController.h"
#import "Item.h"
#import "ItemViewController.h"
#import "CoreDataHelper.h"
#import "DataBaseManager.h"
#import <GoogleMobileAds/GoogleMobileAds.h>

@interface ItemListViewController () <UITableViewDelegate,UITableViewDataSource,GADBannerViewDelegate,UISearchBarDelegate>
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *tableViewTopConstraint;
//@property (weak, nonatomic) IBOutlet UITableView *itemListTableView;
#pragma mark Q.search用拉的該如何實作？
@property (nonatomic) UISearchController *itemListSearchController;
@property NSMutableArray *itemList;
@property NSArray *itemListSearchResults;
@property (nonatomic) GADBannerView *bannerAD;
@end

@implementation ItemListViewController

-(instancetype)initWithCoder:(NSCoder *)coder
{
    self = [super initWithCoder:coder];
    if (self)
    {
        //初始化陣列
        self.itemList = [[NSMutableArray alloc]init];
        //根據料號排序
        self.itemList = [DataBaseManager queryFromCoreData:@"ItemEntity" sortBy:@"itemNo"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"商品清單";
    self.itemListTableView.delegate = self;
    self.itemListTableView.dataSource = self;
    [self.itemList enumerateObjectsUsingBlock:^(Item *deleteItem, NSUInteger idx, BOOL *stop)
    {
        if (deleteItem.itemNo == nil)
        {
            *stop = YES;
            if (*stop)
            {
                CoreDataHelper *helper = [CoreDataHelper sharedInstance];
                [helper.managedObjectContext deleteObject:deleteItem];
                [self.itemList removeObject:deleteItem];
            }
        }
    }];
    //加廣告
    self.bannerAD = [[GADBannerView alloc]initWithAdSize:kGADAdSizeSmartBannerPortrait];
    self.bannerAD.adUnitID = @"ca-app-pub-7838204729392356/8056073022";
    self.bannerAD.delegate = self;
    //Google規定要設的, 據說是為了讓Google知道在哪個VC
    self.bannerAD.rootViewController = self;
    //因為下面要設動態Constraint, 所以這個舊設定先關掉
    self.bannerAD.translatesAutoresizingMaskIntoConstraints = NO;
    [self.bannerAD loadRequest:[GADRequest request]];
    
    //產生搜尋物件
    //ResultsController可以指定別的ViewController
    self.itemListSearchController = [[UISearchController alloc]initWithSearchResultsController:nil];
    self.itemListSearchController.searchBar.scopeButtonTitles = @[@"商品分類",@"商品編號",@"商品名稱"];
    self.itemListSearchController.searchBar.delegate = self;
    
    //設定高度
    CGRect rect = self.itemListSearchController.searchBar.frame;
    rect.size.height = 44.0;
    self.itemListSearchController.searchBar.frame = rect;
    //搜尋時背景不要變暗(變暗就點不到結果)
    self.itemListSearchController.dimsBackgroundDuringPresentation = NO;
    //放到TableView的上方
    self.itemListTableView.tableHeaderView = self.itemListSearchController.searchBar;
    //當前VC回應搜尋結果
    self.itemListSearchController.searchResultsUpdater = self;
    //意義不明(加了這行搜尋欄才不會跳到下一頁)
    self.definesPresentationContext = YES;
    //一開始隱藏(位移)SearchBar(聽說這種做法比較專業)
    self.itemListTableView.contentOffset = CGPointMake(0, 44);
}

//如果有收到廣告
-(void)adViewDidReceiveAd:(GADBannerView *)bannerView
{
    if (![bannerView superview])
    {
        [self.view addSubview:bannerView];
        //關閉table view 上方的constraint
        self.tableViewTopConstraint.active = NO;
        //重新產生autolayout
        NSArray *constraints =  [NSLayoutConstraint constraintsWithVisualFormat:@"V:[top][ad][tableView]|" options:0 metrics:nil views:@{@"ad":bannerView,@"tableView":self.itemListTableView,@"top":self.topLayoutGuide}];
        NSArray *horizonalConstraints =  [NSLayoutConstraint constraintsWithVisualFormat:@"H:|[adview]|" options:0 metrics:nil views:@{@"adview":bannerView}];
        [NSLayoutConstraint activateConstraints:constraints];
        [NSLayoutConstraint activateConstraints:horizonalConstraints];
    }
}

//cell數量
-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (self.itemListSearchResults != nil)
    {
        return self.itemListSearchResults.count;
    }
    return self.itemList.count;
}

//決定cell樣式
-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    //生成cell
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"itemCell"];
    
    //生成item
    Item *item;
    
    if (self.itemListSearchResults != nil)
    {
        item = [self.itemListSearchResults objectAtIndex:indexPath.row];
    }
    else
    {
        item = [self.itemList objectAtIndex:indexPath.row];
    }
    
    //設定cell文字
    NSString *title = [@"" stringByAppendingFormat:@"[%@]%@_%@",item.itemKind,item.itemNo,item.itemName];
    
//    NSString *title = @"編號";
//    title = [title stringByAppendingFormat:@"%@名稱%@",item.itemNo,item.itemName];
    
    cell.textLabel.text = title;
    
    return cell;
}

//按下新增
- (IBAction)itenListAdd:(id)sender
{
    //生成物件插入陣列
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Item *item = [NSEntityDescription insertNewObjectForEntityForName:@"ItemEntity" inManagedObjectContext:helper.managedObjectContext];
    [self.itemList insertObject:item atIndex:0];
    //顯示在TableView
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.itemListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    //寫DB
    [DataBaseManager updateToCoreData];
    //生成ViewController
    ItemViewController *ivc = [self.storyboard instantiateViewControllerWithIdentifier:@"itemViewController"];
    //把物件跟陣列丟過去
    ivc.thisItem = item;
    ivc.itemListInDetail = self.itemList;
    //委派
    ivc.delegate = self;
    //換頁
    [self showViewController:ivc sender:self];
}

-(BOOL)tableView:(UITableView *)tableView canEditRowAtIndexPath:(NSIndexPath *)indexPath{
    if (self.itemListSearchController.active){
        return NO;
    }
    return YES;
}

//啟用滑動編輯
-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (self.itemListSearchController.active==NO)
    {
        if (editingStyle==UITableViewCellEditingStyleDelete)
        {
            //生成物件
            CoreDataHelper *helper = [CoreDataHelper sharedInstance];
            Item *item = [self.itemList objectAtIndex:indexPath.row];
            //刪DB
            [helper.managedObjectContext deleteObject:item];
            //刪陣列
            [self.itemList removeObjectAtIndex:indexPath.row];
            //刪cell
            [tableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
            //寫DB
            [DataBaseManager updateToCoreData];
        }
    }
}

//串場前準備
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    //生成ViewController物件
    ItemViewController *ivc = segue.destinationViewController;
    //找到被選的cell
    NSIndexPath *ip = self.itemListTableView.indexPathForSelectedRow;
    //生成物件
    Item *item;
    if (self.itemListSearchResults != nil)
    {
        item = [self.itemListSearchResults objectAtIndex:ip.row];
    }
    else
    {
        item  = [self.itemList objectAtIndex:ip.row];
    }
    //把物件跟陣列丟過去
    ivc.thisItem = item;
    ivc.itemListInDetail = self.itemList;
    //委派
    ivc.delegate = self;
}

-(void)cellInsert:(NSIndexPath*)indexPath
{
    [self.itemListTableView insertRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//原本寫法
-(void)cellRefresh:(Item*)backItem
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.itemList indexOfObject:backItem] inSection:0];
    [self.itemListTableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//肯特建議可以全部刷新
-(void)allCellRefresh
{
    [self.itemListTableView reloadData];
}

-(void)cellDelete:(NSIndexPath*)indexPath
{
    [self.itemListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
}

//接陣列寫法(有空研究為何不行)
//-(void)cellRefresh:(NSArray*)backItemList
//{
//    //生成一個陣列放IndexPath
//    NSMutableArray *indexPathList = [[NSMutableArray alloc]init];
//    //把每個物件拿出來放到indexPathList
//    for (int i=0; i<backItemList.count; i++)
//    {
//        Item *getItem = [backItemList objectAtIndex:i];
//        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.itemList indexOfObject:getItem] inSection:0];
//        [indexPathList insertObject:ip atIndex:i];
//    }
//    //刷新TableView
//    [self.itemTableView reloadRowsAtIndexPaths:indexPathList withRowAnimation:UITableViewRowAnimationAutomatic];
//    //寫DB
//    [DataBaseManager updateToCoreData];
//}

-(void)searchBar:(UISearchBar *)searchBar selectedScopeButtonIndexDidChange:(NSInteger)selectedScope
{
    [self updateSearchResultsForSearchController:self.itemListSearchController];
}

//更新搜尋結果
-(void)updateSearchResultsForSearchController:(UISearchController *)searchController
{
    if (searchController.isActive)
    {
        //搜尋字串前後接星號
        NSString *star = @"*";
        NSString *searchString = self.itemListSearchController.searchBar.text;
        searchString = [searchString stringByAppendingString:@"*"];
        star = [star stringByAppendingString:searchString];
        //如果有打字
        if ([searchString length] > 0)
        {
            NSInteger scopeIndex = self.itemListSearchController.searchBar.selectedScopeButtonIndex;
            switch (scopeIndex)
            {
                case 0:
                {
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"itemKind like [cd] %@", star];
                    self.itemListSearchResults = [self.itemList filteredArrayUsingPredicate:p];
                    break;
                }
                case 1:
                {
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"itemNo like [cd] %@", star];
                    self.itemListSearchResults = [self.itemList filteredArrayUsingPredicate:p];
                    break;
                }
                case 2:
                {
                    NSPredicate *p = [NSPredicate predicateWithFormat:@"itemName like [cd] %@", star];
                    self.itemListSearchResults = [self.itemList filteredArrayUsingPredicate:p];
                    break;
                }
                default:
                    break;
            }
        }
        else
        {
            self.itemListSearchResults = nil;
        }
    }
    else
    {
        self.itemListSearchResults = nil;
    }
    
    [self.itemListTableView reloadData];
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
