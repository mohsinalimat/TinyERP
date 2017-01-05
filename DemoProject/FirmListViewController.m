//
//  FirmListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/11.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "FirmListViewController.h"
#import "DataBaseManager.h"
#import "Partner.h"
#import "CoreDataHelper.h"
#import "PartnerViewController.h"

@interface FirmListViewController () <UITextViewDelegate,UITableViewDataSource>
@property (nonatomic) NSMutableArray *firmList;
@end

@implementation FirmListViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        //初始化陣列
        self.firmList = [[NSMutableArray alloc]init];
        //根據ID排序
        self.firmList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"F"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"廠商清單";
    self.firmListTableView.delegate = self;
    self.firmListTableView.dataSource = self;
}

-(void)viewWillAppear:(BOOL)animated
{
    [self.firmListTableView reloadData];
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.firmList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"firmCell"];
    Partner *partner = [self.firmList objectAtIndex:indexPath.row];
    NSString *title = [@"" stringByAppendingFormat:@"[%@]%@_%@",partner.partnerKind,partner.partnerID,partner.partnerName];
    cell.textLabel.text = title;
    return cell;
}

- (IBAction)addFirm:(id)sender
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Partner *partner = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerEntity" inManagedObjectContext:helper.managedObjectContext];
    partner.partnerType = @"F";
    [self.firmList insertObject:partner atIndex:0];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.firmListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
//    [DataBaseManager updateToCoreData];
    
    PartnerViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"partnerViewController"];
    pvc.thisPartner = partner;
    pvc.partnerListInDetail = self.firmList;
    pvc.whereFrom = @"firmList";
    pvc.delegate = self;
    [self showViewController:pvc sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PartnerViewController *pvc = segue.destinationViewController;
    NSIndexPath *ip = self.firmListTableView.indexPathForSelectedRow;
    //生成物件
    Partner *partner = [self.firmList objectAtIndex:ip.row];
    pvc.partnerListInDetail = self.firmList;
    pvc.thisPartner = partner;
    pvc.whereFrom = @"firmList";
    pvc.delegate = self;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Partner *partner = [self.firmList objectAtIndex:indexPath.row];
        [helper.managedObjectContext deleteObject:partner];
        [self.firmList removeObject:partner];
        [self.firmListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
        [DataBaseManager updateToCoreData];
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
