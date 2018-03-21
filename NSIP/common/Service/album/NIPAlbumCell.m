//
//  NIPAlbumCell.m
//  NSIP
//
//  Created by Eric on 2016/11/25.
//  Copyright © 2016年 netease. All rights reserved.
//

#import "NIPAlbumCell.h"
#import "NIPAlbumInfo.h"

#import "NIPUIFactory.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "UIView+NIPBasicAdditions.h"


@interface NIPAlbumCell ()


@property (nonatomic, strong) UIImageView *albumThumbnailImV;
@property (nonatomic, strong) UILabel *albumTitleLabel;

@end

@implementation NIPAlbumCell


+ (CGFloat)height {
    return [UIDevice screenWidth] * 150 / 375;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        [self initViews];
        [self addConstraints];
        
    }
    return self;
}

- (void)initViews {
    [self.contentView addSubview:self.albumThumbnailImV];
    [self.contentView addSubview:self.albumTitleLabel];
}

- (void)addConstraints {
    [self.albumThumbnailImV autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.albumThumbnailImV autoPinEdgeToSuperviewEdge:ALEdgeLeft withInset:3];
    [self.albumThumbnailImV autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.albumThumbnailImV autoMatchDimension:ALDimensionWidth toDimension:ALDimensionHeight ofView:self.albumThumbnailImV];
    
    [self.albumTitleLabel autoPinEdge:ALEdgeLeft toEdge:ALEdgeRight ofView:self.albumThumbnailImV withOffset:5];
    [self.albumTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeTop];
    [self.albumTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeBottom];
    [self.albumTitleLabel autoPinEdgeToSuperviewEdge:ALEdgeRight withInset:-100];
}

- (void)updateDisplayInfo {
    [self setAlbumThumbnailImVWithRedrawedImage];
    [self fillAlbumTitleLabelWithAttributedText];
}

- (void)setAlbumThumbnailImVWithRedrawedImage {
    UIGraphicsBeginImageContext(CGSizeMake(self.contentView.height, self.contentView.height));
    [self.albumInfo.albumThumbnailImage drawInRect:CGRectMake(0,0,self.contentView.height, self.contentView.height)];
    UIImage* redrawedImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    self.albumThumbnailImV.image = redrawedImage;
}

- (void)fillAlbumTitleLabelWithAttributedText {
    NSString *orignalText = [NSString stringWithFormat:@"%@ (%ld)", self.albumInfo.albumTitle, (long)self.albumInfo.albumPhotoCount];
    NSDictionary *attributeDic = @{NSFontAttributeName: [UIFont systemFontOfSize:15],
                                   NSForegroundColorAttributeName: [UIColor lightGrayColor]};
    NSString *grayString = [orignalText substringFromIndex:[orignalText rangeOfString:@"("].location];
    NSRange grayRange = [orignalText rangeOfString:grayString];
    NSMutableAttributedString *attributeText = [[NSMutableAttributedString alloc] initWithString:orignalText];
    [attributeText addAttributes:attributeDic range:grayRange];
    
    self.albumTitleLabel.attributedText = attributeText;
}


#pragma mark - Setters && Getters 

- (void)setAlbumInfo:(NIPAlbumInfo *)albumInfo {
    _albumInfo = albumInfo;
    [self updateDisplayInfo];
}


- (UIImageView *)albumThumbnailImV {
    if (!_albumThumbnailImV) {
        _albumThumbnailImV = [[UIImageView alloc] initWithFrame:CGRectZero];
    }
    return _albumThumbnailImV;
}

- (UILabel *)albumTitleLabel {
    if (!_albumTitleLabel) {
        _albumTitleLabel = [NIPUIFactory labelWithText:@"" boldFont:15 textColor:[UIColor blackColor]];
        _albumTitleLabel.textAlignment = NSTextAlignmentLeft;
    }
    return _albumTitleLabel;
}

@end
