//
//  ViewController.m
//  UITableView Parallax
//
//  Created by Hank on 2015/8/10.
//  Copyright (c) 2015年 Hank. All rights reserved.
//

#import "HomePageViewController.h"
#import "ParallaxTableViewCell.h"
#import "MJRefresh.h"
#import "AppDelegate.h"
#import "Reachability.h"
#import "TWMessageBarManager.h"

@interface HomePageViewController ()
{
    NSMutableArray *arrayDatas;
    Reachability *serverReach;
}
@property (weak, nonatomic) IBOutlet UITableView *tableView;
@end

@implementation HomePageViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    _tableView.delegate=self;
    _tableView.dataSource=self;
    
    
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[CustomAnimationImageView alloc] initWithFrame:CGRectMake(0, 0, 64,64)];
    hud.labelText = @"Loading...";
    
    dispatch_queue_t loadingQueue = dispatch_queue_create("HomePageLoading", nil);
    dispatch_async(loadingQueue, ^{
        [self getdata];
        [[PFUser currentUser] fetchIfNeeded];
        dispatch_async(dispatch_get_main_queue(), ^{
            [_tableView reloadData];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    self.navigationItem.backBarButtonItem =[[UIBarButtonItem alloc] initWithTitle:@"" style:UIBarButtonItemStylePlain target:nil action:nil];
    
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector
    (jumpToWallTableviewCell:) name:JUMP_TO_WallTableviewCell object:nil];

    
    // Prepare Rechability
    //使用NSNotificationCenter來通知網路狀態改變
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(networkStatusChanged:) name:kReachabilityChangedNotification object:nil];
    
    serverReach = [Reachability reachabilityWithHostName:@"www.parse.com"];
    [serverReach startNotifier];
    
    
 
}

-(void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.navigationController.navigationBar.hidden = YES;
    //關閉分隔線
    [_tableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];

    
    if(arrayDatas.count==0){
        
        dispatch_queue_t loadingQueue = dispatch_queue_create("HomePageLoading2", nil);
        dispatch_async(loadingQueue, ^{
            [self getdata];
            dispatch_async(dispatch_get_main_queue(), ^{
                [_tableView reloadData];
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    }
    

}

// 判斷網路是否存在
-(void) networkStatusChanged:(NSNotification*)notify{
    NetworkStatus status = [serverReach currentReachabilityStatus];
    if(status == NotReachable)
    {
        //斷線
        //NSLog(@"Not Reachable.");
        [[TWMessageBarManager sharedInstance]
         showMessageWithTitle:@"TravelWithMe" //標頭
         description:@"無法連線上網,請檢查您的網路唷！" //內容
         type:TWMessageBarMessageTypeInfo // 主題(底層有三種效果＆顏色自訂)
         duration:600.0]; // 秒數
    }
    else{
        //連線
        //NSLog(@"Reach with: %ld",status);
        [self update];
        [[TWMessageBarManager sharedInstance] hideAllAnimated:YES];
        
    }
    
}
// 如果網路重整時
-(void) update{
    
    if([serverReach currentReachabilityStatus] == NotReachable){
        // Remin User ... etc
        return;
    }
}
// 停止接收



- (void) jumpToWallTableviewCell:(NSNotification*) notify {
    [self performSegueWithIdentifier:@"4ni2" sender:nil];
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}


-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return arrayDatas.count;
}

-(UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    static NSString *cellIdentifier =@"loactionCell";
    ParallaxTableViewCell *cell =[tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.titleLabel.text = arrayDatas[indexPath.row][@"title"];
    cell.subtitleLabel.text = arrayDatas[indexPath.row][@"subTitle"];
    
    int randomNum = (arc4random()%7)+1;
    
    //照片
    PFFile *photo = (PFFile *)[[arrayDatas objectAtIndex:indexPath.row] objectForKey:@"image"];
    [cell.parallaxImage sd_setImageWithURL:(NSURL*)photo.url placeholderImage:[UIImage imageNamed:[NSString stringWithFormat:@"demo_%d",randomNum]]];
    
    return cell;
}

-(void)scrollViewDidScroll:(UIScrollView *)scrollView{
    NSArray *visibleCells = [self.tableView visibleCells];
    for (ParallaxTableViewCell*cell in visibleCells){
        [cell cellOnTableView:self.tableView didScrollOnView:self.view];
    
    
    }
    
}


#pragma mark - Load Parse Data

- (void) getdata
{
    PFQuery *query = [PFQuery queryWithClassName:@"HomePage"];
    [query orderByAscending:@"sort"];
    //query.limit = 3;
    
    arrayDatas = [[NSMutableArray alloc] initWithArray:[query findObjects]];
}
-(void)dealloc
{
    [[NSNotificationCenter defaultCenter] removeObserver:self forKeyPath:JUMP_TO_WallTableviewCell];
    [[NSNotificationCenter defaultCenter]removeObserver:self name:kReachabilityChangedNotification object:nil];
    
    [serverReach stopNotifier];
}

@end
