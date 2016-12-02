//
//  CoreDataHelper.h
//  Notes
//
//  Created by vincent on 13/10/14.
//  Copyright (c) 2013年 vincent. All rights reserved.
//

#import <Foundation/Foundation.h>
@import CoreData;

@interface CoreDataHelper : NSObject
@property(nonatomic)NSManagedObjectContext *managedObjectContext;

+(CoreDataHelper*) sharedInstance;

@end
