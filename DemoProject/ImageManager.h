//
//  ImageManager.h
//  DemoProject
//
//  Created by user32 on 2016/12/13.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface ImageManager : NSObject
@property UIViewController *vc;
@property UIImageView *imageView;
-(void)getImageByAlbum;
-(void)getImageByCamera;
-(void)deleteImage;
@end
