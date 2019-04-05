//
//  ZTCameraKitHeader.h
//  Pods
//
//  Created by zt on 2019/4/5.
//

#ifndef ZTCameraKitHeader_h
#define ZTCameraKitHeader_h

/*屏幕宽度*/
#define ZTSCREENW (([UIScreen mainScreen].bounds.size.width > [UIScreen mainScreen].bounds.size.height) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)
/*屏幕高度*/
#define ZTSCREENH (([UIScreen mainScreen].bounds.size.height > [UIScreen mainScreen].bounds.size.width) ? [UIScreen mainScreen].bounds.size.height : [UIScreen mainScreen].bounds.size.width)


#define ZTHEXCOLOR(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define ZTgradient1 ZTHEXCOLOR(0x0060FF)

#import "ReactiveCocoa.h"
#import <Photos/Photos.h>
#define ZT_Is_iPhoneX  ((ZTSCREENH == 812 || ZTSCREENH == 896) ? YES : NO)
// tabBar高度
#define ZT_TAB_BAR_HEIGHT (ZT_Is_iPhoneX ? 83 : 49)
// 状态栏高度
#define ZT_kNavigationBarHeight (ZT_Is_iPhoneX ? 88 : 64)

#endif /* ZTCameraKitHeader_h */
