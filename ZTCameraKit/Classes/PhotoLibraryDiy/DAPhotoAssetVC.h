//
//  DAPhotoAssetVC.h
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
@class DAPhotoAlbums;

typedef void(^SelectTheImage)(UIImage *image);
NS_ASSUME_NONNULL_BEGIN

@interface DAPhotoAssetVC : UIViewController

// 所选相册
@property (nonatomic, strong) DAPhotoAlbums *photoAlbum;

/**
 选择的图片
 */
@property (nonatomic,copy) SelectTheImage imageBlock;

@end

#pragma mark - ################## DAPHAsset
@interface DAPHAsset : NSObject

@property (nonatomic,assign) CGFloat aspectRatio;

// 资源
@property (nonatomic, strong) PHAsset * asset;
// 是否已选择
@property (nonatomic, assign) BOOL isSelected;

@end
#pragma mark - ################## DAPHAssetCell

@interface DAPHAssetCell : UICollectionViewCell

@property (nonatomic, strong) PHAsset * asset;
@property (nonatomic, strong) UIImageView * imageView;
@property (nonatomic, strong) UIImageView * overLay;

- (void)configWithAsset:(PHAsset *)asset isCover:(BOOL)isCover;

@end

NS_ASSUME_NONNULL_END
