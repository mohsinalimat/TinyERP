//
//  ItemViewController.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Item.h"

@protocol ItemViewControllerDelegate <NSObject>
-(void)cellInsert:(NSIndexPath*)indexPath;
-(void)cellRefresh:(Item*)item;
-(void)allCellRefresh;
-(void)cellDelete:(NSIndexPath*)indexPath;
@end

@interface ItemViewController : UIViewController
@property Item *thisItem;
@property (weak, nonatomic) IBOutlet UIImageView *itemImageView;
@property NSMutableArray *itemListInDetail;
@property id <ItemViewControllerDelegate> delegate;
@end
