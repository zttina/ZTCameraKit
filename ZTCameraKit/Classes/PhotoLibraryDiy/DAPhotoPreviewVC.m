//
//  DAPhotoPreviewVC.m
//  TechnicianApp
//
//  Created by zt on 2019/3/23.
//  Copyright © 2019年 Captain. All rights reserved.
//

#import "DAPhotoPreviewVC.h"
#import "DAPhotoUtil.h"
#import "ZTCameraKitHeader.h"
@interface DAPhotoPreviewVC ()<UICollectionViewDelegate,UICollectionViewDataSource>

@property (nonatomic,strong) UIButton *navBackBtn;//左上角返回相册的按钮
@property (nonatomic,strong) UIButton *confirmBtn;//右下角确定按钮
@property (nonatomic, strong) UICollectionView * collectionView;//相册的collectionView



@end

@implementation DAPhotoPreviewVC


- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor blackColor];
    [self.view addSubview:self.collectionView];
    [self.collectionView scrollToItemAtIndexPath:[NSIndexPath indexPathForRow:self.currentIndex inSection:0] atScrollPosition:UICollectionViewScrollPositionCenteredHorizontally animated:NO];
    
    [self createTopView];
    [self createBottomView];
    
//    self.navigationItem.title = [NSString stringWithFormat:@"%ld/%d",(long)self.currentIndex,self.assetArray.count];
}
- (void)createBottomView {
    UIView *bottomView = [[UIView alloc]initWithFrame:CGRectMake(0, ZTSCREENH - ZT_TAB_BAR_HEIGHT, ZTSCREENW, ZT_TAB_BAR_HEIGHT)];
    [self.view addSubview:bottomView];
    bottomView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    
    self.confirmBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [bottomView addSubview:self.confirmBtn];
    [self.confirmBtn addTarget:self action:@selector(confirmThesePhotos:) forControlEvents:UIControlEventTouchUpInside];
    self.confirmBtn.frame = CGRectMake(ZTSCREENW - 60 - 10, 10, 60, 29);
    self.confirmBtn.layer.cornerRadius = 5;
//    [self.confirmBtn gradientLayerWithColor:gradient1 color2:gradient2];
    [self.confirmBtn setTitle:@"确定" forState:UIControlStateNormal];
    [self.confirmBtn setTitleColor:[UIColor whiteColor] forState:UIControlStateNormal];
    self.confirmBtn.titleLabel.font = [UIFont systemFontOfSize:14];

}

- (void)createTopView {
    
    UIView *topView = [[UIView alloc]initWithFrame:CGRectMake(0, 0, ZTSCREENW, ZT_kNavigationBarHeight)];
    [self.view addSubview:topView];
    topView.backgroundColor = [[UIColor blackColor]colorWithAlphaComponent:0.5];
    
    
    self.navBackBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [topView addSubview:self.navBackBtn];
    [self.navBackBtn setImage:[UIImage imageNamed:@"arrow-left"] forState:UIControlStateNormal];
    self.navBackBtn.frame = CGRectMake(10, ZT_kNavigationBarHeight - 64 + 20, 30, 30);
    [self.navBackBtn addTarget:self action:@selector(backToView) forControlEvents:UIControlEventTouchUpInside];
}
//MARK:button点击事件
- (void)backToView {
 
    [self dismissViewControllerAnimated:YES completion:nil];
}
- (void)confirmThesePhotos:(UIButton *)btn {
    //判断当前index
    NSInteger currentIndex = self.collectionView.contentOffset.x / ZTSCREENW;
    DAPHAsset *asset = self.assetArray[currentIndex];
    @weakify(self);
    [DAPhotoUtil getImageWithAsset:asset.asset completion:^(NSData *imageData) {
        @strongify(self);
        if (self.selectImageBlock) {
            UIImage *image = [[UIImage alloc]initWithData:imageData];
            self.selectImageBlock(image);
        }
    }];
}

#pragma mark - UICollectionViewDataSource
- (NSInteger)numberOfSectionsInCollectionView:(UICollectionView *)collectionView
{
    return 1;
}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section
{
    return self.assetArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath
{
    DAPHAsset * mmAsset = [self.assetArray objectAtIndex:indexPath.row];
    // 赋值
    DAPHAssetCell * cell = [collectionView dequeueReusableCellWithReuseIdentifier:@"cell" forIndexPath:indexPath];
//    cell.asset = mmAsset.asset;
    [cell configWithAsset:mmAsset.asset isCover:NO];
    cell.imageView.contentMode = UIViewContentModeScaleAspectFit;
    cell.selected = mmAsset.isSelected;
    return cell;
}

#pragma mark - UICollectionViewDelegate
- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath
{
//    [collectionView deselectItemAtIndexPath:indexPath animated:YES];
//    //    DAPHAsset * mmAsset = [self.phAssetArray objectAtIndex:indexPath.row];
//    //    PHAsset * asset = mmAsset.asset;
//    DAPhotoPreviewVC *previewVC = [[DAPhotoPreviewVC alloc]init];
//    previewVC.assetArray = self.assetArray;
//    previewVC.currentIndex = indexPath.row;
//    previewVC.modalPresentationStyle = UIModalPresentationOverCurrentContext;
//    previewVC.modalTransitionStyle = UIModalTransitionStyleCrossDissolve;
//    [self presentViewController:previewVC animated:YES completion:nil];
    
}
//MARK:懒加载
- (UICollectionView *)collectionView
{
    if (!_collectionView) {
        
        UICollectionViewFlowLayout * flowLayout = [[UICollectionViewFlowLayout alloc] init];
        flowLayout.itemSize = CGSizeMake(ZTSCREENW, ZTSCREENH);
        flowLayout.sectionInset = UIEdgeInsetsMake(0, 0, 0, 0);
        flowLayout.minimumLineSpacing = 0;
        flowLayout.minimumInteritemSpacing = 0.f;
        flowLayout.scrollDirection = UICollectionViewScrollDirectionHorizontal;
        
        _collectionView = [[UICollectionView alloc]initWithFrame:CGRectMake(0, 0, ZTSCREENW, ZTSCREENH) collectionViewLayout:flowLayout];
        _collectionView.backgroundColor = [UIColor clearColor];
        _collectionView.delegate = self;
        _collectionView.dataSource = self;
        _collectionView.scrollEnabled = YES;
        _collectionView.pagingEnabled = YES;
        [_collectionView registerClass:[DAPHAssetCell class] forCellWithReuseIdentifier:@"cell"];
    }
    return _collectionView;
}

@end

