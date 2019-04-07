//
//  ZTPhotoPreviewVC.h
//  ZTCameraKit
//
//  Created by zttina on 2019/3/23.
//  Copyright © 2019年 zttina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTPhotoAssetVC.h"

typedef void(^SelectTheImage)(UIImage *image);
NS_ASSUME_NONNULL_BEGIN

@interface ZTPhotoPreviewVC : UIViewController

@property (nonatomic, strong) NSMutableArray<ZTPHAsset *> * assetArray;
@property (nonatomic,assign) NSInteger currentIndex;


/**
 选择这个image
 */
@property (nonatomic,copy) SelectTheImage selectImageBlock;


@end


NS_ASSUME_NONNULL_END
