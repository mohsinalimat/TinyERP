//
//  Member.h
//  DemoProject
//
//  Created by user32 on 2016/12/13.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "CoreDataHelper.h"

//@interface Member : NSObject
@interface Member : NSManagedObject
@property NSString *memberID;
@property NSString *memberPW;
@property NSString *memberName;
@property NSDate *memberBirthday;
@property NSData *memberImg;
@end

