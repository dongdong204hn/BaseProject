//
//  NIPPhotoPreviewViewController.m
//  NSIP
//
//  Created by Eric on 2016/12/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPPhotoPreviewViewController.h"
#import "NIPAlbumToolbarView.h"
#import "NIPAlertView.h"
#import "NIPUIFactoryChild.h"
#import "UIColor+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "UIImage+NIPBasicAdditions.h"
#import "nip_macros.h"


#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


#define BASE_TAG 10

@interface NIPPhotoPreviewViewController () <UIScrollViewDelegate>

@property (nonatomic, strong) NIPAlbumToolbarView *toolbarView;

@property (nonatomic, strong) UIImageView *checkImageView;

@property (nonatomic, strong) UIScrollView *previewScrollView;

@property (nonatomic, strong) NSMutableDictionary *loadInfoMap;

@property (nonatomic, assign) NSInteger actualIndex;


@end

@implementation NIPPhotoPreviewViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.contentView.backgroundColor = [UIColor blackColor];
    self.naviRightView = self.checkImageView;
    [self initViews];
    [self addConstraints];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
     [NIPUIFactoryChild setNormalBackgroundImage:[UIImage imageWithColor:[UIColor colorWithIntegerR:50 g:50 b:50 a:0.5] size:CGSizeMake([UIDevice screenWidth], 64)] toNavigationBar:self.navigationController.navigationBar];
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    [self updatePreviewScrollViewInfo];
    [self updateScrollView:self.previewScrollView forCurrentPage:self.currentIndex byDefault:YES];
}


#pragma mark - UI control

- (void)initViews {
    [self.contentView addSubview:self.previewScrollView];
    [self.contentView addSubview:self.toolbarView];
}

- (void)addConstraints {
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.toolbarView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.toolbarView autoSetDimension:ALDimensionHeight toSize:40];
}


#pragma mark - 手势管理

- (void)addGestureRecognizer {
    UITapGestureRecognizer *tapGestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(handleTapGestureRecognizer:)];
    [self.previewScrollView addGestureRecognizer:tapGestureRecognizer];
    UIPinchGestureRecognizer *pinchGestureRecognizer = [[UIPinchGestureRecognizer alloc] initWithTarget:self action:@selector(handlePinchGestureRecognizer:)];
    [self.previewScrollView addGestureRecognizer:pinchGestureRecognizer];
    
}

- (void)handleTapGestureRecognizer:(UITapGestureRecognizer *)tapGestureRecognizer {
    if (tapGestureRecognizer.numberOfTouches == 1) {
        self.toolbarView.hidden = !self.toolbarView.hidden;
        self.navigationController.navigationBar.hidden = !self.navigationController.navigationBar.hidden;
    } else if (tapGestureRecognizer.numberOfTouches == 2) {
        
    }
}

- (void)handlePinchGestureRecognizer:(UIPinchGestureRecognizer *)pinchGestureRecognizer {
    
}


#pragma mark - selectors

- (void)checkImageViewTapped:(id)sender {
    if (self.selectedPhotosArray.count >= self.availableCount && !_checkImageView.highlighted) {
        [self showHasReachedMaxLimit];
    } else {
        _checkImageView.highlighted = !_checkImageView.highlighted;
        if (_checkImageView.highlighted) {
            [self.selectedPhotosArray addObject:self.photosArray[_currentIndex]];
        } else {
            [self.selectedPhotosArray removeObject:self.photosArray[_currentIndex]];
        }
        [self.toolbarView setNumber:self.selectedPhotosArray.count animated:YES];
    }
}

- (void)showHasReachedMaxLimit {
    NSString *message = [NSString stringWithFormat:@"你最多只能选择%ld张照片", (long)self.availableCount];
    [NIPAlertView simpleAlertWithTitle:@""
                               message:message
                             onDismiss:nil];
}

