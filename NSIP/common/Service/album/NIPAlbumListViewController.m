//
//  NIPAlbumListViewController.m
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPAlbumListViewController.h"
#import "NIPPhotosViewController.h"
#import "NIPUIFactory.h"
#import "NIPAlbumInfo.h"
#import "NIPAlbumCell.h"

#import "nip_macros.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import "UIDevice+NIPBasicAdditions.h"

@interface NIPAlbumListViewController () <UITableViewDelegate, UITableViewDataSource>

@property (nonatomic, strong) UITableView *albumListView;

@property (nonatomic, strong) NSMutableArray *albumListArray;
@property (nonatomic, strong) NSMutableArray *photosArrayContainer;

@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;

@property (nonatomic, assign) BOOL hasPushedDefaultController;

@property (nonatomic, copy) void(^assetsInfoLoadCompletedBlock)(void);

@end


static NSString * const cellIdentifer = @"album_cell_id";


@implementation NIPAlbumListViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    self.title = @"相册";
    
    [self initData];
    [self initViews];
    [self addConstraints];
    self.naviRightView = [NIPUIFactory buttonWithWhiteTitle:@"取消"
                                                   fontSize:15
                                                     target:self
                                                   selector:@selector(cancelButtonPressed:)];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    WEAK_SELF(weakSelf)
    [self loadAssetsInfoOnComplete:^ {
        [weakSelf.albumListView reloadData];
        if (!weakSelf.hasPushedDefaultController) {
            weakSelf.hasPushedDefaultController = YES;
            [weakSelf showDefaultPhotosViewController];
        }
    }];
}

- (void)initData {
    self.albumListArray = [NSMutableArray array];
    self.photosArrayContainer = [NSMutableArray array];
}

- (void)initViews {
    [self.contentView addSubview:self.albumListView];
}

- (void)addConstraints {
    [self.albumListView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.albumListView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.albumListView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.albumListView autoPinEdgeToSuperviewEdge:ALEdgeRight];
}

- (void)loadAssetsInfoOnComplete:(void (^)(void))completedBlock {
    [self.albumListArray removeAllObjects];
    [self.photosArrayContainer removeAllObjects];
    self.assetsInfoLoadCompletedBlock = completedBlock;
    if ([UIDevice systemMainVersion] >=.0 ) {
        [self getAlbumInfoOnDevicesSystemVersionBeyondIOS8];
    } else {
        [self getAlbumInfoOnDevicesSystemVersionBelowIOS8];
    }
}

- (void)getAlbumInfoOnDevicesSystemVersionBeyondIOS8 {
    // 获取相机胶卷
    PHFetchResult<PHAssetCollection *> *cameraCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumUserLibrary options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:cameraCollections];
    
    // 获取全景
    PHFetchResult<PHAssetCollection *> *panoramaCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumPanoramas options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:panoramaCollections];
    
    // 获取个人收藏
    PHFetchResult<PHAssetCollection *> *favoriteCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumFavorites options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:favoriteCollections];
    
    // 获取最近添加
    PHFetchResult<PHAssetCollection *> *recentlyAddedCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumRecentlyAdded options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:recentlyAddedCollections];
    
    // 获取连拍快照
    PHFetchResult<PHAssetCollection *> *burstsCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumBursts options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:burstsCollections];
    
    if ([UIDevice systemMainVersion] >= 9) {
        // 获取自拍
        PHFetchResult<PHAssetCollection *> *selfPortraitCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumSelfPortraits options:nil];
        [self configDataSourceWithAssetsCollectionFetchResult:selfPortraitCollections];
        
        // 获取屏幕快照
        PHFetchResult<PHAssetCollection *> *screenshotCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeSmartAlbum subtype:PHAssetCollectionSubtypeSmartAlbumScreenshots options:nil];
        [self configDataSourceWithAssetsCollectionFetchResult:screenshotCollections];
    }
    
    // 获得自定义相册
    PHFetchResult<PHAssetCollection *> *userCollections = [PHAssetCollection fetchAssetCollectionsWithType:PHAssetCollectionTypeAlbum subtype:PHAssetCollectionSubtypeAlbumRegular options:nil];
    [self configDataSourceWithAssetsCollectionFetchResult:userCollections];
    if (self.assetsInfoLoadCompletedBlock) {
        self.assetsInfoLoadCompletedBlock();
    }
}

