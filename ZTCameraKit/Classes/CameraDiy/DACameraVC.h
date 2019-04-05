//
//  DACameraVC.h
//  TechnicianApp
//
//  Created by zt on 2019/3/15.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTCameraKitHeader.h"
typedef void(^ReturnImageData)(NSData *imageData);
typedef void(^ReturnVideoURL)(NSURL *videoUrl);
typedef void(^ReturnImage)(UIImage *image);
NS_ASSUME_NONNULL_BEGIN

@interface DACameraVC : UIViewController


/**
 选择照片时的block
 */
@property (nonatomic,copy) ReturnImageData imageDataBlock;

/**
 选择视频时的block
 */
@property (nonatomic,copy) ReturnVideoURL videoUrlBlock;


/**
 选择照片的block传image
 */
@property (nonatomic,copy) ReturnImage imageBlock;


@end

NS_ASSUME_NONNULL_END
