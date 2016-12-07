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
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    AllDataViewController *advc = segue.destinationViewController;
    NSArray *segueList = @[@"unitSegue",@"itemKindSegue",@"firmKindSegue",@"custKindSegue",@"warehouseSegue"];
    NSInteger goToIndex = 9;
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
        default:
            break;
    }

}

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}


@end
