//
//  DAPhotoAssetVC.m
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import "DAPhotoAssetVC.h"
#import "DAPhotoLibraryVC.h"
#import "DAPhotoUtil.h"
#import "DAPhotoPreviewVC.h"
#import "ZTCameraKitHeader.h"
@interface DAPhotoAssetVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic, strong) UICollectionView * collectionView;//相册的collectionView
@property (nonatomic,strong) NSMutableArray *phAssetArray;//图片数组
@property (nonatomic, strong) PHCachingImageManager *imageManager;
@property (nonatomic, assign) CGRect previousPreheatRect;

@end

@implementation DAPhotoAssetVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = self.photoAlbum.name;
    self.view.backgroundColor = [UIColor whiteColor];
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(rightBarItemAction)];
    [self.view addSubview:self.collectionView];

    // 获取指定相册所有照片
    self.phAssetArray = [[NSMutableArray alloc] init];
    
    PHFetchOptions * option = [[PHFetchOptions alloc] init];
    option.sortDescriptors = @[[NSSortDescriptor sortDescriptorWithKey:@"creationDate" ascending:NO]];
    PHFetchResult * result = [PHAsset fetchAssetsInAssetCollection:self.photoAlbum.collection options:option];
    [result enumerateObjectsUsingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        PHAsset * asset = (PHAsset *)obj;
        if (asset.mediaType == PHAssetMediaTypeImage) {
            DAPHAsset * daAsset = [[DAPHAsset alloc] init];
            daAsset.asset = asset;
            daAsset.isSelected = NO;
            [self.phAssetArray addObject:daAsset];
        }
    }];

}
- (void)rightBarItemAction {
    [self.navigationController popViewControllerAnimated:YES];
}
#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.phAssetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAPHAsset * mmAsset = [self.phAssetArray objectAtIndex:indexPath.row];
    // 赋值
    DAPHAssetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
    [cell configWithAsset:mmAsset.asset isCover:YES];
    cell.selected = mmAsset.isSelected;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    DAPHAsset * mmAsset = [self.phAssetArray objectAtIndex:indexPath.row];
//    PHAsset * asset = mmAsset.asset;
    DAPhotoPreviewVC *previewVC = [[DAPhotoPreviewVC alloc]init];
    previewVC.assetArray = self.phAssetArray;
    previewVC.currentIndex = indexPath.item;
    previewVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
    previewVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
    [self presentViewController:previewVC animated:YES completion:nil];
    @weakify(self,previewVC);
    previewVC.selectImageBlock = ^(UIImage *image) {
        @strongify(self,previewVC);
        dispatch_async(dispatch_get_main_queue(), ^{
            @strongify(previewVC);
            [previewVC dismissViewControllerAnimated:NO completion:nil];
        });
        if (self.imageBlock) {
            self.imageBlock(image);
        }
    };
}
- (void)viewDidAppear:(BOOL)animated{
    [super viewDidAppear:animated];
    [self updateCachedAssets];
}
- (void)scrollViewDidScroll:(UIScrollView *)scrollView
{
    [self updateCachedAssets];
}

