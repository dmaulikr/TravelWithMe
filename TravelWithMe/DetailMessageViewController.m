//
//  DetailMessageViewController.m
//  TravelWithMe
//
//  Created by Jesselin on 2015/8/9.
//  Copyright (c) 2015年 Jesse. All rights reserved.
//

#import "DetailMessageViewController.h"
#import "UIColors.h"
#import "JLTableViewCell.h"
#import "JL2TableViewCell.h"
#import "JL3MessageTableViewCell.h"
#import "ParallaxHeaderView.h"
#import "IHKeyboardAvoiding.h"
#import "UIImage+ImageEffects.h"
#import "SSBouncyButton.h"

@interface DetailMessageViewController () <UITableViewDelegate, UITableViewDataSource, UIScrollViewDelegate, UITextFieldDelegate>
@property (weak, nonatomic) IBOutlet UITableView *detailTableView;
@end

@implementation DetailMessageViewController
{
    UIImage *headerPhoto;
    UIImage *blurImage;
    UIImageView *blurImageView;
    UIVisualEffectView *blurredView;
    ParallaxHeaderView *headerView;
    SSBouncyButton *customJoinButton;
    PFUser *user;
    NSNumber *isJoin;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    if (!user) {
        user = [PFUser currentUser];
        [[PFUser currentUser] fetchIfNeeded];
    }
    //NSLog(@"%@",_cellDictData);
    
    _detailTableView.scrollEnabled = YES;
    _detailTableView.delegate = self;
    _detailTableView.dataSource = self;

    if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
    {
        blurImage = [UIImage imageNamed:@"bg-blur-image"];
        blurImageView = [[UIImageView alloc]initWithFrame:self.view.bounds];
        blurImageView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [blurImageView setImage:[blurImage applyDarkEffect]];
    }
    else
    {
        //blur效果
        UIBlurEffect *blurEffect = [UIBlurEffect effectWithStyle:UIBlurEffectStyleLight];
        blurredView = [[UIVisualEffectView alloc]initWithEffect:blurEffect];
        blurredView.frame = self.view.bounds;
        blurredView.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
        [self.view addSubview:blurredView];
    }
    
    //手勢控制鍵盤縮放
    UITapGestureRecognizer *clickGesture = [[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(clickMethof:)];
    
    [self.view addGestureRecognizer:clickGesture];
    
    MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    hud.labelText = @"讀取中...";
    
    
    //dispatch_queue_t downloadQueue = dispatch_queue_create("Download", nil);
    //dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0)
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self getData];
    });
  
    
    //設定Navigation bar為透明
    self.navigationController.navigationBar.translucent = YES;
    //關閉分隔線
    [_detailTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    self.view.backgroundColor = [UIColor homeCellbgColor];
    self.view.opaque = NO;
    _detailTableView.backgroundColor = [UIColor homeCellbgColor];
    _detailTableView.opaque = NO;
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardHeightChange:) name:UIKeyboardWillShowNotification object:nil];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewWillDisappear:(BOOL)animated {
    [super viewWillDisappear:NO];
    [self.tabBarController.tabBar setHidden:NO];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:NO];
    [self.tabBarController.tabBar setHidden:YES];
    
}

- (void) viewWillLayoutSubviews {
    [super viewWillLayoutSubviews];
}

- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [(ParallaxHeaderView *)headerView refreshBlurViewForNewImage];
    //NSLog(@"view = %f",self.view.frame.size.height);
    //[IHKeyboardAvoiding setAvoidingView:(UIView *)self.view];
}


#pragma mark - Table View
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 3;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    if (section == 0) {
        return 1;
    } else if (section == 1){
        return 0;
    } else if (section == 2){
        return 10;
    }
    
    return 1;
}


- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
    NSString *identifier;
    NSString *nibName;
    
    if (indexPath.section == 0) {
        identifier = @"JLCell";
        nibName = @"JLTableViewCell";
    } else if (indexPath.section == 1){
        identifier = @"JL2Cell";
        nibName = @"JL2TableViewCell";
    } else if (indexPath.section == 2){
        identifier = @"JL3MessageCell";
        nibName = @"JL3MessageTableViewCell";
    }
    
    UINib *nib = [UINib nibWithNibName:nibName bundle:nil];
    
    
    [tableView registerNib:nib forCellReuseIdentifier:identifier];
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
    
    //NSLog(@"cell = %@ ,section = %ld,row = %ld",cell,indexPath.section,indexPath.row);
 
        if(indexPath.section == 0) {
            [self prepareJLCellstyle:(JLTableViewCell *)cell cellForRowAtIndexPath:indexPath];
            [self setJLCellData:(JLTableViewCell*)cell cellForRowAtIndexPath:indexPath];
            
        } else if(indexPath.section == 1) {
            [self prepareJL2Cellstyle:(JL2TableViewCell *)cell cellForRowAtIndexPath:indexPath];
            //[self setJLCellData:(JLTableViewCell*)cell cellForRowAtIndexPath:indexPath];
            
        } else if(indexPath.section == 2) {
            [self prepareJL3MessagCellstyle:(JL3MessageTableViewCell *)cell cellForRowAtIndexPath:indexPath];
        }

    return cell;
}


- (void) prepareJLCellstyle:(JLTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //點選時的顏色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //設定邊框粗細
    //[[cell.firstSectionView layer] setBorderWidth:1.5];
    
    //邊框顏色
    //[[cell.firstSectionView layer] setBorderColor:[UIColor colorWithRed:0.806 green:0.806 blue:0.806 alpha:1.0].CGColor];
    
    //設定背景顏色
    //[[cell.firstSectionView layer] setBackgroundColor:[UIColor whiteColor].CGColor];
    cell.backgroundColor = [UIColor whiteColor];
    
    //設定圓角程度
    [[cell.firstSectionView layer] setCornerRadius:5.0];
    
    //照片圓形遮罩
    cell.headPhoto.layer.cornerRadius = cell.headPhoto.frame.size.width / 2;
    cell.headPhoto.layer.borderWidth = 3.0f;
    cell.headPhoto.layer.borderColor = [UIColor boyPhotoBorderColor].CGColor;
    cell.headPhoto.clipsToBounds = YES;
    
    //參加按鈕
    if(![user.objectId isEqualToString:_cellDictData[@"userObjectId"]]) {
        if (customJoinButton==nil) {
            CGRect btnBounds = cell.joinBtn.bounds;
            if([[UIScreen mainScreen] bounds].size.height >= 667.0){
                btnBounds.origin.y = cell.frame.size.height - btnBounds.size.height - 20;
                btnBounds.size.height += 5;
                btnBounds.size.width += 5;
            }else{
                btnBounds.origin.y = cell.frame.size.height - btnBounds.size.height - 5;
            }
            
            btnBounds.origin.x = cell.frame.size.width/2 - btnBounds.size.width/2;
            //NSLog(@"height = %f",[[UIScreen mainScreen] bounds].size.height);
            // tintColor, cornerRadius
            customJoinButton = [[SSBouncyButton alloc] initWithFrame:btnBounds];
            
            customJoinButton.tintColor = [UIColor customGreenColor];
            customJoinButton.cornerRadius = 10;
            customJoinButton.titleLabel.font = [UIFont systemFontOfSize:20.0];
            [customJoinButton setTitle:@"參加" forState:UIControlStateNormal];
            [customJoinButton setTitle:@"退出" forState:UIControlStateSelected];
            [customJoinButton addTarget:self action:@selector(buttonDidPress:) forControlEvents:UIControlEventTouchUpInside];
            [cell addSubview:customJoinButton];
        }
    }
    cell.joinBtn.hidden = YES;
    if([isJoin integerValue]>0)//目前User已參加
        customJoinButton.selected = YES;
    else
        customJoinButton.selected = NO;
    //NSLog(@"what??? = %ld",[isJoin integerValue]);
}

