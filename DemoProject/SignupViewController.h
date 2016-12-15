//
//  SignupViewController.h
//  DemoProject
//
//  Created by user32 on 2016/12/13.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface SignupViewController : UIViewController
@property (weak, nonatomic) IBOutlet UITextField *memberIDInput;
@property (weak, nonatomic) IBOutlet UITextField *memberPWInput;
@property (weak, nonatomic) IBOutlet UITextField *memberNameInput;
@property (weak, nonatomic) IBOutlet UITextField *memberBirthdayInput;
@property (weak, nonatomic) IBOutlet UIImageView *memberImgView;
@end
