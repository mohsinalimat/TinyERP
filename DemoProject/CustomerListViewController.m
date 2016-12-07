//
//  CustomerListViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/11.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "CustomerListViewController.h"
#import "DataBaseManager.h"
#import "CoreDataHelper.h"
#import "Partner.h"
#import "PartnerViewController.h"

@interface CustomerListViewController () <UITableViewDataSource,UITableViewDelegate>
@property (nonatomic) NSMutableArray *custList;
@end

@implementation CustomerListViewController

-(instancetype)initWithCoder:(NSCoder *)aDecoder
{
    self = [super initWithCoder:aDecoder];
    if (self)
    {
        self.custList = [[NSMutableArray alloc]init];
        self.custList = [DataBaseManager fiterFromCoreData:@"PartnerEntity" sortBy:@"partnerID" fiterFrom:@"partnerType" fiterBy:@"C"];
    }
    return self;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    self.title = @"客戶清單";
    self.custListTableView.delegate = self;
    self.custListTableView.dataSource = self;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return self.custList.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:@"custCell"];
    Partner *partner = [self.custList objectAtIndex:indexPath.row];
    NSString *title = [@"" stringByAppendingFormat:@"[%@]%@_%@",partner.partnerKind,partner.partnerID,partner.partnerName];
    cell.textLabel.text = title;
    return cell;
}

- (IBAction)addCust:(id)sender
{
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Partner *partner = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerEntity" inManagedObjectContext:helper.managedObjectContext];
    partner.partnerType = @"C";
    [self.custList insertObject:partner atIndex:0];
    [DataBaseManager updateToCoreData];
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    [self.custListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    
    PartnerViewController *pvc = [self.storyboard instantiateViewControllerWithIdentifier:@"partnerViewController"];
    pvc.thisPartner = partner;
    pvc.partnerListInDetail = self.custList;
    pvc.whereFrom = @"custList";
    pvc.delegate = self;
    [self showViewController:pvc sender:self];
}

-(void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender
{
    PartnerViewController *pvc = segue.destinationViewController;
    NSIndexPath *ip = self.custListTableView.indexPathForSelectedRow;
    //生成物件
    Partner *partner = [self.custList objectAtIndex:ip.row];
    pvc.partnerListInDetail = self.custList;
    pvc.thisPartner = partner;
    pvc.whereFrom = @"custList";
    pvc.delegate = self;
}

-(void)tableView:(UITableView *)tableView commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath
{
    if (editingStyle == UITableViewCellEditingStyleDelete)
    {
        CoreDataHelper *helper = [CoreDataHelper sharedInstance];
        Partner *partner = [self.custList objectAtIndex:indexPath.row];
        [helper.managedObjectContext deleteObject:partner];
        [self.custList removeObject:partner];
        [self.custListTableView deleteRowsAtIndexPaths:@[indexPath] withRowAnimation:UITableViewRowAnimationAutomatic];
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
    // Dispose of any resources that can be recreated.
}



@end