- (void)buttonDidPress:(UIButton *)button
{
    button.selected = !button.selected;
    
    //NSLog(@"%d",button.selected);
    
    UIViewController *targetViewController;
    UIStoryboard *storyboard;
    
    if(user) {
        
        MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
        hud.labelText = @"發送中...";
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            
            PFObject *travelMatePost = [PFObject objectWithoutDataWithClassName:@"TravelMatePost" objectId:_cellDictData[@"objectId"]];
            PFRelation *userRelation = [user relationForKey:@"joinPosts"];
            PFRelation *postRelation = [travelMatePost relationForKey:@"joinUsers"];
            
            if(button.selected) { //儲存"參加"關聯
                
                
                [userRelation addObject:travelMatePost];
                [user save];
                
                [postRelation addObject:user];
                [travelMatePost save];
            
            } else { //解除"參加"關聯
                
                [userRelation removeObject:travelMatePost];
                [user save];
                
                [postRelation removeObject:user];
                [travelMatePost save];
            }
            
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [MBProgressHUD hideHUDForView:self.view animated:YES];
            });
        });
    } else {
        storyboard = [UIStoryboard storyboardWithName:@"Login" bundle:nil];
        
        targetViewController = [storyboard instantiateViewControllerWithIdentifier:@"loginViewController"];
        
        [self presentViewController:targetViewController animated:YES completion:nil];

    }
}

- (void) setJLCellData:(JLTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //大頭照
    [cell.headPhoto setImage:[UIImage imageNamed:@"pic1.jpg"]];
    PFFile *PFPhoto = (PFFile*)_cellDictData[@"profilePictureMedium"];
    [PFPhoto getDataInBackgroundWithBlock:^(NSData *imageData, NSError *error) {
        if (!error) {
            [cell.headPhoto setImage:[UIImage imageWithData:imageData]];
        }
    }];
    
    //名字
    cell.displayName.text = _cellDictData[@"displayName"];
    //出發日期
    cell.travelDate.text = _cellDictData[@"startDate"];
    
    //更多說明
    cell.memo.numberOfLines = 0;  //需定義為0才會換行
    //cell.memo.textColor = [UIColor whiteColor];
    cell.memo.textAlignment = NSTextAlignmentLeft;  //內文對齊方式
    //[cell.memo setBackgroundColor:[UIColor redColor]];
    cell.memo.text = _cellDictData[@"memo"];
    //NSLog(@"label height= %f, width= %f",cell.memo.frame.size.height,cell.memo.frame.size.width);
}

- (void) prepareJL2Cellstyle:(JL2TableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //點選時的顏色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //設定邊框粗細
    //[[cell.firstSectionView layer] setBorderWidth:1.5];
    
    //邊框顏色
    //[[cell.firstSectionView layer] setBorderColor:[UIColor colorWithRed:0.806 green:0.806 blue:0.806 alpha:1.0].CGColor];
    
    //設定背景顏色
    [[cell.secondSectionView layer] setBackgroundColor:[UIColor whiteColor].CGColor];
    cell.backgroundColor = [UIColor homeCellbgColor];
    
    //設定圓角程度
    [[cell.secondSectionView layer] setCornerRadius:10.0];
    
    //照片圓形遮罩
    //cell.headPhoto.layer.cornerRadius = cell.headPhoto.frame.size.width / 2;
    //cell.headPhoto.layer.borderWidth = 3.0f;
    //cell.headPhoto.layer.borderColor = [UIColor boyPhotoBorderColor].CGColor;
    //cell.headPhoto.clipsToBounds = YES;
    
    //按鈕
    //cell.joinBtn.layer.cornerRadius = 15.0;
}

