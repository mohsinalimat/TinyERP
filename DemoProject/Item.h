//
//  Item.h
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "CoreDataHelper.h"

//@interface Item : NSObject
@interface Item : NSManagedObject
@property NSString *itemNo;
@property NSString *itemName;
@property NSString *itemKind;
@property NSString *itemUnit;
@property NSNumber *itemPrice;
@property NSNumber *itemSafetyStock;
@property NSString *itemSpec;
@property NSString *itemRemark;
@property NSData *itemImg;
//@property NSString *itemImg;
@end
