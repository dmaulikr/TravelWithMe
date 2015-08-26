//
//  mapPostViewController.m
//  TravelWithMe
//
//  Created by ajay on 2015/8/10.
//  Copyright (c) 2015年 Jesse. All rights reserved.
//

#import "MapViewController.h"
#import "MapPostViewController.h"
#import "SelectTypeViewController.h"
#import "PostTypeTableViewCell.h"
#import "PostMapPhotoTableViewCell.h"
#import "PostMapMemoTableViewCell.h"
#import "VBFPopFlatButton.h"
#import "SCLAlertView.h"
#import <MobileCoreServices/MobileCoreServices.h>

@interface MapPostViewController ()<UITableViewDelegate, UITableViewDataSource, UITextFieldDelegate, UINavigationControllerDelegate, UIImagePickerControllerDelegate, UITextViewDelegate>
{
    UIImage *pickImage;
    UIImagePickerController *imagePicker;
    UIImageView *selectedImageView;
    UIDatePicker *datepicker;
    UIToolbar *toolBar;
    PFUser *user;
}
@property (weak, nonatomic) IBOutlet UIView *topView;
@property (weak, nonatomic) IBOutlet UILabel *loactionLabel;
@property (weak, nonatomic) IBOutlet UITableView *mapPostTableView;
@property (nonatomic, strong) VBFPopFlatButton *flatSendBtn;
@property (nonatomic, strong) VBFPopFlatButton *flatCancelBtn;
@end

@implementation MapPostViewController


- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    if (!user) {
        user = [PFUser currentUser];
    }
    
    //NSLog(@"%@",_dictDatas[MAPVIEW_LATITUDE_DICT_KEY]);
    [self getGeoCoderPlacemarks];
    
    
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    
    [self initUI];
    
    
}

