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
-(void)showDataPicker:(UIViewController*)controller;
@end
