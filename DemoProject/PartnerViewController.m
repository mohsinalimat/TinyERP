//
//  PartnerViewController.m
//  DemoProject
//
//  Created by user32 on 2016/11/11.
//  Copyright © 2016年 謝騰飛. All rights reserved.
//

#import "PartnerViewController.h"
#import "DataBaseManager.h"
#import "FirmListViewController.h"
#import "CustomerListViewController.h"
#import <CoreLocation/CoreLocation.h>
#import <MapKit/MapKit.h>

@interface PartnerViewController () <UINavigationBarDelegate,CLLocationManagerDelegate>

@property (weak, nonatomic) IBOutlet UILabel *pID;
@property (weak, nonatomic) IBOutlet UILabel *pKind;
@property (weak, nonatomic) IBOutlet UILabel *pName;
@property (weak, nonatomic) IBOutlet UILabel *pFullName;
@property (weak, nonatomic) IBOutlet UILabel *pTexNum;
@property (weak, nonatomic) IBOutlet UILabel *pBoss;
@property (weak, nonatomic) IBOutlet UILabel *pTel;
@property (weak, nonatomic) IBOutlet UILabel *pAddr;

@property (weak, nonatomic) IBOutlet UITextField *pIDInput;
@property (weak, nonatomic) IBOutlet UITextField *pKindInput;
@property (weak, nonatomic) IBOutlet UITextField *pNameInput;
@property (weak, nonatomic) IBOutlet UITextField *pFullNameInput;
@property (weak, nonatomic) IBOutlet UITextField *pTexNumInput;
@property (weak, nonatomic) IBOutlet UITextField *pBossInput;
@property (weak, nonatomic) IBOutlet UITextField *pTelInput;
@property (weak, nonatomic) IBOutlet UITextView *pAddrInput;

@property (weak, nonatomic) IBOutlet UIButton *deletePartnerButton;
@property (weak, nonatomic) IBOutlet UILabel *isSameID;
@property (nonatomic) FirmListViewController *flvc;
@property (nonatomic) CustomerListViewController *clvc;

@property (nonatomic) BOOL isCreateStatus;
@property (nonatomic) BOOL isCreataAgain;

@property (nonatomic) NSString *currentCoordinateString;

@end

@implementation PartnerViewController
{
    CLLocationManager *locationManager;
}

- (void)viewDidLoad
{
    [super viewDidLoad];
    
    [self.isSameID setHidden:YES];
    self.pAddrInput.layer.borderWidth = 1;
    self.pAddrInput.layer.borderColor = self.view.tintColor.CGColor;

    if ([self.whereFrom isEqualToString:@"firmList"])
    {
        self.title = @"廠商資料";
        self.pID.text = @"廠商編號";
        self.pKind.text = @"廠商分類";
        self.pName.text = @"廠商簡稱";
        self.pFullName.text = @"廠商全名";
        self.pTexNum.text = @"廠商統編";
        self.pBoss.text = @"負責人";
        self.pTel.text = @"廠商電話";
        self.pAddr.text = @"廠商地址";
        NSArray *naviArray = [self.navigationController viewControllers];
        NSInteger thisIndex = [naviArray indexOfObject:self];
        self.flvc = [naviArray objectAtIndex:thisIndex-1];
        
    }
    else if ([self.whereFrom isEqualToString:@"custList"])
    {
        self.title = @"客戶資料";
        self.pID.text = @"客戶編號";
        self.pKind.text = @"客戶分類";
        self.pName.text = @"客戶簡稱";
        self.pFullName.text = @"客戶全名";
        self.pTexNum.text = @"客戶統編";
        self.pBoss.text = @"負責人";
        self.pTel.text = @"客戶電話";
        self.pAddr.text = @"客戶地址";
        NSArray *naviArray = [self.navigationController viewControllers];
        NSInteger thisIndex = [naviArray indexOfObject:self];
        self.clvc = [naviArray objectAtIndex:thisIndex-1];
    }
    self.pIDInput.text = self.thisPartner.partnerID;
    self.pKindInput.text = self.thisPartner.partnerKind;
    self.pNameInput.text = self.thisPartner.partnerName;
    self.pFullNameInput.text = self.thisPartner.partnerFullName;
    self.pTexNumInput.text = self.thisPartner.partnerTaxNum;
    self.pBossInput.text = self.thisPartner.partnerBoss;
    self.pTelInput.text = self.thisPartner.partnerTel;
    self.pAddrInput.text = self.thisPartner.partnerAddr;
    
    if (self.pIDInput.text.length==0 && self.pNameInput.text.length==0)
    {
        [self.navigationItem setHidesBackButton:YES animated:YES];
        [self.deletePartnerButton setTitle:@"放棄新增" forState:UIControlStateNormal];
        self.isCreateStatus = YES;
    }
    
    locationManager=[[CLLocationManager alloc]init];
    if([locationManager respondsToSelector:@selector(requestWhenInUseAuthorization)])
    {
        [locationManager requestWhenInUseAuthorization];
    }
    locationManager.desiredAccuracy = kCLLocationAccuracyBest;
    locationManager.activityType = CLActivityTypeAutomotiveNavigation;
    locationManager.delegate = self;
    [locationManager startUpdatingLocation];
}

-(void)saveValue
{
    self.thisPartner.partnerID = self.pIDInput.text;
    self.thisPartner.partnerKind = self.pKindInput.text;
    self.thisPartner.partnerName = self.pNameInput.text;
    self.thisPartner.partnerFullName = self.pFullNameInput.text;
    self.thisPartner.partnerTaxNum = self.pTexNumInput.text;
    self.thisPartner.partnerBoss = self.pBossInput.text;
    self.thisPartner.partnerTel = self.pTelInput.text;
    self.thisPartner.partnerAddr = self.pAddrInput.text;
    [DataBaseManager updateToCoreData];
}

