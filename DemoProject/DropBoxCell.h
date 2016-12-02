//
//  DropBoxCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/30.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DropBoxCell : UITableViewCell
@property (weak, nonatomic) IBOutlet UIButton *dbBackupIcon;
@property (weak, nonatomic) IBOutlet UIButton *dbBackupButton;
@property (weak, nonatomic) IBOutlet UIButton *dbRestoreIcon;
@property (weak, nonatomic) IBOutlet UIButton *dbRestoreButton;
@property (weak, nonatomic) IBOutlet UIButton *dbLogoutButton;
@end
