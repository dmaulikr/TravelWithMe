//
//  LegalViewController.m
//  TravelWithMe
//
//  Created by Hank on 2015/8/21.
//  Copyright (c) 2015年 Jesse. All rights reserved.
//

#import "LegalViewController.h"

@interface LegalViewController ()
{
    NSArray *legaltextviewAry;
}
@property (weak, nonatomic) IBOutlet UITextView *legalTextview;

@end

@implementation LegalViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    // loading 寫法
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.mode = MBProgressHUDModeCustomView;
    hud.customView = [[CustomAnimationImageView alloc] initWithFrame:CGRectMake(0, 0, 64,64)];
    hud.labelText = @"Loading...";
    
    dispatch_queue_t loadingQueue = dispatch_queue_create("loading", nil);
    dispatch_async(loadingQueue, ^{
        [self getdata];
        dispatch_async(dispatch_get_main_queue(), ^{
            _legalTextview.text = legaltextviewAry[0][@"Text"];
            [MBProgressHUD hideHUDForView:self.view animated:YES];
        });
    });
    
    // Textview 遮罩
    _legalTextview.layer.cornerRadius =_legalTextview.frame.size.width / 90;
    // 邊框粗細
    _legalTextview.layer.borderWidth = 1.0f;
    // 邊框顏色
    _legalTextview.layer.borderColor = [UIColor colorWithRed:1.0 green:1.0 blue:1.0 alpha:1.0].CGColor;
    //_policyTextview.clipsToBounds = YES;
    
    
    
}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}
#pragma mark - Load Parse Data

// 讀Parse資料
- (void) getdata{
    
    //@"Legal" Parse 資料庫Name
    PFQuery *policytext = [PFQuery queryWithClassName:@"Legal"];
    
    legaltextviewAry = [[NSArray alloc] initWithArray:[policytext findObjects]];
    
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */

// 建立一個返回方法
- (IBAction)backBtnPressed:(id)sender {
    [self dismissViewControllerAnimated:true completion:nil];
}
@end
