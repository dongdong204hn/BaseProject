//
//  NIPAlbumListViewController.h
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseViewController.h"
#import "NIPPhotosViewController.h"

@interface NIPAlbumListViewController : NIPBaseViewController


@property (nonatomic, assign) NSInteger availableCount;

@property (nonatomic, copy) NIPSelectedPhotosBlock selectedPhotosBlock;

@end