- (IBAction)savePartner:(id)sender
{
    [self saveValue];
    //先判斷來源
    if ([self.whereFrom isEqualToString:@"firmList"])
    {
        //看有無新增多筆
        if (self.isCreataAgain == YES)
        {
            [self.flvc.firmListTableView reloadData];
        }
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.partnerListInDetail indexOfObject:self.thisPartner] inSection:0];
        [self.flvc.firmListTableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([self.whereFrom isEqualToString:@"custList"])
    {
        if (self.isCreataAgain == YES)
        {
            [self.clvc.custListTableView reloadData];
        }
        NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.partnerListInDetail indexOfObject:self.thisPartner] inSection:0];
        [self.clvc.custListTableView reloadRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)saveAndCreatePartner:(id)sender
{
    //存值並寫DB
    [self saveValue];
    [DataBaseManager updateToCoreData];
    //建立新的物件
    CoreDataHelper *helper = [CoreDataHelper sharedInstance];
    Partner *partner = [NSEntityDescription insertNewObjectForEntityForName:@"PartnerEntity" inManagedObjectContext:helper.managedObjectContext];
    //塞到陣列
    [self.partnerListInDetail insertObject:partner atIndex:0];
    //新增到前一頁TV
    NSIndexPath *ip = [NSIndexPath indexPathForRow:0 inSection:0];
    if ([self.whereFrom isEqualToString:@"firmList"])
    {
        [self.flvc.firmListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([self.whereFrom isEqualToString:@"custList"])
    {
        [self.clvc.custListTableView insertRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    //新物件指定為當前物件
    self.thisPartner = partner;
    //清空畫面
    self.pIDInput.text = @"";
    self.pNameInput.text = @"";
    self.pFullNameInput.text = @"";
    self.pKindInput.text = @"";
    self.pTexNumInput.text = @"";
    self.pBossInput.text = @"";
    self.pTelInput.text = @"";
    self.pAddrInput.text = @"";
    //新增多筆為是
    self.isCreataAgain = YES;
}

- (IBAction)deletePartner:(id)sender
{
    NSIndexPath *ip = [NSIndexPath indexPathForRow:[self.partnerListInDetail indexOfObject:self.thisPartner] inSection:0];
    [DataBaseManager deleteDataAndObject:self.thisPartner array:self.partnerListInDetail];
    if ([self.whereFrom isEqualToString:@"firmList"])
    {
        [self.flvc.firmListTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    else if ([self.whereFrom isEqualToString:@"custList"])
    {
        [self.clvc.custListTableView deleteRowsAtIndexPaths:@[ip] withRowAnimation:UITableViewRowAnimationAutomatic];
    }
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)backRootView:(id)sender
{
    if (self.isCreateStatus == YES)
    {
        [DataBaseManager deleteDataAndObject:self.thisPartner array:self.partnerListInDetail];
    }
    [self.navigationController popToRootViewControllerAnimated:YES];
}

- (IBAction)gesturePop:(id)sender
{
    [self.navigationController popViewControllerAnimated:YES];
}

- (IBAction)phoneCell:(id)sender
{
    NSMutableString * telStr=[[NSMutableString alloc] initWithFormat:@"tel:%@",self.pTelInput.text];
    UIWebView * callWebview = [[UIWebView alloc] init];
    [callWebview loadRequest:[NSURLRequest requestWithURL:[NSURL URLWithString:telStr]]];
    [self.view addSubview:callWebview];
}

-(void)locationManager:(CLLocationManager *)manager didUpdateLocations:(NSArray<CLLocation *> *)locations
{
    //取得"陣列裡"最新的位置
    CLLocation *currentLocation = locations.lastObject;
    self.currentCoordinateString = [NSString stringWithFormat:@"%.6f,%.6f",currentLocation.coordinate.latitude,currentLocation.coordinate.longitude];
    NSLog(@"%@",self.currentCoordinateString);
}

- (IBAction)goToMap:(id)sender
{
    NSString *oneLineAddressString = [self.pAddrInput.text stringByReplacingOccurrencesOfString:@"\n" withString:@""];
    //去除掉首尾的空白字符和换行字符
    //[headerData stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([[UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"comgooglemaps://"]])
    {
        NSString *googleMapURLString = [NSString stringWithFormat:@"comgooglemaps://?saddr=%@&daddr=%@",self.currentCoordinateString,oneLineAddressString];
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:[googleMapURLString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]]];
    }
    else
    {
        CLGeocoder *geoclderForApple = [[CLGeocoder alloc]init];
        [geoclderForApple geocodeAddressString:oneLineAddressString completionHandler:
         //異步執行1.需連網查Apple DB 2.需等待
         ^(NSArray<CLPlacemark*>* _Nullable placemarks, NSError* _Nullable error)
         {
             if(error)
             {
                 NSLog(@"%@",error);
                 return ;
             }
             
             CLPlacemark *targetPlacemark = placemarks.firstObject;
             //因為要用地圖 所以把CL的轉成MK
             MKPlacemark *targetPlace = [[MKPlacemark alloc ]initWithPlacemark:targetPlacemark];
             MKMapItem *targetMapItem = [[MKMapItem alloc]initWithPlacemark:targetPlace];
             
             //導航模式參數
             NSDictionary *options = @{MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving};
             
             //請AppleMap導航(由現在位置到目標位置)
             [targetMapItem openInMapsWithLaunchOptions:options];
         }];
    }
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
}

@end
