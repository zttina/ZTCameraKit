//
//  ZTPhotoLibraryVC.h
//  ZTCameraKit
//
//  Created by zttina on 2019/3/22.
//  Copyright © 2019年 zttina. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "ZTCameraKitHeader.h"
NS_ASSUME_NONNULL_BEGIN


typedef void(^SelectTheImage)(UIImage *image);
typedef void(^PhotoPickerDidCancel)(void);

@interface ZTPhotoLibraryVC : UIViewController

@property (nonatomic,copy) PhotoPickerDidCancel cancelBlock;//取消block。如果有其它操作可用它


/**
 选择图片
 */
@property (nonatomic,copy) SelectTheImage imageBlock;

@end

//MARK:相册
@interface ZTPhotoAlbums : NSObject

// 相册名称
@property (nonatomic, copy) NSString * name;
// 内含图片数量
@property (nonatomic, assign) NSInteger assetCount;
// 封面
@property (nonatomic, strong) PHAsset * coverAsset;
// 相册
@property (nonatomic, strong) PHAssetCollection * collection;

@end

#pragma mark - ################## ZTPhotoAlbumCell
@interface ZTPhotoAlbumCell : UITableViewCell

@property (nonatomic,strong) UIImageView *iconImageView;
@property (nonatomic,strong) UILabel *libraryNameLabel;

@end
NS_ASSUME_NONNULL_END