//该缓存方案的原理就是缓存frame范围内所对应的显示到cell上的照片的PHAsset对象。这样在滑动的时候直接读取缓存里面的数据，避免了反复根据index去给cell赋值的操作。
- (void)updateCachedAssets{
    BOOL isViewVisible = [self isViewLoaded] && self.view.window != nil;
    if (!isViewVisible) { return; }
    
    // The preheat window is twice the height of the visible rect
    CGRect preheatRect = self.collectionView.bounds;
    preheatRect = CGRectInset(preheatRect, 0.0, -0.5 * CGRectGetHeight(preheatRect));
    
    // If scrolled by a "reasonable" amount...
    CGFloat delta = ABS(CGRectGetMidY(preheatRect) - CGRectGetMidY(self.previousPreheatRect));
    
    if (delta > CGRectGetHeight(self.collectionView.bounds) / 3.0) {
        // Compute the assets to start caching and to stop caching
        NSMutableArray *addedIndexPaths = [NSMutableArray array];
        NSMutableArray *removedIndexPaths = [NSMutableArray array];
        
        [self computeDifferenceBetweenRect:self.previousPreheatRect andRect:preheatRect addedHandler:^(CGRect addedRect) {
            NSArray *indexPaths = [self apple_indexPathsForElementsInRect:addedRect];
            [addedIndexPaths addObjectsFromArray:indexPaths];
        } removedHandler:^(CGRect removedRect) {
            NSArray *indexPaths = [self apple_indexPathsForElementsInRect:removedRect];
            [removedIndexPaths addObjectsFromArray:indexPaths];
        }];
        
        NSArray *assetsToStartCaching = [self assetsAtIndexPaths:addedIndexPaths];
        NSArray *assetsToStopCaching = [self assetsAtIndexPaths:removedIndexPaths];
        
        NSInteger numInLine = 4;
        CGFloat kMargin = 3;
        CGFloat itemWidth = (ZTSCREENW - (numInLine + 1) * kMargin) / numInLine;

        CGSize itemSize = CGSizeMake(itemWidth, itemWidth);
        
        [self.imageManager startCachingImagesForAssets:assetsToStartCaching
                                            targetSize:itemSize
                                           contentMode:PHImageContentModeAspectFill
                                               options:nil];
        [self.imageManager stopCachingImagesForAssets:assetsToStopCaching
                                           targetSize:itemSize
                                          contentMode:PHImageContentModeAspectFill
                                              options:nil];
        
        self.previousPreheatRect = preheatRect;
    }
}
-(void)computeDifferenceBetweenRect:(CGRect)oldRect andRect:(CGRect)newRect addedHandler:(void (^)(CGRect addedRect))addedHandler removedHandler:(void (^)(CGRect removedRect))removedHandler
{
    if (CGRectIntersectsRect(newRect, oldRect)) {
        CGFloat oldMaxY = CGRectGetMaxY(oldRect);
        CGFloat oldMinY = CGRectGetMinY(oldRect);
        CGFloat newMaxY = CGRectGetMaxY(newRect);
        CGFloat newMinY = CGRectGetMinY(newRect);
        
        if (newMaxY > oldMaxY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, oldMaxY, newRect.size.width, (newMaxY - oldMaxY));
            addedHandler(rectToAdd);
        }
        if (oldMinY > newMinY) {
            CGRect rectToAdd = CGRectMake(newRect.origin.x, newMinY, newRect.size.width, (oldMinY - newMinY));
            addedHandler(rectToAdd);
        }
        if (newMaxY < oldMaxY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, newMaxY, newRect.size.width, (oldMaxY - newMaxY));
            removedHandler(rectToRemove);
        }
        if (oldMinY < newMinY) {
            CGRect rectToRemove = CGRectMake(newRect.origin.x, oldMinY, newRect.size.width, (newMinY - oldMinY));
            removedHandler(rectToRemove);
        }
    } else {
        addedHandler(newRect);
        removedHandler(oldRect);
    }
}
- (NSArray *)apple_indexPathsForElementsInRect:(CGRect)rect
{
    NSArray *allLayoutAttributes = [self.collectionView.collectionViewLayout layoutAttributesForElementsInRect:rect];
    if (allLayoutAttributes.count == 0) { return nil; }
    
    NSMutableArray *indexPaths = [NSMutableArray arrayWithCapacity:allLayoutAttributes.count];
    for (UICollectionViewLayoutAttributes *layoutAttributes in allLayoutAttributes) {
        NSIndexPath *indexPath = layoutAttributes.indexPath;
        [indexPaths addObject:indexPath];
    }
    return indexPaths;
}
- (NSArray *)assetsAtIndexPaths:(NSArray *)indexPaths
{
    if (indexPaths.count == 0) { return nil; }
    NSMutableArray *assets = [NSMutableArray arrayWithCapacity:indexPaths.count];
    for (NSIndexPath *indexPath in indexPaths) {
        if (indexPath.item < self.phAssetArray.count && indexPath.item != 0) {
            DAPHAsset *asset = self.phAssetArray[self.phAssetArray.count-indexPath.item];
            [assets addObject:asset.asset];
        }
    }
    return assets;
}