- (void)initUI {
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    //關閉分隔線
    [_mapPostTableView setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    //設定所在地點
    _loactionLabel.text = [NSString stringWithFormat:@"%@,%@",_dictDatas[MAPVIEW_COUNTRY_DICT_KEY],_dictDatas[MAPVIEW_LOCALITY_DICT_KEY]];
    
    //初始化送出取消按鈕
    [self initFlatBtn];
}

#pragma mark - 初始化送出與取消按鈕
- (void)initFlatBtn {
    //送出
    _flatSendBtn = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(_topView.frame.size.width-30, _topView.center.y, 20, 20)
                                               buttonType:buttonOkType
                                              buttonStyle:buttonPlainStyle
                                    animateToInitialState:YES];
    //_flatSendBtn.roundBackgroundColor = [UIColor whiteColor];
    _flatSendBtn.lineThickness = 2;
    _flatSendBtn.tintColor = [UIColor whiteColor];
    [_flatSendBtn addTarget:self
                     action:@selector(sendBtnPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_flatSendBtn];
    
    //取消
    _flatCancelBtn = [[VBFPopFlatButton alloc]initWithFrame:CGRectMake(12, _topView.center.y, 20, 20)
                                               buttonType:buttonCloseType
                                              buttonStyle:buttonPlainStyle
                                    animateToInitialState:YES];
    //_flatCancelBtn.roundBackgroundColor = [UIColor redColor];
    _flatCancelBtn.lineThickness = 2;
    _flatCancelBtn.tintColor = [UIColor whiteColor];
    [_flatCancelBtn addTarget:self
                     action:@selector(cancelBtnPressed:)
           forControlEvents:UIControlEventTouchUpInside];
    [_topView addSubview:_flatCancelBtn];
}

#pragma mark - 送出資料
- (void) sendBtnPressed:(UIButton*)button{
    //結束編輯
    [self.view endEditing:YES];
    
    if([self isDataNotEmpty]) {
        [self dismissViewControllerAnimated:YES completion:^{
            [[NSNotificationCenter defaultCenter] postNotificationName:TOP_CHILD_DISMISSED_NOTIFICATION object:self];
        }];
    }
    
    
}

- (void) cancelBtnPressed:(UIButton*)button{
    
    
    [self dismissViewControllerAnimated:YES completion:^{
        [[NSNotificationCenter defaultCenter] postNotificationName:TOP_CHILD_DISMISSED_NOTIFICATION object:self];
    }];
}
//
//- (void)publishBtnPressed:(id *)sender {
//    [self.view endEditing:YES];
//    
//    //NSLog(@"%@",datas);
//    
//    if([self isDataNotEmpty]){
//        if(user) {
//            
//            MBProgressHUD *hud =  [MBProgressHUD showHUDAddedTo:self.view animated:YES];
//            hud.labelText = @"發送中...";
//            
//            dispatch_queue_t publishQueue = dispatch_queue_create("publish", nil);
//            
//            dispatch_async(publishQueue, ^{
//                
//                PFObject *travelMatePost = [PFObject objectWithClassName:TRAVELMATEPOST_TABLENAME];
//                travelMatePost[TRAVELMATEPOST_COUNTRYCITY_KEY] = [datas objectForKey:[NSNumber numberWithInteger: TEXTFIELD_COUNTRYCITY_TAG]];
//                travelMatePost[TRAVELMATEPOST_MEMO_KEY] = [datas objectForKey:[NSNumber numberWithInteger: TEXTVIEW_MEMO_TAG]];
//                
//                //出發日期
//                //NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
//                //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss"];
//                //NSDate *startDate = [dateFormatter dateFromString:[NSString stringWithFormat:@"%@ 00:00:00",[datas objectForKey:[NSNumber numberWithInteger: TEXTFIELD_STARTDATE_TAG]]]];
//                //NSLog(@"%@ => %@",[NSString stringWithFormat:@"%@ 00:00:00",[datas objectForKey:[NSNumber numberWithInteger: TEXTFIELD_STARTDATE_TAG]]],startDate);
//                NSString *startDate = [datas objectForKey:[NSNumber numberWithInteger: TEXTFIELD_STARTDATE_TAG]];
//                //NSLog(@"%@",startDate);
//                travelMatePost[TRAVELMATEPOST_STARTDATE_KEY] = startDate;
//                
//                //顯示用方形照片
//                PFFile *imageFile = [PFFile fileWithName:[NSString stringWithFormat:@"photo.jpg"] data:[datas objectForKey:[NSNumber numberWithInteger: IMAGEVIEW_SHAREPHOTO_TAG]]];
//                //小方形照片
//                PFFile *smallImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"smallPhoto.jpg"] data:[datas objectForKey:TRAVELMATEPOST_SMALLPHOTO_KEY]];
//                //原始大小縮圖照片
//                PFFile *originalImageFile = [PFFile fileWithName:[NSString stringWithFormat:@"originalPhoto.jpg"] data:[datas objectForKey:TRAVELMATEPOST_ORIGINALPHOTO_KEY]];
//                
//                travelMatePost[TRAVELMATEPOST_PHOTO_KEY] = imageFile;
//                travelMatePost[TRAVELMATEPOST_SMALLPHOTO_KEY] = smallImageFile;
//                travelMatePost[TRAVELMATEPOST_ORIGINALPHOTO_KEY] = originalImageFile;
//                
//                
//                //出發天數
//                travelMatePost[TRAVELMATEPOST_DAYS_KEY] = [NSNumber numberWithInteger:[[datas objectForKey:[NSNumber numberWithInteger: TEXTFIELD_DAYS_TAG]] integerValue]];
//                
//                travelMatePost[COMMON_POINTER_CREATEUSER_KEY] = user;
//                
//                //計數
//                travelMatePost[TRAVELMATEPOST_COMMENTCOUNT_KEY] = @0;
//                travelMatePost[TRAVELMATEPOST_JOINCOUNT_KEY] = @0;
//                travelMatePost[TRAVELMATEPOST_INTERESTEDCOUNT_KEY] = @0;
//                travelMatePost[TRAVELMATEPOST_WATCHCOUNT_KEY] = @0;
//                
//                [travelMatePost save];
//                
//                PFRelation *relation = [user relationForKey:USER_RELATION_TRAVELMATEPOSTS_KEY];
//                [relation addObject:travelMatePost];
//                [user save];
//                
//                dispatch_async(dispatch_get_main_queue(), ^{
//                    [MBProgressHUD hideHUDForView:self.view animated:YES];
//                    
//                    [[NSNotificationCenter defaultCenter] postNotificationName:@"isDataSave" object:self];
//                    
//                    [self.navigationController popViewControllerAnimated:YES];
//                });
//            });
//        }
//    } else {
//        
//    }
//    
//}

#pragma mark - 判斷是否有欄位為nil
- (BOOL) isDataNotEmpty {
    
    BOOL result = YES;
    SCLAlertView *alert = [[SCLAlertView alloc] init];
    UIColor *color = [UIColor customGreenColor];
    NSString *icon = @"exclamation-icon";
    NSString *title;
    NSString *subTitle;
    
    NSString *memoStr = [_dictDatas objectForKey:MAPVIEW_MEMO_DICT_KEY];
    NSData *sharePhotoData = [_dictDatas objectForKey:MAPVIEW_SHAREPHOTO_DICT_KEY];
    
    if (memoStr==nil || [memoStr isEqualToString:@""])
    {
        title = @"還沒填唷!";
        subTitle = @"在現在做什麼呢?";
        result = NO;
    }
    else if (sharePhotoData==nil)
    {
        title = @"沒照片唷!";
        subTitle = @"隨手分享張照片吧!";
        result = NO;
    }
    
    if(!result)
        [alert showCustom:self image:[UIImage imageNamed:icon] color:color title:title subTitle:subTitle closeButtonTitle:@"OK" duration:0.0f];
    
    return result;
}

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */


#pragma mark - Table View Delegate Method
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return MAPPOST_NUMBER_OF_SECTIONS;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    
    return MAPPOST_NUMBER_OF_ROWS;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath{
    
//    if(datas == nil) {
//        datas = [NSMutableDictionary new];
//    }
    
    NSString *identifier;
    
    if (indexPath.row == 0) {
        identifier = @"cell1";
    } else if (indexPath.row == 1){
        identifier = @"cell2";
    } else if (indexPath.row == 2){
        identifier = @"cell3";
    }
    
    if (indexPath.row == 0) {
         PostTypeTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else if (indexPath.row == 1) {
        
        PostMapPhotoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell.mapPostSharePhoto setTag:IMAGEVIEW_MAPSHAREPHOTO_TAG];
        //給予imageView手勢行為：點一次觸發
        UITapGestureRecognizer *tapped = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(imageTapped:)];
        tapped.numberOfTapsRequired = 1;
        [cell.mapPostSharePhoto addGestureRecognizer:tapped];
        cell.mapPostSharePhoto.userInteractionEnabled = YES;

        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        return cell;
        
    } else if (indexPath.row == 2) {
        
        PostMapMemoTableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
        
        [cell.mapPostMemoTextView setTag:TEXTVIEW_MAPMEMO_TAG];
        
        [cell.mapPostMemoTextView.layer setBackgroundColor: [[UIColor clearColor] CGColor]];
        [cell.mapPostMemoTextView.layer setBorderColor: [[UIColor colorWithRed:0.533 green:0.544 blue:0.562 alpha:1.000] CGColor]];
        [cell.mapPostMemoTextView.layer setBorderWidth: 2.0];
        [cell.mapPostMemoTextView.layer setCornerRadius:5.0f];
        [cell.mapPostMemoTextView.layer setMasksToBounds:YES];
        
        cell.selectionStyle = UITableViewCellSelectionStyleNone;
        
        cell.mapPostMemoTextView.delegate = self;
        
        return cell;
        
    }
    
    
    return [tableView dequeueReusableCellWithIdentifier:identifier forIndexPath:indexPath];
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    CGFloat result;
    
    if(indexPath.row == 0){
        result = 100.0;
        
    }else if(indexPath.row == 1) {
        result = 350.0;
        
        if(self.view.frame.size.width<=320.0) {//5s
            result -= 30.0;
        } else if (self.view.frame.size.width<=375.0) { //6
            result -= 5.0;
        }else {
            result += 10.0;
        }
        
    }else if(indexPath.row == 2) {
        result = 200.0;
    }
    else{
        result = 80.0;
    }
    
    return result;
}