- (void)cancelButtonPressed:(id)sender {
    [self.navigationController dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - scrollview 管理

- (void)updatePreviewScrollViewInfo {
        if ([UIDevice systemMainVersion] >= 8.0) {
            [self updatePreviewScrollViewInfoForSystemVersionBeyondIOS8];
        } else {
            [self updatePreviewScrollViewInfoForSystemVersionBelowIOS8];
        }
    
    
}

- (void)updatePreviewScrollViewInfoForSystemVersionBeyondIOS8 {
    if (_photosArray.count <= 9) {
        self.previewScrollView.contentSize = CGSizeMake(self.view.width * _photosArray.count, self.view.height);
        WEAK_SELF(weakSelf)
        [_photosArray enumerateObjectsUsingBlock:^(PHAsset*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:weakSelf.view.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            // 从asset中获得图片
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            WEAK_SELF(weakSelf)
            [[PHImageManager defaultManager] requestImageForAsset:obj targetSize:CGSizeZero contentMode:PHImageContentModeDefault options:options resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                imageView.image = [result copy];
            }];
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:weakSelf.view.bounds];
            scrollView.left = idx * weakSelf.view.width;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            [scrollView addSubview:imageView];
            scrollView.tag = idx + BASE_TAG;
            [weakSelf.previewScrollView addSubview:scrollView];
        }];
    } else {
        self.previewScrollView.contentSize = CGSizeMake(self.view.width * 9, self.view.height);
        for (NSInteger index = 0; index <= 9; index ++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
            scrollView.left = index * self.view.width;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            [scrollView addSubview:imageView];
            scrollView.tag = index + BASE_TAG;
            [self.previewScrollView addSubview:scrollView];
        }
    }
}

- (void)updatePreviewScrollViewInfoForSystemVersionBelowIOS8 {
    if (_photosArray.count <= 9) {
        self.previewScrollView.contentSize = CGSizeMake(self.view.width * _photosArray.count, self.view.height);
        WEAK_SELF(weakSelf)
        [_photosArray enumerateObjectsUsingBlock:^(ALAsset*  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:weakSelf.view.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
           imageView.image = [UIImage imageWithCGImage:obj.aspectRatioThumbnail];
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:weakSelf.view.bounds];
            scrollView.left = idx * weakSelf.view.width;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            [scrollView addSubview:imageView];
            scrollView.tag = idx + BASE_TAG;
            [weakSelf.previewScrollView addSubview:scrollView];
        }];
    } else {
        self.previewScrollView.contentSize = CGSizeMake(self.view.width * 9, self.view.height);
        for (NSInteger index = 0; index <= 9; index ++) {
            UIImageView *imageView = [[UIImageView alloc] initWithFrame:self.view.bounds];
            imageView.contentMode = UIViewContentModeScaleAspectFit;
            UIScrollView *scrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
            scrollView.left = index * self.view.width;
            scrollView.showsHorizontalScrollIndicator = NO;
            scrollView.showsVerticalScrollIndicator = NO;
            [scrollView addSubview:imageView];
            scrollView.tag = index + BASE_TAG;
            [self.previewScrollView addSubview:scrollView];
        }
    }
}

- (void)updateScrollView:(UIScrollView *)scrollView forCurrentPage:(NSInteger)currentPage byDefault:(BOOL)byDefault {
    if (self.photosArray.count > 9) {
        if (currentPage != self.actualIndex || byDefault) {
            NSInteger changedIndex = 0;
            if (!byDefault) {
                changedIndex = currentPage - self.actualIndex;
                self.currentIndex += changedIndex;
            }
            
            if ((self.currentIndex == 4 && changedIndex > 0)||
                (self.currentIndex == self.photosArray.count - 5 && changedIndex < 0)) {
                if (byDefault) {
                    self.actualIndex = 4;
                    scrollView.contentOffset = CGPointMake(4 * scrollView.width, scrollView.contentOffset.y);
                } else {
                    self.actualIndex = currentPage;
                }
            } else if (self.currentIndex > 3 && self.currentIndex < self.photosArray.count - 4) {
                self.actualIndex = 4;
                scrollView.contentOffset = CGPointMake(4*scrollView.width, scrollView.contentOffset.y);
            } else {
                if (byDefault) {
                    NSInteger actualIndex = self.currentIndex < 5 ? self.currentIndex : self.currentIndex + 9 - self.photosArray.count;
                    self.actualIndex = actualIndex;
                    scrollView.contentOffset = CGPointMake(actualIndex * scrollView.width, scrollView.contentOffset.y);
                   
                } else {
                    self.actualIndex = currentPage;
                }
            }
            [self updateCurrentPreviewPhotoForIndex:self.currentIndex];
        }
    } else {
        if (byDefault) {
            [scrollView setContentOffset:CGPointMake(self.currentIndex * scrollView.width, scrollView.contentOffset.y)
                                animated:NO];
            [self updateCurrentPreviewPhotoForIndex:self.currentIndex];
        } else {
            if (currentPage != self.currentIndex) {
                self.currentIndex = currentPage;
                [scrollView setContentOffset:CGPointMake(self.currentIndex * scrollView.width, scrollView.contentOffset.y)
                                    animated:NO];
                [self updateCurrentPreviewPhotoForIndex:self.currentIndex];
            }
        }
    }
}

