//
//  ZTPhotoLibraryVC.m
//  ZTCameraKit
//
//  Created by zttina on 2019/3/22.
//  Copyright © 2019年 zttina. All rights reserved.
//

#import "ZTPhotoLibraryVC.h"
#import "ZTPhotoUtil.h"
#import "ZTPhotoAssetVC.h"
#define RowHeight 60.f

@interface ZTPhotoLibraryVC ()<UITableViewDelegate,UITableViewDataSource>

@property (nonatomic,strong) NSMutableArray *photoAlbums;//存相册的数组
@property (nonatomic,strong) ZTPhotoAlbums *selectPhotoAlbum;//当前选择的相册
@property (nonatomic,strong) UITableView *tableView;//相册列表
@end

@implementation ZTPhotoLibraryVC

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    self.title = @"照片";
    self.navigationItem.rightBarButtonItem = [[UIBarButtonItem alloc] initWithTitle:@"取消" style:UIBarButtonItemStylePlain target:self action:@selector(barButtonItemAction:)];

    [self.view addSubview:self.tableView];
    @weakify(self);
    // 相册权限
    PHAuthorizationStatus oldStatus = [PHPhotoLibrary authorizationStatus];
    [PHPhotoLibrary requestAuthorization:^(PHAuthorizationStatus status) {
        @strongify(self);
        switch (status) {
            case PHAuthorizationStatusAuthorized: { // 权限打开
                [self loadAlbumData]; // 加载相册
                break;
            }
            case PHAuthorizationStatusDenied: // 权限拒绝
            case PHAuthorizationStatusRestricted: { // 权限受限
                if (oldStatus == PHAuthorizationStatusNotDetermined) {
                    [self barButtonItemAction:nil]; // 返回
                    return;
                }
                UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"提示"
                                                                message:@"请在设置>隐私>照片中开启权限"
                                                               delegate:self
                                                      cancelButtonTitle:@"知道了"
                                                      otherButtonTitles:nil, nil];
                [alert show];
                break;
            }
            default:
                break;
        }
    }];
}
//MARK:加载相册
- (void)loadAlbumData {
    @weakify(self);
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
//        [MBProgressHUD showHUDAddedTo:self.view animated:YES];
    });
    self.photoAlbums = [[NSMutableArray alloc] init];
    //获取智能相册
    PHFetchResult *smartAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [smartAlbums enumerateObjectsUsingBlock:^(PHAssetCollection *collection, NSUInteger idx, BOOL * _Nonnull stop) {
        //过滤掉隐藏，视频，最近删除，
        if (collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumAllHidden &&
            collection.assetCollectionSubtype != 1000000201 &&
            collection.assetCollectionSubtype != PHAssetCollectionSubtypeSmartAlbumVideos) {
            NSArray<PHAsset *> *assets = [ZTPhotoUtil getAllAssetWithAssetCollection:collection ascending:YES];
            //不显示空相册
            if ([assets count]) {
                ZTPhotoAlbums *album = [[ZTPhotoAlbums alloc] init];
                album.name = collection.localizedTitle;
                album.assetCount = assets.count;
                album.collection = collection;
                album.coverAsset = assets.firstObject;
                // '所有照片'置顶
                if (collection.assetCollectionSubtype == PHAssetCollectionSubtypeSmartAlbumUserLibrary) {
                    [self.photoAlbums insertObject:album atIndex:0];
                    _selectPhotoAlbum = album;
                } else {
                    [self.photoAlbums addObject:album];
                }
            }
        }
    }];
    
    // 获取用户创建相册
    PHFetchResult * userAlbums = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [userAlbums enumerateObjectsUsingBlock:^(PHAssetCollection * _Nonnull collection, NSUInteger idx, BOOL * _Nonnull stop) {
        NSArray<PHAsset *> * assets = [ZTPhotoUtil getAllAssetWithAssetCollection:collection ascending:NO];
        if (assets.count > 0) {
            ZTPhotoAlbums * album = [[ZTPhotoAlbums alloc] init];
            album.name = collection.localizedTitle;
            album.assetCount = assets.count;
            album.coverAsset = assets.firstObject;
            album.collection = collection;
            [self.photoAlbums addObject:album];
        }
    }];
    dispatch_async(dispatch_get_main_queue(), ^{
        @strongify(self);
//        [MBProgressHUD hideHUDForView:self.view animated:YES];
        [self.tableView reloadData];
        // 跳转
//        [self pushAlbumByPhotoAlbum:_selectPhotoAlbum animated:NO];

    });
   

    
}

