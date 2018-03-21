//
//  NIPPhotoPreviewViewController.h
//  NSIP
//
//  Created by Eric on 2016/12/19.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPMyBaseViewController.h"
#import "NIPPhotosViewController.h"

typedef NS_ENUM(NSUInteger, NIPPhotoPreviewType) {
    NIPPhotoPreviewTypePreviewAll,
    NIPPhotoPreviewTypePreviewSelected,
    NIPPhotoPreviewTypePreviewSelectedOutside,
};

@interface NIPPhotoPreviewViewController : NIPMyBaseViewController

@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, strong) NSMutableArray *selectedPhotosArray;
@property (nonatomic, assign) NSInteger availableCount;
@property (nonatomic, assign) NIPPhotoPreviewType previewType;

@property (nonatomic, assign) NSInteger currentIndex;

@property (nonatomic, copy) NIPSelectedPhotosBlock selectedPhotosBlock;


@end