- (void)updateCurrentPreviewPhotoForIndex:(NSInteger)index {
    if (index > self.photosArray.count-1) {
        return;
    }
    [self updateCheckImageStatusForIndex:index];
    if ([UIDevice systemMainVersion] >=.0) {
        [self updateCurrentPreviewPhotoOnSystemVersionBeyondIOS8ForIndex:index];
    } else {
        [self updateCurrentPreviewPhotoOnSystemVersionBelowIOS8ForIndex:index];
    }
}

- (void)updateCheckImageStatusForIndex:(NSInteger)index {
    id asset = self.photosArray[index];
    if ([self.selectedPhotosArray containsObject:asset]) {
        self.checkImageView.highlighted = YES;
    } else {
        self.checkImageView.highlighted = NO;
    }
}

- (void)updateCurrentPreviewPhotoOnSystemVersionBeyondIOS8ForIndex:(NSInteger)index {
    if (self.photosArray.count <= 9) {
        if (![self.loadInfoMap[@(index)] boolValue]) {
            self.loadInfoMap[@(index)] = [NSNumber numberWithBool:YES];
            [self loadHighQualityPreviewPhotoForIndex:index];
        }
    } else {
        NSInteger startIndex = 0;
        NSInteger endIndex = startIndex + 8;
        if (self.currentIndex > 3 && self.currentIndex < self.photosArray.count - 4) {
            startIndex = self.currentIndex - 4;
            endIndex = startIndex + 8;
            
        } else if (self.currentIndex >= self.photosArray.count - 4) {
            endIndex = self.photosArray.count - 1;
            startIndex = endIndex - 8;
            
        }
        for (NSInteger index = startIndex; index <= endIndex; index ++) {
            UIScrollView *scrollView = [self.previewScrollView viewWithTag:BASE_TAG + index - startIndex];
            UIImageView *imageView = [scrollView.subviews lastObject];
            PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
            [[PHImageManager defaultManager] requestImageForAsset:self.photosArray[index]
                                                       targetSize:index == _currentIndex ? self.view.size: CGSizeZero
                                                      contentMode:PHImageContentModeDefault
                                                          options:options
                                                    resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
                                                        imageView.image = [result copy];
                                                    }];
        }
    }
}

- (void)updateCurrentPreviewPhotoOnSystemVersionBelowIOS8ForIndex:(NSInteger)index {
    if (self.photosArray.count <= 9) {
        if (![self.loadInfoMap[@(index)] boolValue]) {
            self.loadInfoMap[@(index)] = [NSNumber numberWithBool:YES];
            [self loadHighQualityPreviewPhotoForIndex:index];
        }
    } else {
        NSInteger startIndex = 0;
        NSInteger endIndex = startIndex + 8;
        if (self.currentIndex > 3 && self.currentIndex < self.photosArray.count - 4) {
            startIndex = self.currentIndex - 4;
            endIndex = startIndex + 8;
            
        } else if (self.currentIndex >= self.photosArray.count - 4) {
            endIndex = self.photosArray.count - 1;
            startIndex = endIndex - 8;
            
        } else {
            
        }
        for (NSInteger innerIndex = startIndex; innerIndex <= endIndex; innerIndex ++) {
            UIScrollView *scrollView = [self.previewScrollView viewWithTag:BASE_TAG + innerIndex - startIndex];
            UIImageView *imageView = [scrollView.subviews lastObject];
            ALAsset *asset = self.photosArray[innerIndex];
            imageView.image = [UIImage imageWithCGImage:asset.aspectRatioThumbnail];
        }
        [self loadHighQualityPreviewPhotoForIndex:index - startIndex];
    }
}

