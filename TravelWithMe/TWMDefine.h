//
//  TWMDefine.h
//  TravelWithMe
//
//  Created by Jesselin on 2015/8/19.
//  Copyright (c) 2015年 Jesse. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface TWMDefine : NSObject

/*
 * NSNotification 定義
 */
#pragma mark - NSNotification

#define TOP_CHILD_DISMISSED_NOTIFICATION @"TopChildDismissed"
#define PRESENT_TO_MAPPOSTVIEW_NOTIFICATION @"PresentToMapPost"
#define OFF_LINE_NOTIFICATION @"OffLine"
#define EMAIL_LOGIN_PROCESS_DONE @"emailLoginProcessDone"

/*
 * PARSE 欄位定義
*/

#pragma mark - Parse Table:TRAVELMATEPOST

#define TRAVELMATEPOST_TABLENAME @"TravelMatePost"
#define TRAVELMATEPOST_COUNTRYCITY_KEY @"countryCity"
#define TRAVELMATEPOST_STARTDATE_KEY @"startDate"
#define TRAVELMATEPOST_DAYS_KEY @"days"
#define TRAVELMATEPOST_MEMO_KEY @"memo"
#define TRAVELMATEPOST_PHOTO_KEY @"photo"
#define TRAVELMATEPOST_SMALLPHOTO_KEY @"smallPhoto"
#define TRAVELMATEPOST_ORIGINALPHOTO_KEY @"originalPhoto"
#define TRAVELMATEPOST_RELATION_COMMENTS_KEY @"comments"
#define TRAVELMATEPOST_RELATION_JOINUSERS_KEY @"joinUsers"
#define TRAVELMATEPOST_RELATION_INTERSTEDUSERS_KEY @"interestedUsers"
#define TRAVELMATEPOST_INTERESTEDCOUNT_KEY @"interestedCount"
#define TRAVELMATEPOST_COMMENTCOUNT_KEY @"commentCount"
#define TRAVELMATEPOST_JOINCOUNT_KEY @"joinCount"
#define TRAVELMATEPOST_WATCHCOUNT_KEY @"watchCount"

//使用者//
#pragma mark - Parse Table:USER

#define USER_DISPLAYNAME_KEY @"displayName"
#define USER_EMAIL_KEY @"email"
#define USER_LINE_KEY @"line"
#define USER_WECHAT_KEY @"wechat"
#define USER_FACEBOOK_KEY @"facebook"
#define USER_GENDER_KEY @"gender"
#define USER_LOCATION_KEY @"location"
#define USER_BIRTHDAY_KEY @"birthday"
#define USER_PROFILEPICTUREMEDIUM_KEY @"profilePictureMedium"
#define USER_PROFILEPICTURESMALL_KEY @"profilePictureSmall"
#define USER_RELATION_TRAVELMATEPOSTS_KEY @"travelMatePosts"
#define USER_RELATION_MAPPOSTS_KEY @"mapPosts"

//留言//
#pragma mark - Parse Table:COMMENT

#define COMMENT_TABLENAME @"Comment"
#define COMMENT_MESSAGE_KEY @"message"

//地圖PO文
#pragma mark - Parse Table:MapPost

#define MAPPOST_TABLENAME @"MapPost"
#define MAPPOST_TYPE_KEY @"type"
#define MAPPOST_COUNTRY_KEY @"country"
#define MAPPOST_LOCALITY_KEY @"locality"
#define MAPPOST_USERLOCATION_KEY @"userLocation"
#define MAPPOST_LATITUDE_KEY @"latitude"
#define MAPPOST_LONGITUDE_KEY @"longitude"
#define MAPPOST_MEMO_KEY @"memo"
#define MAPPOST_PHOTO_KEY @"photo"
#define MAPPOST_SMALLPHOTO_KEY @"smallPhoto"
#define MAPPOST_ORIGINALPHOTO_KEY @"originalPhoto"
#define MAPPOST_LIKECOUNT_KEY @"likeCount"

//共通欄位名稱//
#pragma mark - Parse Common Table Col

#define COMMON_OBJECTID_KEY @"objectId"
#define COMMON_CREATEDAT_KEY @"createdAt"
#define COMMON_POINTER_CREATEUSER_KEY @"createUser"

#pragma mark - MapView

//地圖ADD按鈕位置//
#define MAP_FLAT_BTN_CGRECTMAKE self.view.frame.size.width/2 - 15, self.view.frame.size.height - 100, 30, 30
//地圖大頭針註解按鈕//
#define MAP_ANNOTATION_FLAT_BTN_CGRECTMAKE 0, 0, 22, 22
//類別按鈕初始位置
#define FOOT_BTN_CGRECTMAKE self.view.frame.size.width/2 - 40, self.view.frame.size.height - 150, 90, 105
#define LANSCAPE_BTN_CGRECTMAKE self.view.frame.size.width/2 - 40, self.view.frame.size.height - 150, 90, 105
#define PEOPLE_BTN_CGRECTMAKE self.view.frame.size.width/2 - 40, self.view.frame.size.height - 150, 90, 105
//類別按鈕動態移動結束位置
#define FOOD_BTN_SNAP_BEHAVIOR_CGPOINT self.view.frame.size.width/2, self.view.frame.size.height/2 - 50
#define LANSCAPE_BTN_SNAP_BEHAVIOR_CGPOINT self.view.frame.size.width/2 - 110, self.view.frame.size.height/2 - 25
#define PEOPLE_BTN_SNAP_BEHAVIOR_CGPOINT self.view.frame.size.width/2 + 110, self.view.frame.size.height/2 - 25

//螢幕大小
#define SCREEN_SIZE [[UIScreen mainScreen] bounds]
@end
