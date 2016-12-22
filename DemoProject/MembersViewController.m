//
//  MembersViewController.m
//  DemoProject
//
//  Created by user32 on 2016/12/22.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "MembersViewController.h"
#import "DataBaseManager.h"
#import "Member.h"
#import "MemberCell.h"

@interface MembersViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property NSArray *memberClassList;
@property NSMutableArray *memberApprovedYesList;
@property NSMutableArray *memberApprovedNoList;
@property NSMutableArray *memberApprovedYes2DList;
@property NSMutableArray *memberApprovedNo2DList;
@property BOOL isShowApporvedMember;
@end

@implementation MembersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //代理
    self.membersCollectionView.delegate = self;
    self.membersCollectionView.dataSource = self;
    self.memberClassList = @[@"店長",@"店員",@"財務",@"未分類"];
    self.memberApprovedYes2DList = [NSMutableArray new];
    self.memberApprovedNo2DList = [NSMutableArray new];
    self.isShowApporvedMember = NO;
    [self classifyMember];
}

-(void)classifyMember
{
    //先分已審未審
    self.memberApprovedYesList = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberApproed" fiterBy:@"Yes"];
    self.memberApprovedNoList = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberApproed" fiterBy:@"No"];
    //再根據類別區分,組二維陣列
    for (Member *yesMember in self.memberApprovedYesList)
    {
        NSMutableArray *classArray = [NSMutableArray new];
        for (NSString *class in self.memberClassList)
        {
            if ([yesMember.memberClass isEqualToString:class])
            {
                [classArray addObject:yesMember];
            }
        }
        [self.memberApprovedYes2DList addObject:classArray];
    }
    for (Member *noMember in self.memberApprovedNoList)
    {
        NSMutableArray *classArray = [NSMutableArray new];
        for (NSString *class in self.memberClassList)
        {
            if ([noMember.memberClass isEqualToString:class])
            {
                [classArray addObject:noMember];
            }
        }
        [self.memberApprovedNo2DList addObject:classArray];
    }
}

-(NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return self.memberClassList.count;
//    return 1;
}

-(NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    if (self.isShowApporvedMember==YES)
    {
        NSArray *classArray = self.memberApprovedYes2DList[section];
        return classArray.count;
    }
    else if (self.isShowApporvedMember==NO)
    {
        NSArray *classArray = self.memberApprovedNo2DList[section];
        return classArray.count;
    }
    return 0;
}

-(UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    Member *member;
    NSArray *classArray;
    if (self.isShowApporvedMember==YES)
    {
        classArray = self.memberApprovedYes2DList[indexPath.section];
        member = classArray[indexPath.row];
    }
    else if (self.isShowApporvedMember==NO)
    {
        classArray = self.memberApprovedNo2DList[indexPath.section];
        member = classArray[indexPath.row];
    }
    MemberCell *mCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"memberCell" forIndexPath:indexPath];
    mCell.memberIDLabel.text = member.memberID;
    mCell.memberNameLabel.text = member.memberName;
    mCell.memberimgView.image = [UIImage imageWithData:member.memberImg];
    mCell.layer.borderWidth = 1;
    return mCell;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    return CGSizeMake(75, 75);
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

- (IBAction)isShowApporvedMember:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.isShowApporvedMember = NO;
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        self.isShowApporvedMember = YES;
    }
    
}

- (IBAction)membersCellSizeChange:(id)sender
{
    
}

- (IBAction)changeAdmin:(id)sender
{
    
}

@end
