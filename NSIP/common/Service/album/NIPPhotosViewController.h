//
//  NIPPhotosViewController.h
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPBaseViewController.h"


typedef void(^NIPSelectedPhotosBlock)(NSArray *selectedPhotosArray);

@interface NIPPhotosViewController : NIPBaseViewController

@property (nonatomic, strong) NSArray *photosArray;
@property (nonatomic, assign) NSInteger availableCount;

@property (nonatomic, copy) NIPSelectedPhotosBlock selectedPhotosBlock;

@end