- (void) prepareJL3MessagCellstyle:(JL3MessageTableViewCell *)cell cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    //點選時的顏色
    cell.selectionStyle = UITableViewCellSelectionStyleNone;
    //設定邊框粗細
    //[[cell.firstSectionView layer] setBorderWidth:1.5];
    
    //邊框顏色
    //[[cell.firstSectionView layer] setBorderColor:[UIColor colorWithRed:0.806 green:0.806 blue:0.806 alpha:1.0].CGColor];
    
    //設定背景顏色
    [[cell.thirdSectionView layer] setBackgroundColor:[UIColor whiteColor].CGColor];
    cell.backgroundColor = [UIColor homeCellbgColor];
    
    //設定圓角程度
    [[cell.thirdSectionView layer] setCornerRadius:5.0];
    
    //照片圓形遮罩
    //cell.headPhoto.layer.cornerRadius = cell.headPhoto.frame.size.width / 2;
    //cell.headPhoto.layer.borderWidth = 3.0f;
    //cell.headPhoto.layer.borderColor = [UIColor boyPhotoBorderColor].CGColor;
    //cell.headPhoto.clipsToBounds = YES;
    
    //按鈕
    //cell.joinBtn.layer.cornerRadius = 15.0;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result;
    
    if(indexPath.section == 0){
        result = 310.0;
        
        NSString * memo = _cellDictData[@"memo"];
        NSDictionary *attributes = @{NSFontAttributeName: [UIFont fontWithName:@"HelveticaNeue" size:12]};
        NSAttributedString * attrString = [[NSAttributedString alloc] initWithString:memo attributes:attributes];
        
        //寬度固定計算行高(NSStringDrawingUsesLineFragmentOrigin|NSStringDrawingUsesFontLeading)
        CGRect rect = [attrString boundingRectWithSize:CGSizeMake(296.0, CGFLOAT_MAX) options:NSStringDrawingUsesLineFragmentOrigin context:nil];
        //NSLog(@"rect:%@",NSStringFromCGRect(rect));
        //NSLog(@"rect height = %f",rect.size.height);
        result += rect.size.height;
        
        //如果使用者為原PO,參加按鈕隱藏
        if([user.objectId isEqualToString:_cellDictData[@"userObjectId"]])
            result -= 50.0;
        
    }else{
        result = 80.0;
    }
    
    return result;
}

- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    if (scrollView == _detailTableView)
    {
        // pass the current offset of the UITableView so that the ParallaxHeaderView layouts the subViews.
        [(ParallaxHeaderView *)_detailTableView.tableHeaderView layoutHeaderViewForScrollViewOffset:scrollView.contentOffset];
    }
}

#pragma mark - TextField Delegate
//- (BOOL)textFieldShouldBeginEditing:(UITextView *)textView {
//    
//    //[_detailTableView setContentOffset:CGPointMake(0, CGFLOAT_MAX)];
//    return YES;
//}


#pragma mark - keyboard move view method
- (void)clickMethof:(UITapGestureRecognizer*)recognizer{
    [self.view endEditing:YES];
    CGRect frame = self.view.frame;
    frame.origin.y = 0;
    [self.view setFrame:frame];
    //    [_txtFiledComment resignFirstResponder];
    //    [_txtFieldName resignFirstResponder];
    
}

- (void)keyboardHeightChange:(NSNotification*)notification{
    NSDictionary *userInfo = [notification userInfo];
    CGSize keyboardSize = [[userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue].size;
    
    CGRect frame = self.view.frame;
    frame.origin.y = -(keyboardSize.height);
    [self.view setFrame:frame];
}

#pragma mark - Loading Parse Data
- (void)getData {
        
    //取得目前使用者是否有參加該活動
    PFObject *post = [PFObject objectWithoutDataWithClassName:@"TravelMatePost" objectId:_cellDictData[@"objectId"]];
    PFRelation *relation = [post relationForKey:@"joinUsers"];
    PFQuery *query = [relation query];
    //NSLog(@"%ld",query.countObjects);
    isJoin = @(query.countObjects);
    
    CGFloat tableViewWidth = [_cellDictData[@"tableViewWidth"] floatValue];
    //置頂照片
    PFFile *PFPhoto = (PFFile*)_cellDictData[@"photo"];
    headerPhoto = [UIImage imageWithData:[PFPhoto getData]];
    dispatch_async(dispatch_get_main_queue(), ^{
        
        headerView = [ParallaxHeaderView parallaxHeaderViewWithImage:headerPhoto forSize:CGSizeMake(tableViewWidth, 300)];
        //置頂標題:國家城市
        headerView.headerTitleLabel.text = _cellDictData[@"countryCity"];
        [_detailTableView setTableHeaderView:headerView];
        
        if (floor(NSFoundationVersionNumber) <= NSFoundationVersionNumber_iOS_7_1)
        {
            [blurImageView removeFromSuperview];
        } else {
            [blurredView removeFromSuperview];
        }
        
        [_detailTableView reloadData];
        [MBProgressHUD hideHUDForView:self.view animated:YES];
    });

}

@end