- (void)loadHighQualityPreviewPhotoForIndex:(NSInteger)index {
    UIScrollView *scrollView = [self.previewScrollView viewWithTag:BASE_TAG + index];
    UIImageView *imageView = [scrollView.subviews lastObject];
    if ([UIDevice systemMainVersion] >=.0) {
        PHImageRequestOptions *options = [[PHImageRequestOptions alloc] init];
        [[PHImageManager defaultManager] requestImageForAsset:self.photosArray[index]
                                                   targetSize:scrollView.bounds.size
                                                  contentMode:PHImageContentModeDefault
                                                      options:options
                                                resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
            imageView.image = [result copy];
        }];
    } else {
        imageView.image = [UIImage imageWithCGImage:[[self.photosArray[_currentIndex] defaultRepresentation] fullScreenImage]];
    }
}


#pragma mark - UIScrollViewDelegate

- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    if (fabsf(fmodf(scrollView.contentOffset.x, scrollView.width)) <= 0) {
        [self scrollViewDidEndAnimation:scrollView];
        NSLog(@"scrollViewDidScroll");
    }
}

- (void)scrollViewWillBeginDragging:(UIScrollView *)scrollView {
    self.checkImageView.userInteractionEnabled = NO;
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
    if (!decelerate) {
        self.checkImageView.userInteractionEnabled = YES;
    }
}

- (void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView {
    self.checkImageView.userInteractionEnabled = YES;
}

- (void)scrollViewDidEndAnimation:(UIScrollView *)scrollView {
    NSInteger currentPage = scrollView.contentOffset.x / scrollView.width;
    [self updateScrollView:scrollView forCurrentPage:currentPage byDefault:NO];
}


#pragma mark - Setters && Getters

- (void)setPhotosArray:(NSArray *)photosArray {
    _photosArray = photosArray;
}

- (NSMutableDictionary *)loadInfoMap {
    if (!_loadInfoMap) {
        _loadInfoMap = [NSMutableDictionary dictionary];
    }
    return _loadInfoMap;
}

- (NIPAlbumToolbarView *)toolbarView {
    if (!_toolbarView) {
        _toolbarView = [[NIPAlbumToolbarView alloc] init];
        _toolbarView.backgroundColor = [UIColor colorWithIntegerR:50 g:50 b:50 a:0.5];
        [_toolbarView setNumber:self.selectedPhotosArray.count animated:YES];
        [_toolbarView hidePreviewBtn];
        WEAK_SELF(weakSelf)
        _toolbarView.doneBlock = ^ {
            if (weakSelf.selectedPhotosBlock) {
                weakSelf.selectedPhotosBlock(weakSelf.selectedPhotosArray);
                [weakSelf cancelButtonPressed:nil];
            }
        };
    }
    return _toolbarView;
}

- (UIImageView *)checkImageView {
    if (!_checkImageView) {
        _checkImageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 30, 30)];
        _checkImageView.contentMode = UIViewContentModeCenter;
        _checkImageView.highlightedImage = [UIImage imageNamed:@"checkbox_selected"];
        _checkImageView.image = [UIImage imageNamed:@"checkbox_selected_gray"];
        [_checkImageView makeTapableWithTarget:self action:@selector(checkImageViewTapped:)];
    }
    return _checkImageView;
}

- (UIScrollView *)previewScrollView {
    if (!_previewScrollView) {
        _previewScrollView = [[UIScrollView alloc] initWithFrame:self.view.bounds];
        _previewScrollView.showsVerticalScrollIndicator = NO;
        _previewScrollView.showsHorizontalScrollIndicator =  NO;
        _previewScrollView.pagingEnabled = YES;
        _previewScrollView.delegate = self;
    }
    return _previewScrollView;
}


@end
