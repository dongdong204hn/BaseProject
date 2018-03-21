//
//  NIPPhotoCell.m
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPPhotoCell.h"
#import "nip_macros.h"
#import "UIView+NIPBasicAdditions.h"
#import "UIDevice+NIPBasicAdditions.h"

#import <Photos/Photos.h>
#import <AssetsLibrary/AssetsLibrary.h>


@interface NIPPhotoCell ()

@property (nonatomic, strong) UIImageView *photoImageView;
@property (nonatomic, strong) UIImageView *checkImageView;

@end

@implementation NIPPhotoCell

- (instancetype)initWithFrame:(CGRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        [self initViews];
        [self addConstraints];
    }
    return self;
}

- (void)initViews {
    [self.contentView addSubview:self.photoImageView];
    [self.contentView addSubview:self.checkImageView];
}

- (void)addConstraints {
    [self.photoImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.photoImageView autoPinEdgeToSuperviewEdge:ALEdgeLeft];
    [self.photoImageView autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.photoImageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    
    [self.checkImageView autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.checkImageView autoPinEdgeToSuperviewEdge:ALEdgeRight];
    [self.checkImageView autoSetDimensionsToSize:CGSizeMake(30, 30)];
}

- (void)updateDisplayInfo {
    if ([UIDevice systemMainVersion] >= 8.0) {
        [self updateDisplayInfoForSystemVersionBeyondIOS8];
    } else {
        [self updateDisplayInfoForSystemVersionBelowIOS8];
    }
}

- (void)updateDisplayInfoForSystemVersionBeyondIOS8 {
    PHAsset *asset = (PHAsset *)_asset;
    WEAK_SELF(weakSelf)
    [[PHImageManager defaultManager] requestImageForAsset:asset
                                               targetSize:CGSizeZero
                                              contentMode:PHImageContentModeDefault
                                                  options:nil
                                            resultHandler:^(UIImage * _Nullable result, NSDictionary * _Nullable info) {
        weakSelf.photoImageView.image = [result copy];
    }];
}

- (void)updateDisplayInfoForSystemVersionBelowIOS8 {
    ALAsset *asset = (ALAsset *)_asset;
    self.photoImageView.image = [UIImage imageWithCGImage:asset.thumbnail];
}

- (void)checkImageViewTapped:(id)sender {
    WEAK_SELF(weakSelf)
    if (self.canSelectAssetBlock(weakSelf.asset, !weakSelf.isPotoSelected)) {
        self.isPotoSelected = !self.isPotoSelected;
    }
}


#pragma mark - Setters && Getters

- (void)setAsset:(id)asset {
    _asset = asset;
    [self updateDisplayInfo];
}

- (void)setIsPotoSelected:(BOOL)isPotoSelected {
    _isPotoSelected = isPotoSelected;
    if (_isPotoSelected) {
        _checkImageView.image = [UIImage imageNamed:@"checkbox_selected"];
    } else {
        _checkImageView.image = [UIImage imageNamed:@"checkbox_selected_gray"];
    }
}

- (UIImageView *)photoImageView {
    if (!_photoImageView) {
        _photoImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _photoImageView.contentMode = UIViewContentModeScaleToFill;
        _photoImageView.clipsToBounds = YES;
    }
    
    return _photoImageView;
}

- (UIImageView *)checkImageView {
    if (!_checkImageView) {
        _checkImageView = [[UIImageView alloc] initWithFrame:CGRectZero];
        _checkImageView.contentMode = UIViewContentModeCenter;
        _checkImageView.image = [UIImage imageNamed:@"checkbox_selected_gray"];
        [_checkImageView makeTapableWithTarget:self action:@selector(checkImageViewTapped:)];
    }
    return _checkImageView;
}


@end
