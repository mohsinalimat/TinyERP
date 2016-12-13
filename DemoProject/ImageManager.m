//
//  ImageManager.m
//  DemoProject
//
//  Created by user32 on 2016/12/13.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "ImageManager.h"
#import "AlertManager.h"

@implementation ImageManager

-(instancetype)init
{
    if (self)
    {
        [[NSNotificationCenter defaultCenter]addObserverForName:@"deleteImgYes" object:nil queue:nil usingBlock:^(NSNotification * _Nonnull note)
         {
             self.imageView.image = nil;
         }];
    }
    return self;
}

-(void)getImageByAlbum
{
    //產生物件
    UIImagePickerController *pickerCtrl = [[UIImagePickerController alloc]init];
    //指定類型為抓圖庫
    pickerCtrl.sourceType = UIImagePickerControllerSourceTypePhotoLibrary;
    //代理
    pickerCtrl.delegate = self.vc;
    //秀挑照畫面
    [self.vc presentViewController:pickerCtrl animated:YES completion:nil];
}

-(void)getImageByCamera
{
    //產生物件
    UIImagePickerController *pickerCtrl = [[UIImagePickerController alloc]init];
    //指定類型為抓相機
    pickerCtrl.sourceType = UIImagePickerControllerSourceTypeCamera;
    pickerCtrl.cameraDevice = UIImagePickerControllerCameraDeviceRear;
    pickerCtrl.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
    //代理
    pickerCtrl.delegate = self.vc;
    //秀挑照畫面
    [self.vc presentViewController:pickerCtrl animated:YES completion:nil];
}

-(void)putImage
{
    //得到圖片
    UIImage *image = self.imageInfo[UIImagePickerControllerOriginalImage];
    //放到相框
    self.imageView.image = image;
    //關掉挑照畫面
    [self.vc dismissViewControllerAnimated:YES completion:nil];
}

-(void)deleteImage
{
    [AlertManager alertYesAndNo:@"是否確定刪除圖片" yes:@"是" no:@"否" controller:self.vc postNotificationName:@"deleteImg"];
}

@end
