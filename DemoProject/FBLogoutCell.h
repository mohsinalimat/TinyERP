//
//  FBLogoutCell.h
//  DemoProject
//
//  Created by user32 on 2016/11/28.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <FBSDKCoreKit/FBSDKCoreKit.h>
#import <FBSDKLoginKit/FBSDKLoginKit.h>

@interface FBLogoutCell : UITableViewCell
@property (weak, nonatomic) IBOutlet FBSDKLoginButton *fbLogoutButton;

@end
