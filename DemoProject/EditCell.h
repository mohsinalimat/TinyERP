//
//  EditCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/8.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface EditCell : UITableViewCell <UITextViewDelegate>
@property (weak, nonatomic) IBOutlet UITextView *editCellTextView;
@end
