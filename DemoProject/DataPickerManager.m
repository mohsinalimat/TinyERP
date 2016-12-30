//
//  DataPickerManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/30.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "DataPickerManager.h"

@implementation DataPickerManager

//-(instancetype)init
//{
//    
//    return self;
//}

-(void)showDataPicker:(UIViewController*)controller
{
    CGFloat vcWidth = controller.view.frame.size.width;
    CGFloat vcHeight = controller.view.frame.size.height;
    self.pv = [[UIPickerView alloc]initWithFrame:CGRectMake(0, vcHeight/2, vcWidth, vcHeight/3)];
    self.pv.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
    self.pv.delegate = self;
    [controller.view addSubview:self.pv];
}

-(NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

-(NSInteger)pickerView:(UIPickerView *)pickerView numberOfRowsInComponent:(NSInteger)component
{
    return 5;
}

-(NSString *)pickerView:(UIPickerView *)pickerView titleForRow:(NSInteger)row forComponent:(NSInteger)component
{
    NSString *rowIndex = [NSString stringWithFormat:@"%ld",row];
    return rowIndex;
}

-(void)pickerView:(UIPickerView *)pickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    NSLog(@"%ld",row);
}


@end
