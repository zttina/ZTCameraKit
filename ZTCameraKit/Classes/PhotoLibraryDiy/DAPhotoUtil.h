//
//  DAPhotoUtil.h
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <Photos/Photos.h>
NS_ASSUME_NONNULL_BEGIN

@interface DAPhotoUtil : NSObject


/**
 获取指定相册照片

 */
+ (NSArray<PHAsset *> *)getAllAssetWithAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending;

/**
 获取asset对应的图片
 */
+ (void)getImageWithAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion;


/**
 获取asset对应的图片
 */
+ (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData))completion;
@end

NS_ASSUME_NONNULL_END
