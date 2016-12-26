//
//  BankAccount.h
//  DemoProject
//
//  Created by user32 on 2016/12/26.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

@interface BankAccount : NSManagedObject
@property NSString *bankID;
@property NSString *bankName;
@property NSString *bankAccount;
@end
