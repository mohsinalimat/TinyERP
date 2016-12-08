//
//  BasicData.h
//  DemoProject
//
//  Created by user32 on 2016/11/15.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

//@interface BasicData : NSObject
@interface BasicData : NSManagedObject
@property NSString *basicDataType;
@property NSString *basicDataName;
@end