#pragma mark - 取消
- (void)barButtonItemAction:(UIButton *)sender
{
    if (self.cancelBlock) {
        self.cancelBlock();
    }else {
        [self dismissViewControllerAnimated:YES completion:nil];
    }
}
//MARK:懒加载
- (UITableView *)tableView {
    if (!_tableView) {
        _tableView = [[UITableView alloc] initWithFrame:CGRectMake(0, ZT_kNavigationBarHeight, ZTSCREENW, ZTSCREENH-ZT_kNavigationBarHeight) style:UITableViewStyleGrouped];
        _tableView.delegate = self;
        _tableView.dataSource = self;
        _tableView.rowHeight = RowHeight;
        _tableView.showsHorizontalScrollIndicator = NO;
        _tableView.backgroundColor = [UIColor clearColor];
        _tableView.separatorColor = [[UIColor lightGrayColor] colorWithAlphaComponent:0.5];
        _tableView.tableFooterView = [UIView new];
        _tableView.estimatedRowHeight = 0;
        _tableView.estimatedSectionHeaderHeight = 0;
        _tableView.estimatedSectionFooterHeight = 0;
        if (@available(iOS 11.0, *)) {
            _tableView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
        }
    }
    return _tableView;
}
#pragma mark - UITableViewDataSource
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.photoAlbums count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * CellIdentifier = @"Cell";
    ZTPhotoAlbumCell * cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    if (cell == nil) {
        cell = [[ZTPhotoAlbumCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier];
    }
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    cell.selectionStyle = UITableViewCellSelectionStyleGray;
    cell.libraryNameLabel.textColor = [UIColor grayColor];
    // 封面
    ZTPhotoAlbums * album = [self.photoAlbums objectAtIndex:indexPath.row];
    if (album.coverAsset) {
        @weakify(cell);
        [ZTPhotoUtil getImageWithAsset:album.coverAsset size:CGSizeMake(RowHeight, RowHeight) completion:^(UIImage * _Nonnull image) {
            @strongify(cell);
            cell.iconImageView.image = image;

        }];
    } else {
        cell.iconImageView.image = [UIImage imageNamed:@""];
    }
    // 数量
    NSString * text = [NSString stringWithFormat:@"%@  (%ld)",album.name, (long)album.assetCount];
    NSMutableAttributedString * attributedText = [[NSMutableAttributedString alloc] initWithString:text];
    [attributedText addAttribute:NSForegroundColorAttributeName value:[UIColor blackColor] range:NSMakeRange(0,[album.name length])];
    [attributedText addAttribute:NSFontAttributeName value:[UIFont boldSystemFontOfSize:17.0] range:NSMakeRange(0,[album.name length])];
    cell.libraryNameLabel.attributedText = attributedText;
    return cell;
}

#pragma mark - UITableViewDelegate
- (CGFloat)tableView:(UITableView *)tableView heightForHeaderInSection:(NSInteger)section
{
    return 0.1f;
}

- (UIView *)tableView:(UITableView *)tableView viewForHeaderInSection:(NSInteger)section
{
    return nil;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    // 跳转
    ZTPhotoAlbums *photoAlbum = [self.photoAlbums objectAtIndex:indexPath.row];
    [self pushAlbumByPhotoAlbum:photoAlbum animated:YES];
}

#pragma mark - 跳转
- (void)pushAlbumByPhotoAlbum:(ZTPhotoAlbums *)photoAlbum animated:(BOOL)animated
{
    
    ZTPhotoAssetVC *assetVC = [ZTPhotoAssetVC new];
    assetVC.photoAlbum = photoAlbum;
    @weakify(self);
    assetVC.imageBlock = ^(UIImage *image) {
        @strongify(self);
//        [self.navigationController popToRootViewControllerAnimated:YES];
        if (self.imageBlock) {
            self.imageBlock(image);
        }
    };
    [self.navigationController pushViewController:assetVC animated:animated];

}

@end

//MARK:相册
@implementation ZTPhotoAlbums

@end
#pragma mark - ################## ZTPhotoAlbumCell
@implementation ZTPhotoAlbumCell

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    
    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
        [self createUI];
    }
    return self;
}
- (void)createUI {
    self.iconImageView = [[UIImageView alloc]initWithFrame:CGRectMake(0, 0, RowHeight, RowHeight)];
    self.iconImageView.contentMode = UIViewContentModeScaleAspectFill;
    [self.contentView addSubview:self.iconImageView];
    self.iconImageView.clipsToBounds = YES;
    
    self.libraryNameLabel = [[UILabel alloc]initWithFrame:CGRectMake(CGRectGetMaxX(self.iconImageView.frame) + 10, 0, self.frame.size.width - RowHeight - 40, RowHeight)];
    [self.contentView addSubview:self.libraryNameLabel];
    self.separatorInset = UIEdgeInsetsZero;
}

@end
