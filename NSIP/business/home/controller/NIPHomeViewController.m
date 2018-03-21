//
//  NIPHomeViewController.m
//  NSIP
//
//  Created by Eric on 16/10/14.
//  Copyright © 2016年 Eric. All rights reserved.
//

#import "NIPHomeViewController.h"
#import "NIPURLHandler.h"
#import "NIPUIFactory.h"
#import "NIPAlbumListViewController.h"

#import <AVFoundation/AVFoundation.h>
#import <AssetsLibrary/AssetsLibrary.h>
#import <Photos/Photos.h>

#import "NIPAlertView.h"
#import "NIPUIFactoryChild.h"
#import "UIView+NIPBasicAdditions.h"
#import "UIDevice+NIPBasicAdditions.h"
#import "NIPImageFactory.h"
#import "NIPNavigationController.h"
#import "nip_macros.h"

#import "NIPProductService.h"
#import "NIPPartnerGoodsResponse.h"
#import "NIPWatchItem.h"

#import <UMengUShare/UShareUI/UShareUI.h>
#import <UMengUShare/UMSocialCore/UMSocialCore.h>

@interface NIPHomeViewController () <UIImagePickerControllerDelegate, UINavigationControllerDelegate>

@property (nonatomic, strong) UIImageView *imageView;
@property (nonatomic, strong) NSMutableArray *selectedPhotosArray;

@property (nonatomic, strong) UILabel *httpResponseLabel;

@end


@implementation NIPHomeViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"首页";
    
    UIButton *queryButton = [NIPUIFactoryChild buttonWithTitle:@"网络请求测试" target:self selector:@selector(queryBtnPressed:)];
    [self.contentView addSubview:queryButton];
    queryButton.center = self.contentView.center;
    
    UIButton *shareButton = [NIPUIFactoryChild buttonWithTitle:@"分享测试" target:self selector:@selector(shareBtnPressed:)];
    [self.contentView addSubview:shareButton];
    [shareButton makeCenter];
    shareButton.bottom = queryButton.top - 10;
    
    UIButton *pageButton = [NIPUIFactoryChild buttonWithTitle:@"开启一个位于第三个tab的页面" target:self selector:@selector(jumpToViewController:)];
    [self.contentView addSubview:pageButton];
    pageButton.center = self.contentView.center;
    pageButton.centerY = self.contentView.centerY + 50;
    
    UIButton *webButton = [NIPUIFactoryChild buttonWithTitle:@"开启一个web页" target:self selector:@selector(jumpToWebViewController:)];
    [self.contentView addSubview:webButton];
    webButton.center = self.contentView.center;
    webButton.top = pageButton.bottom + 20;
    
    
    UIButton *takePhotoButton = [NIPUIFactory buttonWithTitle:@"调起相机" target:self selector:@selector(takePhotoButtonPressed:)];
    [self.contentView addSubview:takePhotoButton];
    takePhotoButton.center = self.contentView.center;
    takePhotoButton.top = webButton.bottom + 20;
    
    UIButton *choosePhotoButton = [NIPUIFactory buttonWithTitle:@"打开相册" target:self selector:@selector(choosePhotoButtonPressed:)];
    [self.contentView addSubview:choosePhotoButton];
    choosePhotoButton.center = self.contentView.center;
    choosePhotoButton.top = takePhotoButton.bottom + 20;
    
    _imageView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 200, 200)];
    [self.contentView addSubview:_imageView];
    _imageView.centerX = self.contentView.centerX;
    _imageView.bottom = pageButton.top - 50;
    
    _httpResponseLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 20, [UIDevice screenWidth]- 40, 300)];
    _httpResponseLabel.numberOfLines = 0;
    [self.contentView addSubview:_httpResponseLabel];
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
}


#pragma mark - selectors

- (void)shareBtnPressed:(id)sender {
    [UMSocialUIManager showShareMenuViewInWindowWithPlatformSelectionBlock:^(UMSocialPlatformType platformType, NSDictionary *userInfo) {
        UMSocialMessageObject *messageObject = [UMSocialMessageObject messageObject];
        //设置文本
        messageObject.text = @"丫丫的呸的！！";
        
        //调用分享接口
        [[UMSocialManager defaultManager] shareToPlatform:platformType messageObject:messageObject currentViewController:self completion:^(id data, NSError *error) {
            if (error) {
                UMSocialLogInfo(@"************Share fail with error %@*********",error);
            }else{
                if ([data isKindOfClass:[UMSocialShareResponse class]]) {
                    UMSocialShareResponse *resp = data;
                    //分享结果消息
                    UMSocialLogInfo(@"response message is %@",resp.message);
                    //第三方原始返回的数据
                    UMSocialLogInfo(@"response originalResponse data is %@",resp.originalResponse);

                }else{
                    UMSocialLogInfo(@"response data is %@",data);
                }
            }
        }];

    }];
}

