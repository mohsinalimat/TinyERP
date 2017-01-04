//
//  DataPickerManager.h
//  DemoProject
//
//  Created by user32 on 2016/12/30.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface DataPickerManager : NSObject <UIPickerViewDelegate,UIPickerViewDataSource>
@property UIPickerView *pv;
@property UITextField *dataField;
@property NSMutableArray *dataSourceList;
@property NSString *dataSource;
-(void)showDataPicker:(UIViewController*)controller dataField:(UITextField*)dataField dataSource:(NSString*)dataSource sortBy:(NSString*)sortBy fiterFrom:(NSString*)fiterFrom fiterBy:(NSString*)fiterBy headerView:(UIView*)headerView;
@end
