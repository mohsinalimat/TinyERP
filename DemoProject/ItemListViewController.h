//
//  ItemListViewController.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@interface ItemListViewController : UIViewController <UISearchResultsUpdating>
@property (weak, nonatomic) IBOutlet UITableView *itemListTableView;
-(void)cellInsert:(NSIndexPath*)indexPath;
-(void)cellRefresh:(Item*)backItem;
-(void)allCellRefresh;
-(void)cellDelete:(NSIndexPath*)indexPath;
@end