- (void)queryBtnPressed:(id)sender {
    WEAK_SELF(weakSelf)
    [[NIPProductService sharedService] queryDefaultPartnerGoodsOnComplete:^(NIPPartnerGoodsResponse *response) {
        if (response.retCode == 200) {
            NIPWatchItem *item = response.ret[0];
            weakSelf.httpResponseLabel.text = item.description;
        } else {
            weakSelf.httpResponseLabel.text = response.retDesc;
        }
    }];
}

- (void)jumpToWebViewController:(id)sender {
    [[NIPURLHandler sharedHandler] openStringUrl:@"https://www.baidu.com?hideToolBar=YES" inController:self];
}

- (void)takePhotoButtonPressed:(id)sender {
    if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
        
        if (status == AVAuthorizationStatusRestricted || status == AVAuthorizationStatusDenied) {
            [self showRemindAlertViewWithMessage:@"请在iPhone的“设置-隐私-相机”选项中，允许XXX访问您的相机。"];
            return;
        }
        UIImagePickerController * cameraPicker = [[UIImagePickerController alloc] init];
        cameraPicker.delegate = self;
        cameraPicker.allowsEditing = NO;
        cameraPicker.sourceType = UIImagePickerControllerSourceTypeCamera;
        //  相机的调用为照相模式,此外还有video
        cameraPicker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModePhoto;
        //  设置为NO则隐藏了拍照按钮
        cameraPicker.showsCameraControls = YES;
        //  设置相机摄像头默认为前置
        cameraPicker.cameraDevice = UIImagePickerControllerCameraDeviceFront;
        //  设置相机闪光灯开关
        cameraPicker.cameraFlashMode = UIImagePickerControllerCameraFlashModeAuto;
        //  用来设置覆盖在你照相图像上,可以自定义位置或图片(类似美图秀秀加个小猫小狗小花修饰)
        //cameraPicker.cameraOverlayView
        //  用来修改拍照相框
        //cameraPicker.cameraViewTransform
        [self presentViewController:cameraPicker animated:YES completion:nil];
        
    } else {
        NSLog(@"当前设备不支持相机调用");
    }
    
}

- (void)choosePhotoButtonPressed:(id)sender {
    if ([UIDevice systemMainVersion] >= 8.0 ) {
        [self choosePhotosOnDevicesSystemVersionBeyondIOS8];
    } else {
        [self choosePhotosOnDevicesSystemVersionBelowIOS8];
    }
}


#pragma mark - action code

- (void)showAlbumListViewController {
    NIPAlbumListViewController *viewController = [[NIPAlbumListViewController alloc] init];
    viewController.availableCount = 9 - self.selectedPhotosArray.count;
    WEAK_SELF(weakSelf)
    viewController.selectedPhotosBlock = ^(NSArray *selectedPhotosArray) {
        [weakSelf.selectedPhotosArray addObjectsFromArray:selectedPhotosArray];
    };
    UINavigationController *naviController = [[NIPNavigationController alloc] initWithRootViewController:viewController];
    [NIPUIFactory setNormalBackgroundImage:[NIPImageFactory navigationBarBackgroundImage] toNavigationBar:naviController.navigationBar];
    [self.navigationController presentViewController:naviController animated:YES completion:nil];
}

- (void)jumpToViewController:(id)sender {
     [[NIPURLHandler sharedHandler] openStringUrl:@"nsip://testPage" inController:nil];
}

- (void)showRemindAlertViewWithMessage:(NSString *)message {
    [NIPAlertView simpleAlertWithTitle:@""
                               message:message
                             onDismiss:nil];
}

- (void)choosePhotosOnDevicesSystemVersionBeyondIOS8 {
    PHAuthorizationStatus status= [PHPhotoLibrary authorizationStatus];
    if (status == PHAuthorizationStatusRestricted ||
        status == PHAuthorizationStatusDenied) {
        [self showRemindAlertViewWithMessage:@"请在iPhone的“设置-隐私-照片”选项中，允许XXX访问您的手机相册。"];
        return;
    }
    [self showAlbumListViewController];

}

- (void)choosePhotosOnDevicesSystemVersionBelowIOS8 {
    ALAuthorizationStatus status = [ALAssetsLibrary authorizationStatus];
    if (status == ALAuthorizationStatusRestricted ||
        status == ALAuthorizationStatusDenied) {
        [self showRemindAlertViewWithMessage:@"请在iPhone的“设置-隐私-照片”选项中，允许XXX访问您的手机相册。"];
        return;
    }
    [self showAlbumListViewController];
}


#pragma mark - UIImagePickerControllerDelegate methods

- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info {
    if (picker.sourceType == UIImagePickerControllerSourceTypeCamera) {
        UIImage * image = [info objectForKey:UIImagePickerControllerOriginalImage];
        WEAK_SELF(weakSelf)
        [self dismissViewControllerAnimated:YES completion:^{
            weakSelf.imageView.image = image;
        }];
    }
}


#pragma mark - Setters && Getters

- (NSMutableArray *)selectedPhotosArray {
    if (!_selectedPhotosArray) {
        _selectedPhotosArray = [NSMutableArray array];
    }
    return _selectedPhotosArray;
}


@end
