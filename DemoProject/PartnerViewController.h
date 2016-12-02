//
//  PartnerViewController.h
//  DemoProject
//
//  Created by user32 on 2016/11/11.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Partner.h"

@interface PartnerViewController : UIViewController
@property (nonatomic) Partner *thisPartner;
@property (nonatomic) NSMutableArray *partnerListInDetail;
@property (nonatomic) NSString *whereFrom;
@property id delegate;
@end