#pragma mark - Gesture Method

//Method controlling what happens when cell's UIImage is tapped
-(void)imageTapped:(UIGestureRecognizer*)gesture
{
    
    selectedImageView=(UIImageView*)[gesture view];
    
    UIAlertController * alertController = [UIAlertController new];
    if(imagePicker==nil)
        imagePicker = [[UIImagePickerController alloc]init];
    
    UIAlertAction * action1 = [UIAlertAction actionWithTitle:@"拍攝照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        // NSLog(@"拍攝照片");
        // 先檢查裝置是否配備相機
        if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]){
            
            
            // 設定相片來源為裝置上的相機
            imagePicker.sourceType = UIImagePickerControllerSourceTypeCamera;
            // 設定imagePicker的delegate為ViewController
            imagePicker.delegate = self;
            imagePicker.allowsEditing=true;
            //開起相機拍照界面
            [self presentViewController:imagePicker animated:YES completion:nil];
        }
        
    }];
    
    UIAlertAction * action2 = [UIAlertAction actionWithTitle:@"選擇照片" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 讀取照片
        UIImagePickerControllerSourceType sourceType=UIImagePickerControllerSourceTypePhotoLibrary;
        imagePicker.sourceType=sourceType;
        imagePicker.mediaTypes = @[(NSString*)kUTTypeImage];
        imagePicker.allowsEditing=true; // 調整大小
        imagePicker.delegate=self;
        
        [self presentViewController:imagePicker animated:true completion:nil];
        
    }];
    
    UIAlertAction * cancel = [UIAlertAction actionWithTitle:@"取消" style:UIAlertActionStyleCancel handler:^(UIAlertAction *action) {
        //NSLog(@"cancel");
    }];
    
    [alertController addAction:action2];
    [alertController addAction:action1];
    [alertController addAction:cancel];
    
    [self presentViewController:alertController animated:YES completion:^{
        //NSLog(@"didshow");
    }];
}


