                                                                                                                                                                                                                                                                                                                                                                                                                                                   //
//  NIPPhotosViewController.m
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPPhotosViewController.h"
#import "NIPPhotoPreviewViewController.h"

#import "NIPAlbumToolbarView.h"
#import "NIPPhotoCell.h"
#import "NIPUIFactory.h"
#import "NIPAlertView.h"

#import "nip_macros.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "UIColor+NIPBasicAdditions.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>

@interface NIPPhotosViewController () <UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout>

@property (nonatomic, strong) UICollectionView *photosCollectionView;
@property (nonatomic, strong) UICollectionViewFlowLayout *collectionViewLayout;

@property (nonatomic, strong) NIPAlbumToolbarView *toolbarView;

@property (nonatomic, assign) CGFloat spacing;
@property (nonatomic, assign) CGFloat cellWidth;

@property (nonatomic, strong) NSMutableArray *selectedPhotoArray;


@end

static NSString * const cellIdentifer = @"photo_cell_id";


@implementation NIPPhotosViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
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
    [self.photosCollectionView reloadData];
    [self.toolbarView setNumber:self.selectedPhotoArray.count animated:NO];
}

- (void)viewDidLayoutSubviews {
    [super viewDidLayoutSubviews];
    NSIndexPath *indexPath = [NSIndexPath indexPathForRow:self.photosArray.count - 1 inSection:0];
    [self.photosCollectionView scrollToItemAtIndexPath:indexPath atScrollPosition:UICollectionViewScrollPositionBottom animated:NO];
}

- (void)initData {
    self.spacing = 5;
    self.cellWidth = ([UIDevice screenWidth] - 5 * _spacing) / 4;
    self.selectedPhotoArray = [NSMutableArray arrayWithCapacity:9];
}

- (void)initViews {
    [self.contentView addSubview:self.photosCollectionView];
    [self.contentView addSubview:self.toolbarView];
}

- (void)addConstraints {
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.toolbarView autoSetDimension:ALDimensionHeight toSize:40];
    
    [self.photosCollectionView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.photosCollectionView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.photosCollectionView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.photosCollectionView autoPinEdge:ALEdgeBottom toEdge:ALEdgeTop ofView:self.toolbarView];
}


#pragma mark - selectors

- (void)cancelButtonPressed:(UIButton *)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

- (void)showPhotoPreviewViewControllerWithType:(NIPPhotoPreviewType)previewType andCurrentIndex:(NSInteger)currentIndex {
    NIPPhotoPreviewViewController *previewController = [NIPPhotoPreviewViewController new];
    previewController.previewType = previewType;
    previewController.currentIndex = currentIndex;
    previewController.availableCount = self.availableCount;
    previewController.selectedPhotosBlock = self.selectedPhotosBlock;
    if (previewType == NIPPhotoPreviewTypePreviewSelected) {
        previewController.photosArray = [self.selectedPhotoArray copy];
        previewController.selectedPhotosArray = self.selectedPhotoArray;
    } else if (previewType == NIPPhotoPreviewTypePreviewAll) {
        previewController.photosArray = self.photosArray;
        previewController.selectedPhotosArray = self.selectedPhotoArray;
    }
    
    [self.navigationController pushViewController:previewController animated:YES];
}

- (void)showHasReachedMaxLimit {
    NSString *message = [NSString stringWithFormat:@"你最多只能选择%ld张照片", (long)self.availableCount];
    [NIPAlertView simpleAlertWithTitle:@""
                               message:message
                             onDismiss:nil];
}


#pragma mark - UICollectionViewDelegate && UICollectionViewDataSource

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section {
    return self.photosArray.count;
}

- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NIPPhotoCell *cell = [collectionView dequeueReusableCellWithReuseIdentifier:cellIdentifer forIndexPath:indexPath];
    cell.asset = self.photosArray[indexPath.row];

    if ([self.selectedPhotoArray indexOfObject:cell.asset] != NSNotFound) {
        cell.isPotoSelected = YES;
    } else {
        cell.isPotoSelected = NO;
    }
    WEAK_SELF(weakSelf)
    cell.canSelectAssetBlock = ^(PHAsset *asset, BOOL isSelected) {
        if (isSelected && weakSelf.selectedPhotoArray.count >= weakSelf.availableCount) {
            [weakSelf showHasReachedMaxLimit];
            return NO;
        } else {
            if (isSelected) {
                if ([weakSelf.selectedPhotoArray indexOfObject:cell.asset] == NSNotFound) {
                    [weakSelf.selectedPhotoArray addObject:asset];
                }
            } else {
                if ([weakSelf.selectedPhotoArray indexOfObject:cell.asset] != NSNotFound) {
                    [weakSelf.selectedPhotoArray removeObject:asset];
                }
            }
            [weakSelf.toolbarView setNumber:weakSelf.selectedPhotoArray.count animated:YES];
            return YES;
        }
    };
    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    
    [self showPhotoPreviewViewControllerWithType:NIPPhotoPreviewTypePreviewAll andCurrentIndex:indexPath.row];
}


#pragma mark - Setters && Getters

- (UICollectionView *)photosCollectionView {
    if (!_photosCollectionView) {
        _photosCollectionView = [[UICollectionView alloc] initWithFrame:CGRectZero collectionViewLayout:self.collectionViewLayout];
        _photosCollectionView.backgroundColor = [UIColor colorWithHexRGB:0xeeeeee];
        _photosCollectionView.showsVerticalScrollIndicator = NO;
        _photosCollectionView.dataSource = self;
        _photosCollectionView.delegate = self;
        
        [_photosCollectionView registerClass:[NIPPhotoCell class] forCellWithReuseIdentifier:cellIdentifer];
    }
    return _photosCollectionView;
}

- (UICollectionViewFlowLayout *)collectionViewLayout {
    if (!_collectionViewLayout) {
        _collectionViewLayout = [[UICollectionViewFlowLayout alloc] init];
        //该方法也可以设置itemSize
        _collectionViewLayout.sectionInset = UIEdgeInsetsMake(_spacing, _spacing, _spacing, _spacing);
        _collectionViewLayout.itemSize =CGSizeMake(self.cellWidth, self.cellWidth);
        _collectionViewLayout.minimumLineSpacing = self.spacing;
        _collectionViewLayout.minimumInteritemSpacing = self.spacing;
    }
    return _collectionViewLayout;
}

- (NIPAlbumToolbarView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[NIPAlbumToolbarView alloc] init];
        WEAK_SELF(weakSelf)
        _toolbarView.previewBlock = ^ {
            [weakSelf showPhotoPreviewViewControllerWithType:NIPPhotoPreviewTypePreviewSelected andCurrentIndex:0];
        };
        
        _toolbarView.doneBlock = ^ {
            if (weakSelf.selectedPhotosBlock) {
                weakSelf.selectedPhotosBlock(weakSelf.selectedPhotoArray);
                [weakSelf cancelButtonPressed:nil];
            }
        };
    }
    
    return _toolbarView;
}

@end
