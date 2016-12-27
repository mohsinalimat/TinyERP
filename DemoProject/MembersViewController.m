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
#import "AppDelegate.h"

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
@property CGFloat cellWidth;
@property CGFloat cellHeight;
@property CGFloat cellSizeRatio;
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
    self.cellWidth = 80;
    self.cellHeight = self.cellWidth+40;
    self.cellSizeRatio = 1.0;
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(setAdmin) name:@"setAdminYes" object:nil];
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(popVC) name:@"popVC" object:nil];
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
    if ([member.memberType isEqualToString:@"FaceBook"])
    {
        mCell.memberIDLabel.text = @"FB使用者";
    }
    mCell.memberNameLabel.text = member.memberName;
    mCell.memberimgView.image = [UIImage imageWithData:member.memberImg];
    
    CGRect rect = mCell.memberimgView.frame;
    rect.size.width = self.cellWidth;
    mCell.memberimgView.frame = rect;
    
    mCell.layer.borderWidth = 1;
    return mCell;
}

-(UICollectionReusableView *)collectionView:(UICollectionView *)collectionView viewForSupplementaryElementOfKind:(NSString *)kind atIndexPath:(NSIndexPath *)indexPath
{
    CollectionReusableViewWithTitle *headerView = [collectionView dequeueReusableSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:@"collectionHeader" forIndexPath:indexPath];
    headerView.backgroundColor = [UIColor colorWithRed:0.2 green:1 blue:1 alpha:1];
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
    CGFloat myCellWidth = self.cellWidth*self.cellSizeRatio;
    CGFloat myCellHeight = myCellWidth + 40;
    return CGSizeMake(myCellWidth, myCellHeight);
}

//間距
- (CGFloat)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout*)collectionViewLayout minimumInteritemSpacingForSectionAtIndex:(NSInteger)section
{
    return 1;
}

-(void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedMemberList addObject:[self getMember:indexPath]];
    MemberCell *cell = (MemberCell*)[self.membersCollectionView cellForItemAtIndexPath:indexPath];
    cell.selectedView.alpha = 0.5;
}

-(void)collectionView:(UICollectionView *)collectionView didDeselectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [self.selectedMemberList removeObject:[self getMember:indexPath]];
    MemberCell *cell = (MemberCell*)[self.membersCollectionView cellForItemAtIndexPath:indexPath];
    cell.selectedView.alpha = 0.0;
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
    if (self.isShowApporvedMember)
    {
        [self clearSelected:self.memberApprovedYes2DList];
    }
    else
    {
        [self clearSelected:self.memberApprovedNo2DList];
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
        //清空已選cell
        [self clearSelected:self.memberApprovedYes2DList];
    }
    else if (sender.selectedSegmentIndex == 1)
    {
        self.isShowApporvedMember = YES;
        [self.changeAppovedButton setTitle:@"停用" forState:UIControlStateNormal];
        [self clearSelected:self.memberApprovedNo2DList];
    }
    self.selectedMemberList = [NSMutableArray array];
    [self.membersCollectionView reloadData];
}

-(void)clearSelected:(NSMutableArray*)array
{
    for (NSArray *classArray in array)
    {
        for (NSUInteger rowIndex=0; rowIndex<classArray.count; rowIndex++)
        {
            MemberCell *cell = (MemberCell*)[self.membersCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:[array indexOfObject:classArray]]];
            cell.selected = NO;
            cell.selectedView.alpha = 0.0;
        }
    }
}

- (IBAction)reverseSelect:(id)sender
{
    if (self.isShowApporvedMember)
    {
        for (NSArray *classArray in self.memberApprovedYes2DList)
        {
            for (NSUInteger rowIndex=0; rowIndex<classArray.count; rowIndex++)
            {
                MemberCell *cell = (MemberCell*)[self.membersCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:[self.memberApprovedYes2DList indexOfObject:classArray]]];
                [self reverse:cell];
            }
        }
    }
    else
    {
        for (NSArray *classArray in self.memberApprovedNo2DList)
        {
            for (NSUInteger rowIndex=0; rowIndex<classArray.count; rowIndex++)
            {
                MemberCell *cell = (MemberCell*)
                [self.membersCollectionView cellForItemAtIndexPath:[NSIndexPath indexPathForRow:rowIndex inSection:[self.memberApprovedNo2DList indexOfObject:classArray]]];
                [self reverse:cell];
            }
        }
    }
}

-(MemberCell*)reverse:(MemberCell*)cell
{
    if (cell.selected)
    {
        [self.selectedMemberList removeObject:[self getMember:[self.membersCollectionView indexPathForCell:cell]]];
        cell.selected = NO;
        cell.selectedView.alpha = 0.0;
    }
    else
    {
        [self.selectedMemberList addObject:[self getMember:[self.membersCollectionView indexPathForCell:cell]]];
        cell.selected = YES;
        cell.selectedView.alpha = 0.5;
    }
    return cell;
}

- (IBAction)membersCellSizeChange:(UISlider*)sender
{
    //起值為1,五段變速
    if (((sender.value+1)-self.cellSizeRatio>0.2) || (self.cellSizeRatio-(sender.value+1)>0.2))
    {
        self.cellSizeRatio = sender.value+1;
        [self.membersCollectionView reloadData];
    }
}

- (IBAction)changeAdmin:(id)sender
{
    if (self.selectedMemberList.count==0)
    {
        [AlertManager alert:@"請先選擇使用者" controller:self];
    }
    else if (self.selectedMemberList.count>1)
    {
        [AlertManager alert:@"選取超過一人" controller:self];
    }
    else if (self.selectedMemberList.count==1)
    {
        Member *theMember = self.selectedMemberList.firstObject;
        if (theMember.memberApproved == NO)
        {
            [AlertManager alert:@"已審核使用者才可成為管理員" controller:self];
        }
        else
        {
            [AlertManager alertYesAndNo:@"請確認是否將管理員權限轉移" yes:@"是" no:@"否" controller:self postNotificationName:@"setAdmin"];
        }
    }
}

-(void)setAdmin
{
    AppDelegate *appDLG = (AppDelegate*)[UIApplication sharedApplication].delegate;
    Member *currentMember = appDLG.currentMember;
    currentMember.memberClass = @"未分類";
    Member *adminMember = self.selectedMemberList.firstObject;
    adminMember.memberClass = @"admin";
    [DataBaseManager updateToCoreData];
    [AlertManager alertWithoutButton:@"修改完成" controller:self time:0.5 action:@"popVC"];
}

-(void)popVC
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
