//
//  NIPPhotoCell.h
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef BOOL (^NIPPhotoCheckImageTappedBlock)(id asset, BOOL isPotoSelected);

@interface NIPPhotoCell : UICollectionViewCell

@property (nonatomic, strong) id asset;
@property (nonatomic, copy) NIPPhotoCheckImageTappedBlock canSelectAssetBlock;

@property (nonatomic, assign) BOOL isPotoSelected;
@end
