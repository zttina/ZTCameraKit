//
//  DAPhotoUtil.m
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import "DAPhotoUtil.h"

@implementation DAPhotoUtil

// 获取指定相册中照片
+ (NSArray<PHAsset *> *)getAllAssetWithAssetCollection:(PHAssetCollection *)assetCollection ascending:(BOOL)ascending
{
    // ascending:按照片创建时间排序 >> YES:升序 NO:降序
    NSMutableArray<PHAsset *> * assets = [NSMutableArray array];
    PHFetchOptions * option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:ascending]];
    PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:assetCollection options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if (((PHAsset *)obj).mediaType == PHAssetMediaTypeImage) {
            [assets addObject:obj];
        }
    }];
    return assets;
}
// 获取asset对应的图片
+ (void)getImageWithAsset:(PHAsset *)asset size:(CGSize)size completion:(void (^)(UIImage *image))completion
{
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageForAsset:asset targetSize:size contentMode:PHImageContentModeDefault options:option resultHandler:^(UIImage * _Nullable image, NSDictionary * _Nullable info) {
        
        if (completion) completion(image);
    }];
}

// 获取asset对应的图片
+ (void)getImageWithAsset:(PHAsset *)asset completion:(void (^)(NSData *imageData))completion
{
    PHImageRequestOptions * option = [[PHImageRequestOptions alloc] init];
    option.deliveryMode = PHImageRequestOptionsDeliveryModeOpportunistic;
    option.networkAccessAllowed = YES;
    [[PHCachingImageManager defaultManager] requestImageDataForAsset:asset options:option resultHandler:^(NSData * _Nullable imageData, NSString * _Nullable dataUTI, UIImageOrientation orientation, NSDictionary * _Nullable info) {
//        UIImage *image = [UIImage imageWithData:imageData];
        if (completion) completion(imageData);
    }];
}

+ (UIImage *)smartCompressImage:(UIImage *)image {
    /** 仿微信算法 **/
    int width = (int)image.size.width;
    int height = (int)image.size.height;
    int updateWidth = width;
    int updateHeight = height;
    int longSide = MAX(width, height);
    int shortSide = MIN(width, height);
    float scale = ((float) shortSide / longSide);
    
    // 大小压缩
    if (shortSide < 1080 || longSide < 1080) { // 如果宽高任何一边都小于 1080
        updateWidth = width;
        updateHeight = height;
    } else { // 如果宽高都大于 1080
        if (width < height) { // 说明短边是宽
            updateWidth = 1080;
            updateHeight = 1080 / scale;
        } else { // 说明短边是高
            updateWidth = 1080 / scale;
            updateHeight = 1080;
        }
    }
    
    CGSize compressSize = CGSizeMake(updateWidth, updateHeight);
    UIGraphicsBeginImageContext(compressSize);
    [image drawInRect:CGRectMake(0,0, compressSize.width, compressSize.height)];
    UIImage *compressImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return compressImage;
}
@end
