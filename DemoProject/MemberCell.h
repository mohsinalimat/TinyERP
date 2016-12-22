//
//  MemberCell.h
//  DemoProject
//
//  Created by user32 on 2016/12/22.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MemberCell : UICollectionViewCell
@property (weak, nonatomic) IBOutlet UILabel *memberIDLabel;
@property (weak, nonatomic) IBOutlet UILabel *memberNameLabel;
@property (weak, nonatomic) IBOutlet UIImageView *memberimgView;

@end
