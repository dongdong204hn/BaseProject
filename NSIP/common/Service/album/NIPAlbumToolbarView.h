//
//  NIPAlbumToolbarView.h
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import <UIKit/UIKit.h>


typedef void(^NIPAlbumToolbarViewPreviewBlock)(void);
typedef void(^NIPAlbumToolbarViewDoneBlock)(void);

@interface NIPAlbumToolbarView : UIView

@property (nonatomic, assign) CGFloat selectedPhotosCount;

@property (nonatomic, copy) NIPAlbumToolbarViewPreviewBlock previewBlock;
@property (nonatomic, copy) NIPAlbumToolbarViewDoneBlock doneBlock;

- (void)hidePreviewBtn;
- (void)setNumber:(NSInteger)number animated:(BOOL)animated;

@end