- (void)getAlbumInfoOnDevicesSystemVersionBelowIOS8 {
    self.assetsLibrary = [[ALAssetsLibrary alloc] init];
    WEAK_SELF(weakSelf)
    [_assetsLibrary enumerateGroupsWithTypes:ALAssetsGroupAll usingBlock:^(ALAssetsGroup *group, BOOL *stop) {
        if (group) {
            NIPAlbumInfo *albumInfo = [NIPAlbumInfo new];
            albumInfo.albumTitle = [group valueForProperty:ALAssetsGroupPropertyName];
            albumInfo.albumPhotoCount = group.numberOfAssets;
            albumInfo.albumThumbnailImage = [UIImage imageWithCGImage:group.posterImage];
            [weakSelf.albumListArray addObject:albumInfo];
            
            NSMutableArray *photosArray = [NSMutableArray arrayWithCapacity:group.numberOfAssets];
            [group setAssetsFilter:[ALAssetsFilter allPhotos]];
            [group enumerateAssetsUsingBlock:^(ALAsset *result, NSUInteger index, BOOL *stop) {
                if (result) {
                    [photosArray addObject:result];
                }
            }];
            [weakSelf.photosArrayContainer addObject:photosArray];
        } else {
            if (weakSelf.albumListArray.count > 1) {
                NIPAlbumInfo *cameraAlbumInfo = [weakSelf.albumListArray lastObject];
                [weakSelf.albumListArray removeLastObject];
                [weakSelf.albumListArray insertObject:cameraAlbumInfo atIndex:0];
                
                NSMutableArray *cameraPhotosArray = [weakSelf.photosArrayContainer lastObject];
                [weakSelf.photosArrayContainer removeLastObject];
                [weakSelf.photosArrayContainer insertObject:cameraPhotosArray atIndex:0];
            }
            
            if (weakSelf.assetsInfoLoadCompletedBlock) {
                weakSelf.assetsInfoLoadCompletedBlock();
            }
            [weakSelf.albumListView reloadData];
        }
    } failureBlock:^(NSError *error) {
        NSLog(@"%@", error.localizedDescription);
    }];
}

- (void)configDataSourceWithAssetsCollectionFetchResult:(PHFetchResult<PHAssetCollection *> *)fetchResult {
    for (PHAssetCollection *assetCollection in fetchResult) {
        PHFetchResult<PHAsset *> *assets = [PHAsset fetchAssetsInAssetCollection:assetCollection options:nil];
        
        NIPAlbumInfo *albumInfo = [NIPAlbumInfo new];
        albumInfo.albumTitle = assetCollection.localizedTitle;
        albumInfo.albumPhotoCount = assets.count;
        
        NSMutableArray *photosArray = [NSMutableArray arrayWithCapacity:assets.count];
        if (assets.count) {
            NSInteger lastIndex = assets.count - 1;
            [assets enumerateObjectsUsingBlock:^(PHAsset * _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
                [photosArray addObject:obj];
                if (idx == lastIndex) {
                    PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
                    options.synchronous = YES;
                    [[PHImageManager defaultManager] requestImageForAsset:obj
                                                               targetSize:CGSizeZero  //获取缩略图
                                                              contentMode:PHImageContentModeDefault
                                                                  options:options
                                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                                albumInfo.albumThumbnailImage = [result copy];
                                                            }];
                }
            }];
        }
        [self.albumListArray addObject:albumInfo];
        [self.photosArrayContainer addObject:photosArray];
    }
}


#pragma mark - 页面跳转

- (void)showDefaultPhotosViewController {
    if (self.albumListArray.count && self.photosArrayContainer.count) {
        NIPAlbumInfo *albumInfo = self.albumListArray[0];
        [self showPhotosViewControllerWithTitle:albumInfo.albumTitle andPhotosArray:self.photosArrayContainer[0] animated:NO];
    }
}

- (void)showPhotosViewControllerWithTitle:(NSString *)title andPhotosArray:(NSArray *)photosArray animated:(BOOL)animated {
    NIPPhotosViewController *photosViewController = [[NIPPhotosViewController alloc] init];
    photosViewController.photosArray = photosArray;
    photosViewController.title = title;
    photosViewController.availableCount = self.availableCount;
    photosViewController.selectedPhotosBlock = self.selectedPhotosBlock;
    [self.navigationController pushViewController:photosViewController animated:animated];
}


#pragma mark - selectors

- (void)cancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - UITableViewDelegate && UITableViewDataSource

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return self.albumListArray.count;
}

- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    NIPAlbumCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifer forIndexPath:indexPath];

    NIPAlbumInfo *albumInfo = self.albumListArray[indexPath.row];
    cell.albumInfo = albumInfo;
    
    return cell;
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    NIPAlbumInfo *albumInfo = self.albumListArray[indexPath.row];
    [self showPhotosViewControllerWithTitle:albumInfo.albumTitle andPhotosArray:self.photosArrayContainer[indexPath.row] animated:YES];
}


#pragma mark - Setters && Getters

- (UITableView *)albumListView {
    if (!_albumListView) {
        _albumListView = [[UITableView alloc] initWithFrame:CGRectZero style:UITableViewStylePlain];
        _albumListView.dataSource = self;
        _albumListView.delegate = self;
        
        [_albumListView registerClass:[NIPAlbumCell class] forCellReuseIdentifier:cellIdentifer];
    }
    
    return _albumListView;
}



@end
