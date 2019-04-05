//
//  DAPhotoPreviewVC.h
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "DAPhotoAssetVC.h"

typedef void(^SelectTheImage)(UIImage *image);
NS_ASSUME_NONNULL_BEGIN

@interface DAPhotoPreviewVC : UIViewController

@property (nonatomic, strong) NSMutableArray<DAPHAsset *> * assetArray;
@property (nonatomic,assign) NSInteger currentIndex;


/**
 选择这个image
 */
@property (nonatomic,copy) SelectTheImage selectImageBlock;


@end


NS_ASSUME_NONNULL_END
