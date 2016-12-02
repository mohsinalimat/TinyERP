//
//  EditCell.m
//  DemoProject
//
//  Created by user32 on 2016/11/8.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "EditCell.h"
#import "AllDataViewController.h"

@implementation EditCell

- (void)awakeFromNib
{
    [super awakeFromNib];
    self.editCellTextView.delegate = self;
}

- (void)setSelected:(BOOL)selected animated:(BOOL)animated
{
    [super setSelected:selected animated:animated];
}

@end
