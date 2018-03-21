//
//  NIPAlbumInfo.h
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NIPAlbumInfo : NSObject

@property (nonatomic, strong) NSString *albumTitle;
@property (nonatomic, assign) NSInteger albumPhotoCount;
@property (nonatomic, strong) UIImage *albumThumbnailImage;

@end
