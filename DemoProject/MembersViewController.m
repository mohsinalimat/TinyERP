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
#import "CollectionReusableViewWithTitle.h"
#import "AlertManager.h"

@interface MembersViewController () <UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout>
@property (weak, nonatomic) IBOutlet UICollectionView *membersCollectionView;
@property (weak, nonatomic) IBOutlet UIButton *changeAppovedButton;

@property NSArray *memberClassList;
@property NSMutableArray *memberApprovedYesList;
@property NSMutableArray *memberApprovedNoList;
@property NSMutableArray *memberApprovedYes2DList;
@property NSMutableArray *memberApprovedNo2DList;
@property NSMutableArray *selectedMemberList;
@property BOOL isShowApporvedMember;
@end

@implementation MembersViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
    //代理
    self.membersCollectionView.delegate = self;
    self.membersCollectionView.dataSource = self;
    self.membersCollectionView.allowsMultipleSelection = YES;
    self.memberClassList = @[@"店長",@"店員",@"財務",@"未分類"];
    self.selectedMemberList = [NSMutableArray new];
    self.isShowApporvedMember = NO;
    [self.changeAppovedButton setTitle:@"啟用" forState:UIControlStateNormal];
    [self classifyMember];
}

-(void)classifyMember
{
    self.memberApprovedYes2DList = [NSMutableArray new];
    self.memberApprovedNo2DList = [NSMutableArray new];
    //先分已審未審
    self.memberApprovedYesList = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberApproed" fiterBy:@"Yes"];
    self.memberApprovedNoList = [DataBaseManager fiterFromCoreData:@"MemberEntity" sortBy:@"memberID" fiterFrom:@"memberApproed" fiterBy:@"No"];
    //再根據類別區分,組二維陣列
    for (NSString *class in self.memberClassList)
    {
        NSMutableArray *classArray = [NSMutableArray new];
        for (Member *yesMember in self.memberApprovedYesList)
        {
            if ([yesMember.memberClass isEqualToString:class])
            {
                [classArray addObject:yesMember];
            }
        }
        [self.memberApprovedYes2DList addObject:classArray];
    }
    for (NSString *class in self.memberClassList)
    {
        NSMutableArray *classArray = [NSMutableArray new];
        for (Member *noMember in self.memberApprovedNoList)
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
    Member *member = [self getMember:indexPath];
    MemberCell *mCell = [collectionView dequeueReusableCellWithReuseIdentifier:@"memberCell" forIndexPath:indexPath];
    mCell.memberIDLabel.text = member.memberID;
    mCell.memberNameLabel.text = member.memberName;
    mCell.memberimgView.image = [UIImage imageWithData:member.memberImg];
    mCell.layer.borderWidth = 1;
    return mCell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionReusableViewWithTitle *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor yellowColor];
    headerView.title.text = self.memberClassList[indexPath.section];
    return headerView;
}

//Header大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section
{
    //寬度不管設多寬都比照superview
    CGSize size={0,22};
    return size;
}

- (CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath
{
    //1.圖片正方形
    //2.上下文字標籤高度固定
    //3.圖片跟cell等寬
    return CGSizeMake(80, 120);
}

//間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedMemberList addObject:[self getMember:indexPath]];
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedMemberList removeObject:[self getMember:indexPath]];
}

-(Member*)getMember:(NSIndexPath*)indexPath
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
    return member;
}

- (IBAction)changeAppoved:(id)sender
{
    for (Member *member in self.selectedMemberList)
    {
        if (self.isShowApporvedMember)
        {
            member.memberApproved = NO;
        }
        else
        {
            member.memberApproved = YES;
        }
    }
    [DataBaseManager updateToCoreData];
    [self classifyMember];
    [self.membersCollectionView reloadData];
    self.selectedMemberList = [NSMutableArray array];
}

- (IBAction)isShowApporvedMember:(UISegmentedControl*)sender
{
    if (sender.selectedSegmentIndex == 0)
    {
        self.isShowApporvedMember = NO;
        [self.changeAppovedButton setTitle:@"啟用" forState:UIControlStateNormal];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        self.isShowApporvedMember = YES;
        [self.changeAppovedButton setTitle:@"停用" forState:UIControlStateNormal];
    }
    [self.membersCollectionView reloadData];
}

- (IBAction)reverseSelect:(id)sender
{
    
}

- (IBAction)membersCellSizeChange:(id)sender
{
    
}

- (IBAction)changeAdmin:(id)sender
{
    
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