#pragma mark - TextView Delegate Method
- (void)textViewDidEndEditing:(UITextView *)textView
{
    if((textView.tag == TEXTVIEW_MAPMEMO_TAG) && ([textView.text isEqual:@""]||textView.text==nil)) {
        [textView.layer setBorderColor: [[UIColor colorWithRed:0.533 green:0.544 blue:0.562 alpha:1.000] CGColor]];
    }
    
    
    [_dictDatas setObject:textView.text forKey:MAPVIEW_MEMO_DICT_KEY];
}

- (BOOL)textViewShouldBeginEditing:(UITextView *)textView {
    
    if(textView.tag == TEXTVIEW_MAPMEMO_TAG) {
        
        [textView.layer setBorderColor: [[UIColor colorWithRed:0.263 green:0.718 blue:0.608 alpha:1.000] CGColor]];
    }
    
    return true;
}

-(void)imagePickerControllerDidCancel:(UIImagePickerController *)picker {
    // 當使用者按下取消按鈕後關閉拍照程式
    [self dismissViewControllerAnimated:YES completion:nil];
}

// 選取完後取得照片
-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info {
    
    
    NSString *type = info[UIImagePickerControllerMediaType];
    
    if ([type isEqualToString:(NSString *)kUTTypeImage])
    {
        //原始大小
        UIImage *originaImage = info[UIImagePickerControllerOriginalImage];
        //原始大小圖縮圖和壓縮
        NSData *originaImageData = [PAPUtility resizeImage:originaImage width:1080.0 height:1080.0 contentMode:UIViewContentModeScaleAspectFill];
        
        //方形圖
        UIImage *editedImage = info[UIImagePickerControllerEditedImage];
        //方形圖縮圖和壓縮
        NSData *imageData = [PAPUtility resizeImage:editedImage width:500.0 height:500.0 contentMode:UIViewContentModeScaleAspectFill];
        //方形圖縮小圖和壓縮
        NSData *smallImageData = [PAPUtility resizeImage:editedImage width:100.0 height:100.0 contentMode:UIViewContentModeScaleAspectFill];
        
        [_dictDatas setObject:imageData forKey:MAPVIEW_SHAREPHOTO_DICT_KEY];
        [_dictDatas setObject:smallImageData forKey:MAPVIEW_SHAREPHOTO_DICT_KEY];
        [_dictDatas setObject:originaImageData forKey:MAPVIEW_SHAREPHOTO_DICT_KEY];
        
        
        [selectedImageView setImage:[UIImage imageWithData:imageData]];
    }
    [picker dismissViewControllerAnimated:true completion:nil];
    
    
    // 取得使用者拍攝的照片
    //UIImage *image = [info valueForKey:UIImagePickerControllerOriginalImage];
    //[selectedImageView setImage:image];
    //    // 存檔
    //    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    // 關閉拍照程式
    //[self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 反查地點
-(void)getGeoCoderPlacemarks{
    
    CLGeocoder *gecorder = [CLGeocoder new];

    CLLocation *location =[[CLLocation alloc] initWithLatitude:[_dictDatas[MAPVIEW_LATITUDE_DICT_KEY] doubleValue] longitude:[_dictDatas[MAPVIEW_LONGITUDE_DICT_KEY] doubleValue]];
    
    [gecorder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks,NSError *error){
        
        //NSLog(@"Result:%@",placemarks.description);
        CLPlacemark *placemark = placemarks[0];
        
//        for(CLPlacemark *placemark in placemarks)
//        {
//            NSLog(@"address dic %@",placemark.addressDictionary);
//        }
        
        //NSLog(@"1:%@,  2:%@  3:%@",placemark.country,placemark.c,placemark.locality);
        
        //country  administrativeArea  locality 國家 縣市(台灣沒有這一級) 鄉鎮區市
        
        [_dictDatas setObject:placemark.country forKey:MAPVIEW_COUNTRY_DICT_KEY];
        [_dictDatas setObject:placemark.locality forKey:MAPVIEW_LOCALITY_DICT_KEY];
    }];
    
}


@end