//MARK:懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        NSInteger numInLine = 4;
        CGFloat kMargin = 3;
        CGFloat itemWidth = (ZTSCREENW - (numInLine + 1) * kMargin) / numInLine;
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(itemWidth, itemWidth);
        flowLayout.sectionInset = UIEdgeInsetsMake(kMargin, kMargin, kMargin, kMargin);
        flowLayout.minimumLineSpacing = kMargin;
        flowLayout.minimumInteritemSpacing = 0.f;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, ZT_kNavigationBarHeight, ZTSCREENW, ZTSCREENH-ZT_kNavigationBarHeight) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        [_collectionView registerClass:[DAPHAssetCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}
- (PHCachingImageManager *)imageManager
{
    if (_imageManager == nil) {
        _imageManager = [PHCachingImageManager new];
    }
    
    return _imageManager;
}
@end

#pragma mark - ################## DAPHAsset
@implementation DAPHAsset

@end
#pragma mark - ################## DAPHAssetCell
@interface DAPHAssetCell ()

@end

@implementation DAPHAssetCell

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self addSubview:self.imageView];
        [self addSubview:self.overLay];
        self.overLay.hidden = YES;
    }
    return self;
}

#pragma mark - getter
- (UIImageView *)imageView
{
    if (!_imageView) {
        _imageView = [[UIImageView alloc] initWithFrame:self.bounds];
        _imageView.layer.masksToBounds = YES;
        _imageView.clipsToBounds = YES;
        _imageView.contentMode = UIViewContentModeScaleAspectFill;
        _imageView.contentScaleFactor = [[UIScreen mainScreen] scale];
    }
    return _imageView;
}

- (UIImageView *)overLay
{
    if (!_overLay) {
        _overLay = [[UIImageView alloc] initWithFrame:self.bounds];
        _overLay.image = [UIImage imageNamed:@"mmphoto_overlay"];
    }
    return _overLay;
}

#pragma mark - setter
- (void)setSelected:(BOOL)selected
{
    self.overLay.hidden = !selected;
}

- (void)configWithAsset:(PHAsset *)asset isCover:(BOOL)isCover {
    @weakify(self);
//    [DAPhotoUtil getImageWithAsset:asset size:self.bounds.size completion:^(UIImage * _Nonnull image) {
//        @strongify(self);
//        self.imageView.image = image;
//    }];
    if (!isCover) {
        [DAPhotoUtil getImageWithAsset:asset completion:^(NSData * _Nonnull imageData) {
            @strongify(self);
            UIImage *image = [[UIImage alloc]initWithData:imageData];
            
            dispatch_async(dispatch_get_global_queue(0, 0), ^{
                @strongify(self);
                UIImage *image1 = [self smartCompressImage:image];
                dispatch_async(dispatch_get_main_queue(), ^{
                    @strongify(self);
                    self.imageView.image = image1;
                });
            });
        }];
    }else {
        @autoreleasepool {
            NSInteger numInLine = 4;
            CGFloat kMargin = 3;
            CGFloat itemWidth = (ZTSCREENW - (numInLine + 1) * kMargin) / numInLine;

            [DAPhotoUtil getImageWithAsset:asset size:CGSizeMake(itemWidth, itemWidth) completion:^(UIImage * _Nonnull image) {
                @strongify(self);
                self.imageView.image = image;
                image = nil;
            }];

        }
        
    }
}
//- (UIImage *)scaleImageWithData:(NSData *)data withSize:(CGSize)size
//                          scale:(CGFloat)scale
//                    orientation:(UIImageOrientation)orientation {
//
//    CGFloat maxPixelSize = MAX(size.width, size.height);
//    CGImageSourceRef sourceRef = CGImageSourceCreateWithData((__bridge CFDataRef)data, nil);
//    NSDictionary *options = @{(__bridge id)kCGImageSourceCreateThumbnailFromImageAlways:(__bridge id)kCFBooleanTrue,
//                              (__bridge id)kCGImageSourceThumbnailMaxPixelSize:[NSNumber numberWithFloat:maxPixelSize]
//                              };
//    CGImageRef imageRef = CGImageSourceCreateThumbnailAtIndex(sourceRef, 0, (__bridge CFDictionaryRef)options);
//    UIImage *resultImage = [UIImage imageWithCGImage:imageRef scale:scale orientation:orientation];
//    CGImageRelease(imageRef);
//    CFRelease(sourceRef);
//
//    return resultImage;
//}
//- (void)setAsset:(PHAsset *)asset
//{
//    @weakify(self);
//    [DAPhotoUtil getImageWithAsset:asset completion:^(NSData * _Nonnull imageData) {
//        @strongify(self);
//        UIImage *image = [[UIImage alloc]initWithData:imageData];
//        self.imageView.image = [self smartCompressImage:image];
//    }];
//}
- (UIImage *)smartCompressImage:(UIImage *)image {
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
