//
//  InventoryCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/29.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface InventoryCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *inventoryNo;
@property (weak, nonatomic) IBOutlet UILabel *inventoryWarehouse;
@property (weak, nonatomic) IBOutlet UILabel *inventoryQty;
@property (weak, nonatomic) IBOutlet UIImageView *inventoryImg;
@end
