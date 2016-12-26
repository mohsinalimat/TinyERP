//
//  BasicDataViewController.m
//  DemoProject
//
//  Created by user32 on 2016/10/31.
//  Copyright © 2016年 user32. All rights reserved.
//

#import "BasicDataViewController.h"
#import "AllDataViewController.h"

@interface BasicDataViewController ()

@end

@implementation BasicDataViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    self.title = @"基本資料";
    UISwipeGestureRecognizer *swipeGesture = [[UISwipeGestureRecognizer alloc]initWithTarget:self action:@selector(gesturePop)];
    swipeGesture.direction = UISwipeGestureRecognizerDirectionRight;
    [self.view addGestureRecognizer:swipeGesture];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AllDataViewController *advc = segue.destinationViewController;
    NSArray *segueList = @[@"unitSegue",@"itemKindSegue",@"firmKindSegue",@"custKindSegue",@"warehouseSegue",@"inventoryReasonSegue",@"bankAccountSegue",@"fianceReasonSegue"];
    NSInteger goToIndex = 999;
    NSString *temp;
    for (temp in segueList)
    {
        if ([segue.identifier isEqualToString:temp])
        {
            goToIndex = [segueList indexOfObject:temp];
        }
    }
    switch (goToIndex)
    {
        case 0:
            advc.whereFrom = @"單位";
            break;
        case 1:
            advc.whereFrom = @"商品分類";
            break;
        case 2:
            advc.whereFrom = @"廠商分類";
            break;
        case 3:
            advc.whereFrom = @"客戶分類";
            break;
        case 4:
            advc.whereFrom = @"倉庫";
            break;
        case 5:
            advc.whereFrom = @"異動理由";
            break;
        case 6:
            advc.whereFrom = @"銀行帳號";
            break;
        case 7:
            advc.whereFrom = @"財務理由";
            break;
        default:
            break;
    }

}

- (void)gesturePop
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
